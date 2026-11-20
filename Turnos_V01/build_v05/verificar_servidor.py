import shutil, concurrent.futures, ctypes, http.client, json, pathlib, socket, subprocess, time
root=pathlib.Path.cwd(); build=root/'build_v05'; exe=build/'ServidorRest.exe'
# No utilizar un servidor ajeno si el puerto ya esta ocupado.
s=socket.socket(); s.bind(('127.0.0.1',8081)); s.close()
si=subprocess.STARTUPINFO(); si.dwFlags|=subprocess.STARTF_USESHOWWINDOW; si.wShowWindow=0
p=subprocess.Popen([str(exe)],cwd=build,startupinfo=si)
def req(body=b'{"prueba":true}',path='/api/lis/turnos',method='POST'):
    c=http.client.HTTPConnection('127.0.0.1',8081,timeout=6)
    try:
        c.request(method,path,body,{'Content-Type':'application/json; charset=utf-8'})
        r=c.getresponse(); return r.status,r.read()
    finally: c.close()
try:
    for n in range(40):
        if p.poll() is not None: raise RuntimeError('El servidor termino al iniciar')
        try:
            with socket.create_connection(('127.0.0.1',8081),timeout=.2): pass
            break
        except OSError: time.sleep(.1)
    order_path='/api/lis/ordenes'
    raw=json.dumps({'orden':'Internacion Niño Álvarez','datos':[1,2]},ensure_ascii=False).encode('utf-8')
    status,body=req(raw,path=order_path)
    answer=json.loads(body)
    assert status==200 and answer=={'ok':True,'mensaje':'Orden recibida correctamente por SAGE','estado':'RECIBIDO'}
    assert any(f.read_bytes()==raw for f in (build/'Logs/Ordenes').glob('Orden_*.json'))
    assert req(b'  \r\n ',path=order_path)[0]==400
    assert req(path=order_path,method='GET')[0]==405
    # This receiver intentionally does not parse JSON or require fields.
    assert req(b'contenido sin estructura JSON',path=order_path)[0]==200
    before=len(list((build/'Logs/Ordenes').glob('*.json')))
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        result=list(pool.map(lambda n:req(raw,path=order_path),range(20)))
    assert all(r[0]==200 for r in result)
    assert len(list((build/'Logs/Ordenes').glob('*.json')))-before==20
    folder=build/'Logs/Ordenes'; saved=build/'Logs/Ordenes_test_guardados'
    folder.rename(saved); folder.write_text('Bloqueo de prueba')
    try: assert req(raw,path=order_path)[0]==500
    finally: folder.unlink(); saved.rename(folder)
    assert req(raw,path=order_path)[0]==200
    print('OK: Ordenes 200 generico sin protocolo ficticio; RAW UTF-8 exacto; vacio 400; GET 405; sin parseo; 20 simultaneas; guardado 500 y recuperacion')
    for n in range(30):
        with socket.create_connection(('127.0.0.1',8081),timeout=2) as c:
            c.settimeout(3)
            c.sendall(b'COMANDO_INVALIDO\r\n' if n % 2 else b'SSH-2.0-Prueba\r\n')
            assert c.recv(1024)==b'', 'No cerro la conexion invalida'
        assert req()[0]==200
    print('OK: 30 comandos invalidos descartados y 30 POST posteriores correctos')
    payload=json.dumps({'prueba':'Niño Álvarez'},ensure_ascii=False).encode('utf-8')
    assert req(payload)[0]==200
    assert any(f.read_bytes()==payload for f in (build/'Logs/Turnos').glob('*.json'))
    assert req(b'')[0]==400
    assert req(path='/no-existe')[0]==404
    assert req(method='PUT')[0]==405
    print('OK: 200 + RAW UTF-8 exacto; 400; 404; 405')
    for data in (b'', b'POST /api/lis/turnos HTTP/1.1\r\nHost: prueba\r\n',b'POST /api/lis/turnos HTTP/1.1\r\nHost: prueba\r\nContent-Length: 100\r\n\r\n{'):
        for _ in range(12):
            with socket.create_connection(('127.0.0.1',8081),timeout=2) as c:
                if data: c.sendall(data)
    time.sleep(1)
    assert p.poll() is None
    assert req()[0]==200
    print('OK: 36 conexiones interrumpidas; servidor sigue respondiendo')
    before=len(list((build/'Logs/Turnos').glob('*.json')))
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as pool:
        results=list(pool.map(lambda n:req(json.dumps({'pruebaConcurrente':n}).encode()),range(40)))
    assert all(r[0]==200 for r in results)
    assert len(list((build/'Logs/Turnos').glob('*.json')))-before==40
    print('OK: 40 POST concurrentes = 40 archivos RAW')
    folder=build/'Logs/Turnos'; saved=build/'Logs/Turnos_test_guardados'
    folder.rename(saved)
    folder.write_text('Bloqueo de prueba: impide crear directorio')
    try: assert req()[0]==500
    finally: folder.unlink(); saved.rename(folder)
    assert req()[0]==200
    print('OK: fallo de guardado devuelve 500; recuperacion posterior 200')
    token=(build/'ServidorRest.ini').read_text().split('Token=',1)[1].strip()
    def get_monitor(cursor=None,key=token):
        c=http.client.HTTPConnection('127.0.0.1',8081,timeout=10)
        try:
            path='/api/lis/recepciones'+('' if cursor is None else '?desde='+str(cursor))
            c.request('GET',path,headers={'X-SAGE-Monitor-Key':key})
            r=c.getresponse();return r.status,json.loads(r.read())
        finally:c.close()
    assert get_monitor(key='incorrecta')[0]==401
    status,initial=get_monitor();assert status==200 and initial['recepciones']==[]
    start=initial['ultimoId'];epoch=initial['instancia']
    # RAW antiguo se recupera, pero archivos incompletos no aparecen.
    partial=build/'Logs/Ordenes/Orden_20261104_120000_000_00000000-0000-0000-0000-000000000001.json.part'
    partial.write_bytes(b'parcial')
    assert get_monitor()[1]['ultimoId']==start
    cfgdir=build/('monitor_test_'+str(time.time_ns()));cfgdir.mkdir(exist_ok=True)
    cfg=cfgdir/'MonitorRecepciones.json'
    cfg.write_text(json.dumps({'url':'http://127.0.0.1:8081/api/lis/recepciones','token':token,'intervaloSegundos':5}))
    def monitor_once():
        result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(root/'monitor_recepciones/MonitorRecepciones.ps1'),'-Configuracion',str(cfg),'-UnaVez','-SinAviso'],capture_output=True,timeout=30)
        assert result.returncode==0,result.stdout.decode(errors='replace')+result.stderr.decode(errors='replace')
    monitor_once()
    assert json.loads((cfgdir/'EstadoMonitor/estado.json').read_text(encoding='utf-8-sig'))['ultimoId']==start
    assert req(b'{"nuevo":"turno"}')[0]==200
    assert req(b'{"nuevo":"orden"}',path='/api/lis/ordenes')[0]==200
    status,delta=get_monitor(start)
    assert status==200 and len(delta['recepciones'])==2
    assert {x['tipo'] for x in delta['recepciones']}=={'TURNO','ORDEN'}
    assert all(set(x)=={'id','tipo','fechaHoraLocal','archivo'} for x in delta['recepciones'])
    monitor_once();monitor_once()
    assert len(list((cfgdir/'EstadoMonitor/Avisos').glob('*.notificado.json')))==2
    assert get_monitor('abc')[0]==409 and get_monitor(-1)[0]==409
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        assert all(r[0]==200 for r in pool.map(lambda n:req(b'RAW',path='/api/lis/ordenes'),range(105)))
    status,page1=get_monitor(delta['siguienteId']);assert page1['hayMas'] and len(page1['recepciones'])==100
    status,page2=get_monitor(page1['siguienteId']);assert not page2['hayMas'] and len(page2['recepciones'])==5
    monitor_once()
    assert len(list((cfgdir/'EstadoMonitor/Avisos').glob('*.notificado.json')))==107
    # Un indice no persistible debe dar error, no una falsa consulta vacia.
    index=build/'Logs/Recepciones.idx'; preserved=build/'Logs/Recepciones_test.idx'
    index.rename(preserved);index.mkdir()
    try: assert get_monitor()[0]==500
    finally: index.rmdir();preserved.rename(index)
    assert get_monitor()[1]['instancia']==epoch
    statepath=cfgdir/'EstadoMonitor/estado.json'
    state_before=statepath.read_bytes()
    original=index.read_bytes()
    changed=original.replace(epoch.encode(),b'00000000-0000-0000-0000-000000000099',1)
    index.write_bytes(changed)
    try:
        result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(root/'monitor_recepciones/MonitorRecepciones.ps1'),'-Configuracion',str(cfg),'-UnaVez','-SinAviso'],capture_output=True,timeout=30)
        assert result.returncode!=0 and statepath.read_bytes()==state_before
    finally:index.write_bytes(original)
    # Reinicio real: mismos IDs e instancia, sin renotificar historial.
    cb_restart=ctypes.WINFUNCTYPE(ctypes.c_bool,ctypes.c_void_p,ctypes.c_void_p)
    def close_restart(hwnd,param):
        pid=ctypes.c_ulong();ctypes.windll.user32.GetWindowThreadProcessId(hwnd,ctypes.byref(pid))
        if pid.value==p.pid:ctypes.windll.user32.PostMessageW(hwnd,0x0010,0,0)
        return True
    ctypes.windll.user32.EnumWindows(cb_restart(close_restart),0);p.wait(timeout=8)
    result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(root/'monitor_recepciones/MonitorRecepciones.ps1'),'-Configuracion',str(cfg),'-UnaVez','-SinAviso'],capture_output=True,timeout=30)
    assert result.returncode!=0 and statepath.read_bytes()==state_before
    p=subprocess.Popen([str(exe)],cwd=build,startupinfo=si)
    for n in range(60):
        try:
            status,after=get_monitor();break
        except OSError:time.sleep(.1)
    assert after['instancia']==epoch and after['ultimoId']==page2['ultimoId']
    assert req(b'RAW tras reinicio')[0]==200
    monitor_once()
    assert len(list((cfgdir/'EstadoMonitor/Avisos').glob('*.notificado.json')))==108
    print('OK: error de indice, cambio de instancia y servidor desconectado no avanzan cursor')
    print('OK: consulta protegida; bootstrap sin historial; RAW .part ignorado; Turnos/Ordenes; monitor PS persistente sin avisos duplicados; 105 novedades paginadas; reinicio mantiene instancia/cursor y recupera novedades')
    time.sleep(.5)
    log=''.join(f.read_text(encoding='utf-8') for f in (build/'Logs').glob('Servidor_*.log'))
    for value in ('EUREKALOG activo','SOLICITUD_DESCARTADA','CIERRE_REMOTO','ERROR_SOLICITUD','RESPUESTA_PREPARADA','RAW_GUARDADO'):
        assert value in log,value
    assert not list(build.glob('*.elf')), 'EurekaLog genero un ELF inesperado'
    print('OK: EurekaLog activo, desconexiones registradas, sin ELF')
finally:
    # Cierre por WM_CLOSE para verificar que no espera al hilo de pantalla.
    cb=ctypes.WINFUNCTYPE(ctypes.c_bool,ctypes.c_void_p,ctypes.c_void_p)
    def close(hwnd,param):
        pid=ctypes.c_ulong(); ctypes.windll.user32.GetWindowThreadProcessId(hwnd,ctypes.byref(pid))
        if pid.value==p.pid: ctypes.windll.user32.PostMessageW(hwnd,0x0010,0,0)
        return True
    ctypes.windll.user32.EnumWindows(cb(close),0)
    try: p.wait(timeout=8); print('OK: cierre del servidor sin bloqueo')
    except subprocess.TimeoutExpired: p.kill(); p.wait(); raise AssertionError('Cierre bloqueado')

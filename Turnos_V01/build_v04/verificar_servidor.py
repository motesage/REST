import concurrent.futures, ctypes, http.client, json, pathlib, socket, subprocess, time
root=pathlib.Path.cwd(); build=root/'build_v04'; exe=build/'ServidorRest.exe'
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

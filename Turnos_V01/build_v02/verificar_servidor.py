import concurrent.futures, ctypes, http.client, json, pathlib, socket, subprocess, time
root=pathlib.Path.cwd(); build=root/'build_v02'; exe=build/'ServidorRest.exe'
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
    for value in ('EUREKALOG activo','CIERRE_REMOTO','ERROR_SOLICITUD','RESPUESTA_PREPARADA','RAW_GUARDADO'):
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

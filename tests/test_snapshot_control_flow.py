from pathlib import Path
import tempfile,subprocess,os
source=(Path(__file__).resolve().parents[1]/'scripts/dp103-system-snapshot.sh').read_text()
for mode in ['success','dd-failure','timeout','wrong-model','existing-image']:
    with tempfile.TemporaryDirectory(prefix='snapshot-test-') as directory:
        root=Path(directory).resolve();binary=root/'bin';binary.mkdir()
        temporary=root/'local-tmp';stage=temporary/'dp103-backup-before-google';stage.mkdir(parents=True)
        size=root/'system-size';size.write_text('2097152\n')
        def script(name,body):
            p=binary/name;p.write_text('#!/bin/sh\n'+body+'\n');p.chmod(0o755)
        script('id','echo 0')
        script('getprop','if [ "$CASE_MODE" = wrong-model ]; then echo OTHER; else echo DP103; fi')
        script('toybox','echo "$*" >> "$TEST_TRACE"')
        script('sleep','if [ "$CASE_MODE" = timeout ]; then /bin/sleep 0.02; else /bin/sleep 2; fi')
        script('dd','''if [ "$CASE_MODE" = dd-failure ]; then exit 7; fi
if [ "$CASE_MODE" = timeout ]; then
    count=0
    while [ ! -e "$TEST_TIMEOUT" ] && [ "$count" -lt 200 ]; do /bin/sleep 0.02; count=$((count+1)); done
fi
for arg in "$@"; do case "$arg" in of=*) printf snapshot > "${arg#of=}";; esac; done''')
        script('md5sum','echo 0123456789abcdef0123456789abcdef "${1}"')
        transformed=source.replace('/system/bin/',str(binary)+'/').replace('/data/local/tmp',str(temporary)).replace('/sys/class/block/mmcblk0p11/size',str(size))
        p=root/'snapshot.sh';p.write_text(transformed)
        if mode=='existing-image':(stage/'system.img').write_text('original')
        env=dict(os.environ,PATH=str(binary)+':'+os.environ['PATH'],CASE_MODE=mode,TEST_TRACE=str(root/'trace'),TEST_TIMEOUT=str(temporary/'dp103-backup-timeout'))
        result=subprocess.run(['sh',str(p)],env=env,text=True,capture_output=True,timeout=5)
        trace=(root/'trace').read_text() if (root/'trace').exists() else ''
        if mode=='success':
            assert result.returncode==0 and 'SNAPSHOT_READY' in result.stdout,(mode,result.stdout,result.stderr)
            assert 'fsfreeze -f /system' in trace and 'fsfreeze -u /system' in trace
        else:
            assert result.returncode!=0 and 'SNAPSHOT_READY' not in result.stdout,(mode,result.stdout,result.stderr)
            if mode in ['dd-failure','timeout']:assert 'fsfreeze -u /system' in trace,mode
            else:assert not trace,mode
            if mode=='existing-image':assert (stage/'system.img').read_text()=='original'
        print(mode,'passed')
print('Five mocked control-flow checks passed; no Android device operations performed.')

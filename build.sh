#!/bin/bash
# Echo Protocol – assemble index.html from src/ (everything stays inside /workspace/echo-protocol)
#   build/vendor.min.js   Three.js r170 + GLTFLoader + post passes, bundled by esbuild from src/vendor.js and INLINED (no code requests)
#   textures/ models/ audio/   optional artist files shipped next to index.html as separate files; only files that exist are ever requested
set -e
ROOT=/workspace/echo-protocol
case "$(cd "$(dirname "$0")" && pwd)" in "$ROOT") ;; *) echo "build.sh: refusing to run outside $ROOT"; exit 1;; esac
cd "$ROOT"
mkdir -p build textures models audio/sfx
if [ ! -f build/vendor.min.js ] || [ src/vendor.js -nt build/vendor.min.js ] || [ "$1" = "--vendor" ]; then
  (cd /workspace/ep-deps && NODE_PATH=/workspace/ep-deps/node_modules npx esbuild "$ROOT/src/vendor.js" --bundle --minify --format=iife \
     --legal-comments=none --target=es2020 --outfile="$ROOT/build/vendor.min.js" --log-level=warning)
fi
python3 - <<'PY'
import base64, struct, zlib, os, json
ROOT='/workspace/echo-protocol/'
def png(n):
    rows=[]
    for y in range(n):
        row=b'\x00'
        for x in range(n):
            cx,cy=(x+.5)/n-.5,(y+.5)/n-.5; r=(cx*cx+cy*cy)**.5
            c=(255,106,90,255) if .30<r<.42 else (233,244,246,255) if r<.12 else (5,8,11,255)
            row+=bytes(c)
        rows.append(row)
    ch=lambda t,d: struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    return 'data:image/png;base64,'+base64.b64encode(b'\x89PNG\r\n\x1a\n'+ch(b'IHDR',struct.pack('>IIBBBBB',n,n,8,6,0,0,0))+ch(b'IDAT',zlib.compress(b''.join(rows)))+ch(b'IEND',b'')).decode()
h=open(ROOT+'src/head.html').read()
for n in (32,16,180): h=h.replace('%%%%ICON%d%%%%'%n,png(n))
vendor=open(ROOT+'build/vendor.min.js').read().replace('</script','<\\/script')
js='"use strict";\n'+''.join(open(ROOT+'src/'+f).read()+'\n' for f in ('data.js','grid.js','textures.js','world.js','entity.js','game.js'))
def lst(d, exts):
    base=ROOT+d
    return sorted(os.path.relpath(os.path.join(p,f), base) for p,_,fs in os.walk(base) for f in fs if f.lower().endswith(exts))
tex=lst('textures',('.png','.jpg','.jpeg','.webp')); mod=lst('models',('.glb',)); aud=lst('audio',('.mp3','.ogg','.m4a','.wav'))
for k,v in (('TEXTURES',tex),('MODELS',mod),('AUDIO',aud)):
    t='/*%%'+k+'_PRESENT%%*/[]'; assert t in js, t; js=js.replace(t, json.dumps(v))
vm=ROOT+'audio/voice/voice-manifest.json'   # Pixel's voice manifest (clips[rec][line] = parts); embedded minus the notes
t='/*%%VOICE_MAP%%*/null'; assert t in js
if os.path.exists(vm):
    man=json.load(open(vm)); man.pop('_how',None)
    miss=[f for r in man['clips'].values() for L in r if L for parts in (L.values() if isinstance(L,dict) else [L]) for q in parts for f in ([q['f']] if isinstance(q['f'],str) else q['f'].values()) if 'voice/'+f not in aud]
    assert not miss, 'manifest clips missing from audio/voice: %r'%miss[:10]
    js=js.replace(t, json.dumps(man,separators=(',',':')))
else: js=js.replace(t,'null')
open(ROOT+'index.html','w').write(h+'<script>'+vendor+'</script>\n<script>\n'+js+'</script>\n</body>\n</html>\n')
print('textures shipped:', len(tex), tex); print('models shipped:', mod); print('audio shipped:', len(aud))
big=[(os.path.join(p,f),os.path.getsize(os.path.join(p,f))) for d in ('textures','models','audio') for p,_,fs in os.walk(ROOT+d) for f in fs]
big.append((ROOT+'index.html',os.path.getsize(ROOT+'index.html')))
over=[b for b in big if b[1]>25*1024*1024]
assert not over, 'files over 25 MB: %r'%over
print('largest file: %s %.2f MB; shipped total %.2f MB'%(max(big,key=lambda b:b[1])[0].replace(ROOT,''), max(b[1] for b in big)/1048576, sum(b[1] for b in big)/1048576))
PY
ls -l "$ROOT/index.html" | awk '{print "index.html", $5, "bytes"}'; sha256sum "$ROOT/index.html" | cut -c1-8

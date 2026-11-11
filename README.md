# Echo Protocol — Chapter 1 (Flux Studios Games)

A short first-person horror game for the browser, PG, ages 10+. You explore Thornfield Acoustics Station with a torch. Stand on the glowing rings by the tape players to hear the 1994 recordings. The recordings slowly start to talk about *you*: your torch, the room you're in, the colour of the card you picked up, how long you took, and where The Grinner is. The last tape is in your own voice, and then the lift opens. There are no jump scares. Something follows you, but it only catches you in the dark.

## Run / build
- `./build.sh` puts `src/*` together into one self-contained `index.html`. Three.js r170, GLTFLoader and the post-processing passes are bundled by esbuild into `build/vendor.min.js` and inlined, so the page makes no code requests.
- `textures/`, `models/` and `audio/` sit next to `index.html`. The game only requests files that exist. Voice clips load lazily when you are within about 8 m of a tape. Audio starts only after the first click, tap or key press, and loops are gapless (Web Audio buffer loops).
- To play locally, serve the folder with any static server (for example `python3 -m http.server`) and open `index.html`.
- GoatCounter: `GOATCOUNTER_CODE` is empty, so nothing is sent. Path `/echo-protocol`, event `echo-protocol-play`.

## Controls
| | Desktop | Touch |
|---|---|---|
| Move | WASD or arrows, mouse look (pointer lock) | left joystick, drag right half to look |
| Sprint / crouch | Shift / C | push the joystick all the way forward / CROUCH |
| Use, Listen [E] | E | ✋ USE |
| Torch | F | 🔦 |
| Camera 1st/3rd person | V | 👁 (saved) |
| Journal / pause / sound | J / Esc / M | 📓 / ⏸ |

**Device:** detection uses pointer:coarse, maxTouchPoints, a short side under 600 px, userAgentData.mobile, and iPads that report as a Mac. The result goes into `window.EP_DEVICE` and a `dev-*` body class. "Detected: X · Change" (Auto / Phone / Tablet / Computer) appears on the title and in pause. It is saved in `ep-device-override`. **Quality:** Low / Medium / High, Auto by default: phone Low, tablet Medium (or Low), desktop High. Software GPUs always get Low.

## Swapping the entity
Everything is in `src/data.js`, under the "THE ENTITY" heading:
```js
const ENTITY_MODEL = 'models/ep-entity-grinner.glb';          // default: Pixel's 'The Grinner'
const ENTITY_ALTERNATIVES = ['models/ep-entity-listener.glb'];   // the white Listener, a drop-in alternative
const ENTITY_NAME = 'The Grinner';   // name used in the journal + HUD captions
const ENTITY_HEIGHT = 2.1;           // metres; any model is normalised to this
const ENTITY_COLOR = 0xe8e6e0;       // only used if ENTITY_RECOLOR is true AND the model is the default Listener file
const ENTITY_GLOW = 0.6;             // faint emissive, full under 3 m, fading to 0 by 7 m
const ENTITY_RECOLOR = false;
```
1. Drop the GLB into `models/` and set `ENTITY_MODEL` to it. For the white Listener, use `'models/ep-entity-listener.glb'`. Set `ENTITY_NAME` too if the creature should be called something else.
2. The model is auto-normalised to `ENTITY_HEIGHT`. It is uniformly scaled, its lowest point sits on the floor, and it is centred on the AI position. Author it facing +Z, the same as the shipped entities.
3. Animation clips are matched by name. The match ignores case and accepts partial names and common synonyms:
   - `idle` ← idle / stand / breath / wait
   - `creep` ← creep / walk / sneak / stalk / move / crawl
   - `flee` ← flee / run / sprint / escape
   - `peek` ← peek / lean / look / spy
   - `recoil` ← recoil / flinch / hit / hurt / stagger / react

   A file with only one unnamed clip uses it as idle. A model with **no clips** still works: it gets a procedural glide, bob and lean.
4. Its own materials are kept. Recolouring only ever applies to the default Listener file, and only when `ENTITY_RECOLOR = true`.
5. Run `./build.sh`, then `node tests/features.mjs`. The "entity swap" test does this whole process with `tests/fixtures/odd-entity.glb`, a red box with no clips, 37 units tall and off-centre.

## Tests (Playwright + Chrome, SwiftShader WebGL)
`node tests/check-data.mjs`, `e2e.mjs`, `walkthrough.mjs` (the whole chapter, driven), `features.mjs`, `device.mjs`, `voice.mjs` and `perf.mjs`. Screenshots are saved in `screenshots/`.

## Credits
See `CREDITS.md`. Art requests are in `ART-NEEDED.md`.

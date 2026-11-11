# Echo Protocol sounds (original, PG: tense but never loud or sudden)
All mono mp3, 44.1 kHz. One-shots are under 1 s. Source: ../src/sfx3d.py

- ep-step-concrete-1..3, ep-step-metal-1..3, ep-step-puddle-1..3: footsteps. Pick one at random each step, pitch +/-5%.
- ep-flashlight-on / -off / -flicker: torch click, plus a low-battery buzz flicker.
- ep-keycard-pickup, ep-card-reader-accept, ep-card-reader-deny
- ep-door-open (heavy slide plus clunk), ep-door-locked (rattle), ep-drawer-open, ep-locker-open
- ep-tape-play, ep-tape-stop, ep-tape-hiss-loop (8 s loop, play quietly under the voice logs)
- ep-entity-creak-far, ep-entity-shuffle, ep-entity-flee: put these on a THREE.PositionalAudio on the entity, so players hear where it is.
- ep-facility-ambience-loop.mp3 (40 s, 469 KB): HVAC rumble, light hum, drips and far pipe groans. It replaces ep-ambient-loop.mp3 for the 3D version. Loop it with Web Audio (AudioBufferSourceNode loop = true) for no gap.

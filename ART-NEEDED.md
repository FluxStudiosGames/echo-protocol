# ART-NEEDED (for Pixel)
Nothing blocks the chapter. The game falls back to captions, with the tape hiss still playing, for these gaps:

1. **Three voice variants: "in the dark between the rooms".** These play when The Grinner is awake but not inside any room at the moment a line is built:
   - R5 line 6, Bea: `bea-r5-06-in-the-dark-between-the-rooms.mp3`
   - R7 line 8, Tomas: `tomas-r7-08-in-the-dark-between-the-rooms.mp3`
   - R9 line 5, Priya: `priya-r9-05-in-the-dark-between-the-rooms.mp3`

   Add them to `voice-manifest.json` under the `itWhere` key `"in the dark between the rooms"`, then run `tools/voice/sync-pixel.sh` and `./build.sh`. Check them with `node tools/voice/coverage.mjs`.
2. Optional: a Grinner-specific breath or giggle loop to replace the shared `ep-entity-*` sounds. Keep it soft and PG.
3. Optional: a share card or preview image for the itch/web page that shows The Grinner, since `ep-preview.png` shows the old 2D art.

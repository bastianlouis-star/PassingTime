# Passing Time (Godot 4.4)

An immortal, alone, with nothing but time.

**Play:** double-click `PassingTime.exe` (one folder up). Or open `godot/project.godot` in Godot 4.4+ and press F5.

**Layout of the repo:** `godot/` the game, `docs/` the progression graph and the project state, `tools/` graph generator, `build/` (not in git) the Windows export template and rcedit, `archive/web-prototype/` the original HTML prototype.

## Controls
| Key | Action |
|-----|--------|
| A / D or arrows | walk |
| W / S or arrows | choose an action |
| E / Space / Enter | do it |
| M | mute |
| F11 | toggle fullscreen (the game starts fullscreen) |
| Esc | leave (shows how long you've played for a few seconds, then closes) |
| R | begin again (after the ending) |

There is deliberately no fast-forward. Time-lapses play out in real time.

## How the first room works
- Walk up to something; its actions float above it. Locked actions stay hidden until you've earned them.
- Every repeatable activity follows the same arc: the first time shows a **NEW** window with a line of philosophy;
  after **2** uses an action appears to search for a note; after **3** a final action appears that exhausts
  the activity ("Read every book on the shelf", "Listen to every record in the box"...). Its message says it no longer
  interests him, and the activity stays on the menu, greyed, marked "not interesting anymore".
- There is no key. "Step outside" is always listed, but it only works once enough time has passed; before that: "The activities here can still pass time for a bit."
- The other eras still use discovery chains: find something -> it opens the next thing -> one exit per era.
- Narration appears as subtitles, first-time actions as a NEW message. There is no notes screen.
- Total real time played is saved, shown when you leave and again on the final screen (after the last atom stops moving).

## Debug mode (temporary)
`scripts/debug_tools.gd` is a self-contained module: **F1 / F2** previous / next era (grants everything
earlier eras gave), **F3** unlock everything in the current era, **F5** flags panel (every gate flag of the current
and earlier eras; Up/Down, Enter toggles, A all on, N all off), **F6** jump to the ending, **F4** hide the overlay.
To remove it for release, delete that one file; nothing else depends on it.

## Layout (HD-2D: a procedural 3D diorama with a pixel-art hero)
- `scripts/data.gd`      all content: hotspots, actions, flags, journal notes, hints
- `scripts/main.gd`      state, input, action loop, HUD (menu card, subtitles, clock, journal), save
- `scripts/world3d.gd`   camera, hero billboard, star dome and the current era's scene
- `scripts/scene_*.gd`   one 3D diorama per era (room, house, road, summit, observatory, plateau, space, nothing)
- `scripts/kit.gd` `sky.gd` `mk.gd` `tex.gd`   building blocks: sky/sun/moon, hills, trees, primitives, procedural pixel textures
- `scripts/hero3d.gd` `sprites.gd` `painter.gd`   the hero, painted procedurally at 80x160 (anti-aliased, lit; beard grows, hair greys); `tools/hero_sheet.gd` renders `docs/hero_sheet.png`
- `shaders/post.gdshader` tilt-shift blur, bloom, grade, vignette
- `scripts/txt.gd`       crisp vector HUD text
- `scripts/synth.gd`     generative music + sound effects, synthesised at runtime (no audio files)

## Checks (headless)
```
godot --headless --path godot --script tools/test_chain.gd     # every era's chain is solvable
godot --headless --path godot --script tools/playthrough.gd    # plays the real game to the ending
godot --headless --path godot --script tools/test_audio.gd     # sfx levels, music generator
godot --headless --path godot --script tools/test_debug.gd     # debug module
godot --headless --path godot --script tools/test_quit.gd      # leave flow (4 s farewell)
godot --headless --path godot --script tools/test_flow.gd      # first-room workflow (2nd/3rd use, exhaust, leaving)
godot --headless --path godot --script tools/test_walk.gd      # era 3: random walk duration, random discovery order
```
Screenshot hook for art work:
`godot --path godot -- "--shot=era:2;flags:seen_world;vis:paint;p:0.5;run:1;hot:easel;hx:188;out:C:\x.png"`

## Adding content
Add an `A(...)` action to a hotspot in `data.gd`; give it `req` flags, `give` flags, and add a
journal line to `NOTES`. Run `test_chain.gd` to confirm it's reachable.

## Progression graph
```
godot --headless --path godot --script tools/export_graph.gd   # dump real game data
python tools/make_graph.py                                      # -> docs/progression.svg
```

## Rebuild the exe (with the clock icon)
```
godot --headless --path godot --export-release "Windows Desktop" ../PassingTime.exe
```
(uses `build/templates/windows_release_x86_64.exe`, the official 4.4.1 template, and `build/tools/rcedit-x64.exe` to stamp `godot/icon.ico` into the exe; Godot's `export/windows/rcedit` editor setting must point at it. Redraw the icon with `tools/make_icon.gd`. Close the game first or the export can't overwrite the exe.)

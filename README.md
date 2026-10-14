# Passing Time

A short, quiet game about an immortal, alone, with nothing but time.

He starts in a small room: reading, a record, a video game, a chess board. Each pastime runs dry, and he has
to find longer ones. You never skip time, you spend it.

It is rendered HD-2D, in the Octopath Traveller manner: procedural 3D dioramas with a painted high-resolution
pixel hero, a tilt-shift and bloom post pass, and music and sound synthesised at runtime (there are no audio or
art asset files).

## Play

- Windows: build `PassingTime.exe` (see below), or run it from Godot.
- Godot: install **Godot 4.4.1** (standard build), open `godot/project.godot`, press F5.

| Key | Action |
|-----|--------|
| A / D or arrows | walk |
| W / S or arrows | choose an action |
| E / Space / Enter | do it |
| M | mute |
| F11 | fullscreen (the game starts fullscreen) |
| Esc | leave: shows your total real play time for four seconds, then closes |
| R | begin again after the ending |

Debug mode (delete `godot/scripts/debug_tools.gd` to remove it): F1/F2 era, F3 unlock era, F5 flag panel, F6 ending.

## The nine eras

1. The Room, 2. The House, 3. The Decades, 4. The Centuries, 5. The Millennia, 6. Deep Time, 7. Stars,
8. The Long Dark, 9. Nothing.

The whole discovery graph is in [docs/progression.png](docs/progression.png) (also `.svg`, regenerated from the
game data).

## Repo layout

| Path | What |
|------|------|
| `godot/` | the Godot 4.4 project (game code in `godot/scripts`, headless tests in `godot/tools`) |
| `docs/` | `PROJECT_STATE.md` (read this first when continuing), the progression graph, the hero sheet |
| `tools/make_graph.py` | renders `docs/progression.json` as `docs/progression.svg` |
| `archive/web-prototype/` | the original HTML/canvas prototype |

See [godot/README.md](godot/README.md) for the code layout and the headless checks, and
[docs/PROJECT_STATE.md](docs/PROJECT_STATE.md) for where the project stands, how it is built and what is next.

## Building the exe

`PassingTime.exe`, `build/` and the export template are not in git (the template is about 95 MB). Either:

1. In the Godot editor, install the 4.4.1 export templates and run Project > Export > "Windows Desktop", or
2. From a shell: `godot --headless --path godot --export-release "Windows Desktop" ../PassingTime.exe`.

`godot/export_presets.cfg` is committed. It embeds the icon via `rcedit`; if you do not have it, set
`application/modify_resources` to false in that preset (the exe still works, with the default icon).

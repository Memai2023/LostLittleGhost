# LostLittleGhost

A small ghost platformer. Godot 4 project — open this folder in Godot 4.3+ and press Play (F5).

**Controls:** A/D or Left/Right to move, Space/W/Up to jump (double jump in air, coyote time + jump buffering included). Touch a Soul Orb (violet) to go stealthy for 4s and pass through hazards.

**Goal:** cross the graveyard → forest/city → and reach the glowing window before the sun timer (top-left) runs out. Avoid the patrolling flashlight hunters — 3 hearts (top-right), each hit knocks you back and costs one. Falling off the level also costs a heart and respawns you.

## Status — all 3 days scaffolded

- **Day 1 — Vibe & movement:** dark background + bloom, floaty accel/friction movement, coyote time, jump buffering, double jump, squish/stretch, PointLight2D ghost glow, greybox graveyard zone with 3 Spirit Orbs.
- **Day 2 — Mechanics & progression:** sunlight timer that lerps the whole scene's tint from night to sunrise (`DayNightCycle.gd`, on the `CanvasModulate` node — tune `run_duration`/colors in the Inspector), hurt/knockback + 3 lives, patrolling `FlashlightHunter` enemies, a `SoulOrb` possess/stealth power-up, and a second (forest/city) + third (final jump) zone continuing the level to the right.
- **Day 3 — Polish & ship:** 3-layer parallax background (moon/trees/houses, auto-tiling via `motion_mirroring`), a `WindowTrigger` win condition with fade-to-black + message, a matching "sun caught you" lose state, and procedurally generated SFX (`SoundGen.gd`, an autoload — jump woosh, orb chime, hurt buzz; no external audio files needed, so there's nothing to license).

## Still needs you (things that need the actual editor/ears/eyes, not text edits)

- **Background music:** there's no ambient loop — drop an audio file into an `AudioStreamPlayer` yourself (procedural synthesis isn't a good fit for a music bed).
- **Real art:** everything is placeholder polygons/gradients ("good enough" per the plan) — swap in a sprite pack (e.g. from itch.io) whenever you want.
- **Playtesting & tuning:** jump height, timer length, hazard placement — all `@export`ed on the relevant nodes, tune by feel in the editor.
- **HTML5/WebGL export:** Project → Export in the editor (needs the Web export templates, downloadable from inside Godot) — not something to hand-write outside the editor.

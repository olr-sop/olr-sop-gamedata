# Design

## Context

See `proposal.md` - Why. The current implementation lives in `Cwound_manager:process_timers()` in `gamedata/scripts/xr_wounded.script`. It already stores a per-wound timer set in the NPC `pstor`: `wounded_since`, `wounded_self_heal_at`, `wounded_death_at`, `wounded_hp0`, `wounded_last_drain_sec` and `wounded_sos_done`. The SOS block runs on the first wounded tick, while self-healing waits for `wounded_self_heal_at` (currently 5-40 game minutes).

Constraints that shape the approach:

- `game.time_sec()` returns game time; `config/alife.ltx` sets `time_factor = 10`, so 1 real second equals 10 game seconds.
- `xr_logic.pstor_load_all()` caps non-actor pstor at 20 entries and the writer stores every entry, so adding keys is risky. The wounded scheme already owns 10 keys.
- `ini_sys` is cached at boot; config edits need a game restart.
- OLR has only one medkit item, `medkit` (user-confirmed); `medkit_army` / `medkit_scientic` do not exist.

## Goals / Non-Goals

**Goals:**

- One random decision deadline per wound, 5-10 game minutes by default, configurable.
- Before the deadline: no self-heal unlock, no SOS SMS, no `map_sos` marker.
- At the deadline: self-heal if `use_medkit` and a `medkit` are present, otherwise SOS once.
- Keep the existing death ladder (drain from the wound moment, death at 2 game hours).
- Preserve save/load behavior without adding a pstor key.

**Non-Goals:**

- Changing the death timer, the health drain rate or the wounded animation/sound states.
- Changing story/protected NPC handling.
- New medkit types, new notifications, or UI changes.
- Reworking the 20-entry pstor load cap.

## Decisions

1. **Reuse `wounded_self_heal_at` as the decision deadline.** The key already exists and is cleared with the other timers. Adding `wounded_decision_at` would grow the pstor of every wounded NPC, risking the 20-entry load truncation. The value is now written as `since + random(min_sec, max_sec)`; the name is kept for save compatibility and documented in a comment.
2. **Config in game minutes.** `[xr_wounded]` gets `decision_delay_min_minutes` (default 5) and `decision_delay_max_minutes` (default 10). `load_settings()` converts them to seconds once, clamps the minimum to 0 and forces `max >= min`. Missing or invalid values keep the defaults. Seconds would be less readable for a designer-facing value.
3. **One gate for both outcomes.** In `process_timers()`, the self-heal unlock and the SOS block are both evaluated only after `now_sec >= decision_at`. They are mutually exclusive per tick: self-heal wins when possible; otherwise the one-shot SOS guard (`wounded_sos_done`) fires. The earlier code sent the SOS unconditionally and separately from the heal check.
4. **Death drain stays outside the gate.** The drain block keeps running whenever the NPC cannot self-heal, exactly as today, so the 2-game-hour deadline still starts at the wound moment.
5. **Only the plain `medkit`.** Self-heal capability is `use_medkit == true and npc:object("medkit") ~= nil`. Army/scientific branches in `eat_medkit()` are left untouched (dead code) but no longer influence the decision.
6. **Old-save normalization.** If a loaded NPC has a `wounded_self_heal_at` later than `since + max_sec` (an old 5-40 minute value), the timer is rewritten to a fresh random deadline inside the configured range. This makes old saves use the new behavior instead of waiting up to 40 minutes.
7. **Delete `zz_test.script`.** The temporary wounded test helper is not part of the product and is removed instead of being updated.

## Risks / Trade-offs

- **Timing is shorter than it sounds** → 5-10 *game* minutes is 30-60 real seconds at `time_factor = 10`; the config comment states this so designers do not misread it.
- **Self-heal becomes common** → an NPC with a medkit now recovers after 5-10 game minutes instead of 5-40. This is the requested behavior; the config range is the tuning knob.
- **Old saves may fire the decision immediately** → normalization preserves the same mapping (`since + random`), and a long-past `since` correctly means "the decision is due".
- **pstor cap** → reusing the existing key means no new entries; the pre-existing 20-entry limitation is unchanged.
- **Config is cached at boot** → the `[xr_wounded]` comment explicitly says changes require a restart.

## Migration Plan

1. Update `gamedata/scripts/xr_wounded.script` and `gamedata/config/olr_script_configs.ltx`.
2. Delete `gamedata/scripts/zz_test.script`.
3. Old saves need no data migration: the first wounded tick after load normalizes the deadline and the existing `wounded_sos_done` guard prevents duplicate messages.
4. Rollback: revert the two edited files and restore `zz_test.script` from git; no save data is written outside the existing pstor keys.

## Encoding

- Source and target encodings are Windows-1251 for `xr_wounded.script` and `olr_script_configs.ltx`; new comments are kept ASCII where possible.
- Writes go through `pwsh OLR/tools/encoding/enc.ps1 write <target> -FromPath <utf8-temp>`, then `pwsh OLR/tools/encoding/enc.ps1 detect <target>` on both touched files.
- `zz_test.script` is ASCII and is deleted with `Remove-Item`.

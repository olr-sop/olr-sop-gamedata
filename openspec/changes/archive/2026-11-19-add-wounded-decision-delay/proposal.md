# Proposal

## Why

A wounded NPC currently sends the SOS SMS and sets the `map_sos` marker on the very first wound tick, even when the NPC is about to treat itself with a medkit. The player gets notified about every wound immediately, and the actual treatment decision happens much later (random 5-40 game minutes). This makes the notification noisy and the wounded behavior feel inconsistent.

## What Changes

- Add a per-NPC random decision delay before the wounded scheme either self-heals or calls for help.
- Delay range is configured in `config/olr_script_configs.ltx`, section `[xr_wounded]`, in game minutes: `decision_delay_min_minutes = 5`, `decision_delay_max_minutes = 10`.
- While the delay is running: no self-heal, no SOS SMS, no `map_sos` marker.
- When the delay expires:
  - if the NPC has `use_medkit` enabled and a `medkit` item, it self-heals (no SMS, no marker);
  - otherwise it sends the SOS SMS and adds the `map_sos` marker once per wound (enemy NPCs still skip the message).
- The death countdown is unchanged: health drain and the 2-game-hour death deadline still start at the wound moment.
- Story and `olr_protected` NPCs keep the current behavior (no timer-driven self-heal, no SOS, no timer death).
- Remove the temporary `gamedata/scripts/zz_test.script` test helper.

## Capabilities

### New Capabilities

- `wounded-scheme`: autonomous behavior of a wounded stalker: delayed heal-or-SOS decision, medkit self-treatment, SOS notification and map marker, death timer, and exceptions for story/protected NPCs.

### Modified Capabilities

<!-- No existing capability requirements change. -->

## Impact

- `gamedata/scripts/xr_wounded.script` (CP1251) - timer logic in `Cwound_manager:process_timers()`.
- `gamedata/config/olr_script_configs.ltx` (CP1251) - new `[xr_wounded]` keys and updated comment.
- `gamedata/scripts/zz_test.script` (ASCII) - deleted.
- No engine, Lua API, spawn or asset changes.
- Save compatibility: the existing `wounded_self_heal_at` pstor key is reused as the decision deadline, so no new pstor key is introduced (the 20-entry pstor load cap stays untouched).
- Encoding impact: gamedata scripts and config are Windows-1251; edits are written through `tools/encoding/enc.ps1` and verified with `detect`.

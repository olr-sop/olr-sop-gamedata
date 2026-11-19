# Tasks

## 1. Wounded script logic

- [x] 1.1 Add config-backed decision delay values in `gamedata/scripts/xr_wounded.script` (`load_settings`: read `decision_delay_min_minutes` / `decision_delay_max_minutes`, default 5/10, convert to seconds, clamp `max >= min`); verify by reading `load_settings()` and checking the computed values never go negative or inverted.
- [x] 1.2 In `Cwound_manager:process_timers()` write the random per-wound deadline into the existing `wounded_self_heal_at` pstor key and normalize old values later than `since + max_sec`; verify by reading the timer init block and confirming no new pstor key is introduced.
- [x] 1.3 Gate the self-heal unlock and the SOS block behind `now_sec >= decision_at`: self-heal only when `use_medkit` is true and `npc:object("medkit")` exists, otherwise send one SMS plus `map_sos`; verify by reading the branch and confirming no SMS/marker path exists before the deadline.
- [x] 1.4 Keep the health drain and death deadline outside the delay gate and anchored to `wounded_since`; verify with `git -C OLR diff -- gamedata/scripts/xr_wounded.script` that the drain condition and the 2-hour deadline are unchanged.
- [x] 1.5 Update `dbg` logging for the deadline, the self-heal decision and the SOS decision; verify the log strings compile by reading the changed lines and checking all format arguments match.

## 2. Config

- [x] 2.1 Add `decision_delay_min_minutes = 5` and `decision_delay_max_minutes = 10` to `[xr_wounded]` in `gamedata/config/olr_script_configs.ltx` and update the timing comment; verify with `pwsh OLR/tools/encoding/enc.ps1 read OLR/gamedata/config/olr_script_configs.ltx -Lines 180` that the section reads correctly in CP1251.

## 3. Cleanup

- [x] 3.1 Delete `gamedata/scripts/zz_test.script`; verify the file is absent and `rg "zz_test" OLR/gamedata` returns no matches.

## 4. Encoding

- [x] 4.1 Run `pwsh OLR/tools/encoding/enc.ps1 detect` on `gamedata/scripts/xr_wounded.script` and `gamedata/config/olr_script_configs.ltx`; both must report `ok` with no BOM and no conversion needed.

## 5. Verification

- [x] 5.1 The user runs `luac -p gamedata/scripts/xr_wounded.script` (user-owned by default; the agent runs it only on explicit request) and reports a clean parse.
- [x] 5.2 The user verifies in game: wound an NPC that carries a medkit and confirm no SMS/marker during the delay, then self-treatment; wound an NPC without a medkit and confirm exactly one SMS plus marker after the delay; save/load while waiting and confirm the deadline is preserved.
- [x] 5.3 Run `openspec validate add-wounded-decision-delay --strict` and confirm the change is valid.

## Workflow follow-up

- Archive the change after the user confirms in-game verification.

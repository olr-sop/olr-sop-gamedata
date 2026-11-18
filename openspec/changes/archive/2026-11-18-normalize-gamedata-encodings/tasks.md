# normalize-gamedata-encodings: Tasks

## 1. Baseline and safety

- [x] 1.1. Generate `tools/encoding/BASELINE.md` with `enc.ps1 scan gamedata`.
- [x] 1.2. Confirm `convert` refuses damaged files and that `restore` preserves current LTX values.
- [x] 1.3. File backups taken to `%TEMP%\olr-enc-backup\` during every write.

## 2. Convert mismatched files

- [x] 2.1. Convert non-English UTF-8 and Windows-1252 gamedata text to CP1251.
- [x] 2.2. Convert the 3 CP1251 shader headers to UTF-8.
- [x] 2.3. Convert all `config/text/eng/*.xml` to UTF-8.
- [x] 2.4. Run `enc.ps1 fix-xml gamedata -Write` so every declaration matches its bytes (363 XML, 0 mismatches).
- [x] 2.5. Verify `scan` reports zero `convert-to-*` actions.

## 3. Restore lost LTX text

- [x] 3.1. `config/creatures/m_stalker.ltx` from `6c83dea0f^` with two final manual comments.
- [x] 3.2. `config/creatures/m_fracture.ltx` from `6c83dea0f^` with one final manual comment.
- [x] 3.3. `config/creatures/m_chimera.ltx` from `6c83dea0f^`.
- [x] 3.4. `config/creatures/m_zombie.ltx` from `6c83dea0f^`.
- [x] 3.5. `config/creatures/m_bloodsucker.ltx` from `6c83dea0f^`.
- [x] 3.6. `config/creatures/m_flesh.ltx` from `6c83dea0f^`.
- [x] 3.7. `config/weapons/w_l85.ltx` from `6c83dea0f^` with two final manual comments.
- [x] 3.8. `config/misc/quest_items.ltx` reconstructed from known comments (`;иммунитеты артефактов`, `;степень поглощения (иммунитет)`).

## 4. Manual repairs

- [x] 4.1. `config/weapons/w_hands_gravity.ltx` restored from `6c83dea0f^`.
- [x] 4.2. `config/gameplay/npc_simulation/character_desc_simulation.xml` comments restored (`Журналист`, `Мертвецы`).
- [x] 4.3. `shaders/r1a/shared/waterconfig.h` comments restored from `gmdata_rc5`.
- [x] 4.4. `config/models/objects/special/vent_destroy.ltx` mojibake reversed to Russian and converted to CP1251.
- [x] 4.5. `config/weapons/ammo/ammo.ltx` 75 mojibake comment lines reversed to Russian.
- [x] 4.6. `stable_items_quest.xml`, `ui_st_others.xml`, `pda_notepad_2.xml`: `¹` -> `№`, `ñ` -> `c`, then CP1251.

## 5. Verification

- [x] 5.1. Run `enc.ps1 scan gamedata`: 5492 ok, 7 review, 0 damaged, 0 convert, 0 mojibake.
- [x] 5.2. Spot-check recovered comments against values in game-relevant sections.
- [x] 5.3. Re-indexed the gamedata graph: 172,913 nodes / 195,876 edges, `ready`.
- [x] 5.4. User verified UI strings and creature configs in game.
- [x] 5.5. Archive the change and refresh `tools/encoding/BASELINE.md`.

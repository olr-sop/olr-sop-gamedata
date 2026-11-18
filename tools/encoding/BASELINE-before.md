# Encoding baseline

Generated: 2026-11-18 21:27 by `tools/encoding/enc.ps1 scan gamedata`.

This snapshot records the state before normalization. Re-generate it after every encoding change.

```text
Encoding scan: Q:/OLRDev/OLR/gamedata
Total text files: 5502

By encoding:
  ascii        4887
  cp1251        499
  utf8           89
  cp1252         15
  utf8-bom       10
  empty           2

By extension:
  .h       total=39    utf8=13    cp1251=3     ascii=23    damaged=1
  .ini     total=215   utf8=0     cp1251=1     ascii=214   damaged=0
  .ltx     total=3897  utf8=29    cp1251=127   ascii=3741  damaged=9
  .ps      total=193   utf8=18    cp1251=0     ascii=175   damaged=0
  .s       total=143   utf8=0     cp1251=0     ascii=143   damaged=0
  .script  total=334   utf8=11    cp1251=245   ascii=78    damaged=0
  .vs      total=215   utf8=4     cp1251=0     ascii=211   damaged=0
  .xml     total=466   utf8=24    cp1251=123   ascii=302   damaged=1

Actions:
  ok                   5409
  convert-to-cp1251    69
  damaged              11
  review               7
  convert-to-utf8      3
  skip                 2
  mojibake             1

Damaged files (U+FFFD lost text):
    2728 lost  utf8      gamedata/config/creatures/m_stalker.ltx
    1347 lost  utf8      gamedata/config/creatures/m_fracture.ltx
    1325 lost  utf8      gamedata/config/creatures/m_chimera.ltx
    1311 lost  utf8      gamedata/config/creatures/m_zombie.ltx
    1178 lost  utf8      gamedata/config/creatures/m_bloodsucker.ltx
    1156 lost  utf8      gamedata/config/creatures/m_flesh.ltx
     549 lost  utf8      gamedata/config/weapons/w_hands_gravity.ltx
     366 lost  utf8      gamedata/config/weapons/w_l85.ltx
     210 lost  utf8      gamedata/config/misc/quest_items.ltx
      36 lost  utf8      gamedata/shaders/r1a/shared/waterconfig.h
      17 lost  utf8      gamedata/config/gameplay/npc_simulation/character_desc_simulation.xml

Policy mismatches (convert):
  utf8       -> cp1251   gamedata/config/creatures/m_karlik.ltx
  utf8       -> cp1251   gamedata/config/debug/my_dbg.ltx
  utf8       -> cp1251   gamedata/config/debug/ui_spawn_menu.ltx
  utf8-bom   -> cp1251   gamedata/config/gameplay/npc_profile.xml
  utf8       -> cp1251   gamedata/config/gameplay/infoportions/info_stories.xml
  utf8       -> cp1251   gamedata/config/gameplay/npc_levels/character_desc_deadcity.xml
  utf8       -> cp1251   gamedata/config/misc/devices.ltx
  utf8       -> cp1251   gamedata/config/misc/olr_sound_events.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_acid_fog.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_black_needle.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_burningfuzz.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_dead.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_fryup.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_kampfire.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_mincer.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_minefield.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_mosquitobald.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_radioactive.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_rustyhair.ltx
  utf8       -> cp1251   gamedata/config/misc/zone_witches_galantine.ltx
  utf8       -> cp1251   gamedata/config/models/objects/special/bottle_destroy.ltx
  utf8       -> cp1251   gamedata/config/models/objects/special/vent_destroy.ltx
  cp1252     -> cp1251   gamedata/config/text/eng/st_tasks_darkvalley.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialog_manager.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialogs_bar.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialogs_croweye.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialogs_escape.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialogs_garbage.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_dialogs_lonewolf.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_items_quest.xml
  cp1252     -> cp1251   gamedata/config/text/eng/stable_items_weapons.xml
  cp1252     -> cp1251   gamedata/config/text/eng/string_table_mydiary.xml
  cp1252     -> cp1251   gamedata/config/text/eng/string_table_news_manager.xml
  cp1252     -> cp1251   gamedata/config/text/eng/string_table_tutorial.xml
  cp1252     -> cp1251   gamedata/config/text/eng/ui_st_about_level.xml
  cp1252     -> cp1251   gamedata/config/text/eng/ui_st_others.xml
  utf8       -> cp1251   gamedata/config/ui/carbody_item.xml
  utf8       -> cp1251   gamedata/config/ui/game_tutorials.xml
  utf8-bom   -> cp1251   gamedata/config/ui/ingame_msglog_mp.xml
  utf8-bom   -> cp1251   gamedata/config/ui/ingame_msglog_sp.xml
  utf8       -> cp1251   gamedata/config/ui/inventory_item.xml
  utf8       -> cp1251   gamedata/config/ui/inventory_new.xml
  utf8-bom   -> cp1251   gamedata/config/ui/jobs_new.xml
  utf8-bom   -> cp1251   gamedata/config/ui/jobs.xml
  utf8-bom   -> cp1251   gamedata/config/ui/maingame_character.xml
  utf8-bom   -> cp1251   gamedata/config/ui/map_character.xml
  utf8-bom   -> cp1251   gamedata/config/ui/pda_new.xml
  utf8-bom   -> cp1251   gamedata/config/ui/sleep_dialog.xml
  utf8       -> cp1251   gamedata/config/ui/trade_item.xml
  utf8       -> cp1251   gamedata/config/ui/ui_credits.xml
  utf8-bom   -> cp1251   gamedata/config/ui/ui_mm_lang_select.xml
  utf8       -> cp1251   gamedata/config/ui/hud_type_1/zone_map_1.xml
  utf8       -> cp1251   gamedata/config/ui/hud_type_2/zone_map_2.xml
  utf8       -> cp1251   gamedata/config/ui/hud_type_3/zone_map_3.xml
  utf8       -> cp1251   gamedata/config/ui/pda_type_1/pda_diary_1.xml
  utf8       -> cp1251   gamedata/config/ui/pda_type_1/pda_events_1.xml
  cp1252     -> cp1251   gamedata/config/ui/pda_type_2/pda_notepad_2.xml
  utf8       -> cp1251   gamedata/config/weapons/ammo/ammo_rockets.ltx
  utf8       -> cp1251   gamedata/scripts/core.script
  utf8       -> cp1251   gamedata/scripts/ogse_mental_fix.script
  utf8       -> cp1251   gamedata/scripts/olr_ai_trade_agree.script
  utf8       -> cp1251   gamedata/scripts/olr_corpses.script
  utf8       -> cp1251   gamedata/scripts/olr_debug.script
  utf8       -> cp1251   gamedata/scripts/olr_military_snd.script
  utf8       -> cp1251   gamedata/scripts/olr_npc_jobs.script
  utf8       -> cp1251   gamedata/scripts/olr_trade_manager.script
  utf8       -> cp1251   gamedata/scripts/state_mgr_animation_list.script
  utf8       -> cp1251   gamedata/scripts/ui_main_menu.script
  utf8       -> cp1251   gamedata/scripts/xrs_trade.script
  cp1251     -> utf8     gamedata/shaders/r1/shared/waterconfig.h
  cp1251     -> utf8     gamedata/shaders/r2/shared/waterconfig.h
  cp1251     -> utf8     gamedata/shaders/shared/waterconfig.h

Needs review (mojibake or ???):
  review               gamedata/config/defines.ltx
  review               gamedata/config/text/rus/stable_dialog_manager.xml
  review               gamedata/config/text/rus/stable_dialogs_croweye.xml
  mojibake             gamedata/config/weapons/ammo/ammo.ltx
  review               gamedata/scripts/_g.script
  review               gamedata/scripts/bind_artefacts.script
  review               gamedata/scripts/m_netpk.script
  review               gamedata/shaders/r2/common_iostructs.h
```

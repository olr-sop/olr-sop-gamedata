# Encoding baseline

Generated: 2026-11-18 23:30 after normalization.

Current policy: CP1251 for gamedata except `shaders/**` and `config/text/eng/**` (UTF-8).
The pre-normalization audit is kept in `BASELINE-before.md`.

```text
Encoding scan: Q:/OLRDev/OLR/gamedata
Total text files: 5502

By encoding:
  ascii        4897
  cp1251        547
  utf8           56
  empty           2

By extension:
  .h       total=39    utf8=16    cp1251=0     ascii=23    damaged=0
  .ini     total=215   utf8=0     cp1251=1     ascii=214   damaged=0
  .ltx     total=3897  utf8=0     cp1251=156   ascii=3741  damaged=0
  .ps      total=193   utf8=18    cp1251=0     ascii=175   damaged=0
  .s       total=143   utf8=0     cp1251=0     ascii=143   damaged=0
  .script  total=334   utf8=0     cp1251=256   ascii=78    damaged=0
  .vs      total=215   utf8=4     cp1251=0     ascii=211   damaged=0
  .xml     total=466   utf8=18    cp1251=134   ascii=312   damaged=0

Actions:
  ok                   5493
  review               7
  skip                 2

Damaged files (U+FFFD lost text):
  none

Policy mismatches (convert):
  none

Needs review (mojibake or ???):
  review               gamedata/config/defines.ltx
  review               gamedata/config/text/rus/stable_dialog_manager.xml
  review               gamedata/config/text/rus/stable_dialogs_croweye.xml
  review               gamedata/scripts/_g.script
  review               gamedata/scripts/bind_artefacts.script
  review               gamedata/scripts/m_netpk.script
  review               gamedata/shaders/r2/common_iostructs.h
```

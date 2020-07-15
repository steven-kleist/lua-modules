[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/stevenkl/lua-modules)

# lua-modules
Dieses Git-Repository enthält eine Sammlung von nützlichen Lua Modulen, welche ohne weitere Kompilierung genutzt werden können.



[TOC]


## Voraussetzung für Module
Wenn du ein Modul hinzu fügen willst musst folgendes beachten:
* Jedes Modul MUSS ohne nativen C-Code laufen
* Dein Modul MUSS die Plattform beachten (LuaScript, LuaJit)
  * Wenn das Modul für mehrere Plattformen gedacht ist MUSS es alternative Implementierungen der Funktionen geben.
* Wenn dein Modul NUR eine bestimmte Plattform gedacht ist, breche die Initialisierung mit einem `error()` ab.


## utils.lua
Das Skript `utils.lua` dient zur validierung der einzelnen Module. Folgende Funktionen sind enthalten:
* `utils.lua test` - Sucht nach `<module_name>_test.lua` und führt die gefundenen Dateien mit `dofile()` aus


## Liste der aktuellen Module
* argparse
* cron
* crypto
  * md5
  * [sha1](./crypto/sha1/README.md)
* etlua
* fs
* inspect
* json
* log
* markdown
* platform
* router
* semver
* [simple_test](./simple_test/README.md)
* strong
* web
  * app
  * request
  * response

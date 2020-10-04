[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/stevenkl/lua-modules)

# lua-modules
Dieses Git-Repository enthält eine Sammlung von nützlichen Lua Modulen, welche ohne weitere Kompilierung genutzt werden können.


[TOC]


## Lua Implementierungen
Aktuell stehen folgende Lua Implementierungen im Focus:
* PUC Lua 5.1-5.3
* LuaJit v.2.0.9 (Native, Lua 5.1)
* LuaScript (Windows Scripting Host, LuaJit 2.0.9)
* LuaScript (Notepad++, Lua 5.3)
* LuaJ v.3.0.1 (JVM, Lua 5.2)


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
* dotenv
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

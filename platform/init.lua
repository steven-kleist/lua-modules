local platform = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "Module with various methods for platform detection",
  _LICENSE = [[]],
}

platform.isWindows = package.config:sub(1, 1) == "\\" and true or false
platform.isUnix    = package.config:sub(1, 1) == "/" and true or false
platform.sep       = package.config:sub(1, 1)
platform.dirsep    = package.config:sub(3, 3)


platform.engine    = {
  host    = "native",
  name    = "lua",
  version = "5.1",
}

if _G.jit then
  platform.engine.host = "native"
  platform.engine.name = "luajit"
end
if platform.isWindows and _G.WScript then
  platform.engine.host = "wsh"
  platform.engine.name = "luascript"
  platform.engine.version = "5.1"
end
if platform.isWindows and _G.npp and _G.winfile then
  platform.engine.host = "notepad++"
  platform.engine.name = "luascript"
  platform.engine.version = "5.3"
end


return platform
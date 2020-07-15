local platform = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "Module with various methods for platform detection",
  _LICENSE = [[]],
}

platform.isWindows = package.config:sub(1, 1) == "\\" and true or false
platform.isUnix    = package.config:sub(1, 1) == "/" and true or false
platform.sep       = package.config:sub(1, 1)

platform.engine    = {
  name    = "lua",
  version = "51",
}

if _G.jit then
  platform.engine.name = "luajit"
end
if platform.isWindows and _G.WScript then
  platform.engine.name = "luascript"
end

return platform
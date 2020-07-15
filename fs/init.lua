local fs = {
  _VERSION    = "0.0.1",
  _DESCRIPTION = "Simple filesystem module for Lua and LuaScript (Windows).",
  _LICENSE     = [[
    MIT LICENSE

    * Copyright (c) 2020 Steven Kleist

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
}


require "strong"
local platform = require "platform"



-- Detecting platform and runtime
local isWindows = platform.isWindows
local sep = platform.sep
local isLuaScript = platform.engine.host == "wsh" and true or false

local obj = {}
if isLuaScript then
  obj.fso = luacom.CreateObject("Scripting.FileSystemObject")
  obj.shell = luacom.CreateObject("WScript.Shell")
end


-------------------------------------------------------------------------------
-- Static methods
-------------------------------------------------------------------------------

-- Returns a table with attributes
function fs.attributes(path, request_type)
  if type(request_type) == "string" then
    
    -- Check for mode (file, directory)
    if request_type == "mode" then
      
      if fs.exist(path) then
        
        if fs.isdir(path) then
          return "directory"
        else
          return "file"
        end
        
      end
      return nil, [["%s" not found.]] % path
      
    end
    
    -- Use COM-Objects
    if isLuaScript then
      
      -- Check for lastModified
      if request_type == "modification" then
        local item = nil
        if fs.isdir(path) then
          item = obj.fso:GetFolder(path)
        else
          item = obj.fso:GetFile(path)
        end
        return item.DateLastModified
      end
      
      -- Check for last Accessed
      if request_type == "access" then
        local item = nil
        if fs.isdir(path) then
          item = obj.fso:GetFolder(path)
        else
          item = obj.fso:GetFile(path)
        end
        return item.DateLastAccessed
      end
      
    end
    
    
    return nil, [[requested attribute "%s" is not supported.]] % request_type
  end
end


function fs.chdir(path)
  if isWindows then
    if isLuaScript then
      if obj.fso.FolderExists(path) then
        obj.shell.CurrentDirectory = path
      end
    end
    
    return nil
  end
end

function fs.lock_dir(path) end


-- Returns the current workinf directory
function fs.currentdir()
  if isWindows then
    if isLuaScript then
      return obj.shell.CurrentDirectory
    else
      local cwd = io.popen([[@echo/%CD%]]):read("*all"):gsub("%s+$", "")
      return cwd
    end
  end
end

function fs.dir(path, recursive)
  local recurse = recursive and "/S" or ""
  local result = {}
  if isWindows then
    local cmd = '@dir /B %s "%s"' % {recurse, path}
    local entries = io.popen(cmd):read("*a") - "%s+$"
    for i,v in ipairs(entries:lines(true)) do
      if #v >= 1 then table.insert(result, v) end
    end
    return result
  end
end

function fs.lock() end

function fs.link() end

function fs.mkdir(path)
  local success = false
  if isWindows then
    if isLuaScript then
      local code = os.execute([[cmd /c @mkdir "%s"]] % path)
      if code == 0 then success = true end
    else
      local ok, t, code = os.execute([[cmd /c @mkdir "%s"]] % path)
      if ok and code == 0 then success = true end
    end
  end
  
  return success
end

function fs.rmdir(path)
  local success = false
  if isWindows then
    if isLuaScript then
      local code = os.execute([[cmd /c @rmdir /S /Q "%s"]] % path)
      if code == 0 then success = true end
    else
      local ok, t, code = os.execute([[cmd /c @rmdir /S /Q "%s"]] % path)
      if ok and code == 0 then success = true end
    end
  end
  
  return success
end

function fs.setmode() end

function fs.symlinkattributes() end

function fs.touch(path)
  if isWindows then
    local file = io.open(path)
    if file then
      file:close()
      local result = io.popen([[@copy /b "%s"+,, "%s"]] % {path, path})
      result:close()
      
    else
      local file = assert(io.open(path, "a"))
      file:write("")
      file:flush()
      file:close()
    end
  end
end

function fs.unlock() end

--- Finds executable in %PATH%
function fs.find(name)
  if isWindows then
    local result = io.popen([[@where %s]] % name):read("*a") - "%s+$"
    return result:lines(true)
  end
end

---
-- @scope module {fs}
-- @desc Returns the basepath of {file}
-- @params {file:string} File or folder path to get basepath from
-- @returns {string|nil} The basepath or nil on error.
--
function fs.basepath(file)
  local match = string.match(file, "^(.*)%s.*$" % sep, 1)
  return match
end


function fs.exist(path)
  if isWindows then
    local cmd = '@if exist "%s" (@echo/true) else (@echo/false)' % path
    local result = io.popen(cmd):read("*l")
    return result == "true" and true or false
  end
  return nil
end


function fs.tryopen(path)
  local res = io.open(path, "rb")
  if res ~= nil then res:close() end
  return res and true or false
end


function fs.isdir(path)
  local exists = fs.exist(path)
  if exists then
    if fs.tryopen(path) then
      return false
    else
      return true
    end
  end
  return false
end


-------------------------------------------------------------------------------
-- Returning insatnce
-------------------------------------------------------------------------------
return fs
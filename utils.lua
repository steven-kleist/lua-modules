-- utils.lua


-- Get all test files
local fs = require "fs"
local inspect = require "inspect"

local files = fs.dir("web", true)

print(('Found %d items.'):format(#files))
print(inspect(files))

print(fs.isdir(".\\web\\request"))

for i,v in ipairs(files) do
  print(inspect(fs.basepath(v)))
end


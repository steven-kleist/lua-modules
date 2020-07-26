-- utils.lua


-- Get all test files
local fs = require "fs"

local items = fs.dir(".")

for i,v in ipairs(items) do
  
  if fs.isdir(v) then
    
    local file = ([[.\%s\%s_test.lua]]):format(v, v)
    if fs.exist(file) then
      
      print(file, fs.attributes(file, "modification"))
      
      dofile(file)
    end
    
  end
end


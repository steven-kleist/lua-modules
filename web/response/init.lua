local response = {
  _VERSION = "0.0.1",
  _DESCRIPTION = "",
  _LICENSE = [[]],
}

-------------------------------------------------------------------------------
-- member functions
-------------------------------------------------------------------------------
function response:send(content) end


function response:status(status)
  status = type(status) == "number" and status or tonumber(status)
  if not status then
    return error("[response:status] {status} not convertable to number!")
  end
  
end


function response:json(content) end




-------------------------------------------------------------------------------
-- Return module
-------------------------------------------------------------------------------
return response
local test = require "simple_test"
local platform = require "platform"

test('platform.engine.version == "51"', function(t)
    t.ok(platform.engine.version == "51", "passed!")
end)
---
--  https://github.com/nrk/hige
--
--
--

local hige = {
    _VERSION    = "0.0.1",
    _DESCRIPTION = "Template library like for Lua and LuaScript (Windows).",
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



local tags = { open = '{{', close = '}}' }
local r = {}

local function merge_environment(...)
    local numargs, out = select('#', ...), {}
    for i = 1, numargs do
        local t = select(i, ...)
        if type(t) == 'table' then
            for k, v in pairs(t) do 
                if (type(v) == 'function') then
                    out[k] = setfenv(v, setmetatable(out, { 
                        __index = getmetatable(getfenv()).__index 
                    }))
                else
                    out[k] = v 
                end
            end
        end
    end
    return out
end

local function escape(str)
    return str:gsub('[&"<>\]', function(c) 
        if c == '&' then return '&amp;'
        elseif c == '"' then return '\"'
        elseif c == '\\' then return '\\\\'
        elseif c == '<' then return '&lt;'
        elseif c == '>' then return '&gt;'
        else return c end
    end)
end

local function find(name, context)
    local value = context[name]
    if value == nil then 
        return ''
    elseif type(value) == 'function' then 
        return merge_environment(context, value)[name]()
    else 
        return value
    end
end

local operators = {
    -- comments 
    ['!'] = function(state, outer, name, context) 
        return state.tag_open .. '!' .. outer .. state.tag_close
    end, 
    -- the triple hige is unescaped
    ['{'] = function(state, outer, name, context) 
        return find(name, context) 
    end, 
    -- render partial
    ['<'] = function(state, outer, name, context) 
        return r.partial(state, name, context)
    end, 
    -- set new delimiters
    ['='] = function(state, outer, name, context)
        -- FIXME!
        error('setting new delimiters in the template is currently broken')
        --[[
        return name:gsub('^(.-)%s+(.-)$', function(open, close)
            state.tag_open, state.tag_close = open, close
            return ''
        end)
        ]]
    end, 
}

function r.partial(state, name, context)
    local target_mt   = setmetatable(context, { __index = state.lookup_env })
    local target_name = setfenv(loadstring('return ' .. name), target_mt)()
    local target_type = type(target_name)

    if target_type == 'string' then
        return r.render(state, target_name, context)
    elseif target_type == 'table' then
        local target_template = setfenv(loadstring('return '..name..'_template'), target_mt)()
        return r.render(state, target_template, merge_environment(target_name, context))
    else
        error('unknown partial type "' .. tostring(name) .. '"')
    end
end

function r.tags(state, template, context)
    local tag_path = state.tag_open..'([=!<{]?)(%s*([^#/]-)%s*)[=}]?%s*'..state.tag_close

    return template:gsub(tag_path, function(op, outer, name)
        if operators[op] ~= nil then
            return tostring(operators[op](state, outer, name, context))
        else
            return escape(tostring((function() 
                if name ~= '.' then 
                    return find(name, context) 
                else 
                    return context 
                end
            end)()))
        end
    end)
end

function r.section(state, template, context)
    for section_name in template:gmatch(state.tag_open..'#%s*([^#/]-)%s*'..state.tag_close) do 
        local found, value = context[section_name] ~= nil, find(section_name, context)
        local section_path = state.tag_open..'#'..section_name..state.tag_close..'%s*(.*)'..state.tag_open..'/'..section_name..state.tag_close..'%s*'

        template = template:gsub(section_path, function(inner)
            if found == false then return '' end

            if value == true then 
                return r.render(state, inner, context)
            elseif type(value) == 'table' then 
                local output = {}
                for _, row in pairs(value) do 
                    local new_context
                    if type(row) == 'table' then 
                        new_context = merge_environment(context, row)
                    else
                        new_context = row
                    end
                    table.insert(output, (r.render(state, inner, new_context)))
                end
                return table.concat(output)
            else 
                return ''
            end
        end)
    end

    return template
end

function r.render(state, template, context)
    return r.tags(state, r.section(state, template, context), context)
end

function render(template, context, env)
    if template:find(tags.open) == nil then return template end

    local state = {
        lookup_env = env or _G,
        tag_open   = tags.open,
        tag_close  = tags.close,
    }

    return r.render(state, template, context or {})
end
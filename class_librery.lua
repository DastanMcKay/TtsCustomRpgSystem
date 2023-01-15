--VERSION=0.1
--CLASS_NAME=ClassLibrery

local function getVersion(script)
    local versionStart, _ = string.find(script, "--VERSION=", nil, true)
    versionStart = versionStart + 1
    local versioEnd, _ = string.find(script, "\n", versionStart, true)
    versionEnd = versioEnd - 1
    local verStr = string.sub(script, versionStart, versioEnd)
    return tonumber(verStr) or 0
end

local function getName(script)
    local nameStart, _ = string.find(script, "--CLASS_NAME=", nil, true)
    nameStart = nameStart + 1
    local nameEnd, _ = string.find(script, "\n", nameStart, true)
    versionEnd = nameEnd - 1
    return string.sub(script, nameStart, nameEnd)
end


function CreateClassFromString(script)
    local versionVal = getVersion(script)
    local nameVal = getName(script)
    local class = {
        version = function() return versionVal end,
        name = function() return nameVal end,
    }
    local createClass = assert(load(script))
    setmetatable(class, createClass())
    class.__index = class
    return class
end

-- -- look up for `k' in list of tables `plist'
-- local function search(k, plist)
--     for _, table in pairs(plist) do
--         local v = table[k]
--         if (v ~= nil) then
--             return v
--         end
--     end
-- end

-- ---comment Create a class with multiple inheritance
-- ---@param ... table List of inherited classes
-- ---@return table
-- function InheritClasses(...)
--     local c = {} -- new class

--     -- class will search for each method in the list of its
--     -- parents (`arg' is the list of parents)
--     setmetatable(c, { __index = function(t, k)
--         local v = search(k, arg)
--         t[k] = v
--         return v
--     end })

--     -- prepare `c' to be the metatable of its instances
--     c.__index = c

--     -- define a new constructor for this new class
--     function c:new(o)
--         o = o or {}
--         setmetatable(o, c)
--         return o
--     end

--     -- return new class
--     return c
-- end

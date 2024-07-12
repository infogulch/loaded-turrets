local set = {}

function set:new(elements)
    local s = {}
    setmetatable(s, self)
    self.__index = self
    s:add(elements)
    return s
end

function set:has(elements)
    for _, e in pairs(elements) do
        if not self[e] then return false end
    end
    return true
end

function set:add(elements)
    for _, e in pairs(elements) do
        if not self:has { e } then self[e] = true end
    end
end

function set:len()
    return table_size(self)
end

function set:is_empty()
    return next(self) == nil
end

function set:intersection(others)
    local res = set:new {}
    for k in pairs(self) do
        for _, s in pairs(others) do
            if not s[k] then goto continue end
        end
        res[k] = true
        ::continue::
    end
    return res
end

function set:equal(others)
    return self:len() == (self:intersection(others)):len()
end

assert(set:new { "a" }:has { "a" })
assert(not set:new { "a" }:has { "b" })
assert(set:new { "a", "b" }:has { "a", "b" })
assert(set:new { "a", "b" }:intersection { set:new { "b", "c" } }:equal { set:new { "b" } })

return set
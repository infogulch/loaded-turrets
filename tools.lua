local Set = require("set")

function map(list, fn)
    local res = {}
    for _, v in pairs(list) do
        table.insert(res, fn(v))
    end
    return res
end

function slice(list, i, j)
    local result = table.pack(table.unpack(list, i, j))
    result["n"] = nil -- :(
    return result
end

-- Extracts the IconData fields from a prototype's embedded icon fields
function proto_icon(proto --[[ @as data.IconData]])
    return {
        icon = proto.icon,
        icon_size = proto.icon_size,
        icon_mipmaps = proto.icon_mipmaps,
        icon_scale = proto.icon_scale,
    } --[[ @as data.IconData]]
end

function concat(arrays)
    local result = {}
    for _, arr in ipairs(arrays) do
        for _, v in ipairs(arr) do
            table.insert(result, v)
        end
    end
    return result
end

local function memoize(fn, keyfn)
    local memo = {}
    setmetatable(memo, { __mode = "v" })
    keyfn = keyfn or function(x) return x end
    return function(param)
        local key = keyfn(param)
        local v = memo[key]
        if v then return v end
        v = fn(param)
        memo[key] = v
        return v
    end
end

local function lookup(list, getprop)
    return function(needle)
        for _, v in pairs(list) do
            if getprop(v) == needle then return v end
        end
    end
end

lookupitem = memoize(lookup(data.raw["item"], function(i) return i.place_result end))

local turret_ammo_cats = memoize(function(turret)
    return Set:new(turret.attack_parameters.ammo_categories or
        { turret.attack_parameters.ammo_category or turret.attack_parameters.ammo_type.category })
end)

local ammo_cats = memoize(function(ammo)
    return Set:new(map(ammo.ammo_type[1] and ammo.ammo_type or { ammo.ammo_type }, function(at) return at.category end))
end)

---@param turret data.AmmoTurretPrototype
---@param ammo data.AmmoItemPrototype
function compatible_turret_ammo(turret, ammo)
    return not turret_ammo_cats(turret):intersection { ammo_cats(ammo) }:is_empty()
end

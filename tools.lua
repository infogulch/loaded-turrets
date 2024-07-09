function merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        assert(type(from) == "table", string.format("Expected a table as function parameter %d", i))
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(result, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

function map(list, f)
    local result = {}
    for _, v in ipairs(list) do
        table.insert(result, f(v))
    end
    return result
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

return {
    merge,
    map,
    slice,
}

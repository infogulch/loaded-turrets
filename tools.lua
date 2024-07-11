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

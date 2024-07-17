--[[icons contains helper functions for building icons]]

do
  ---@class IconTransform
  ---@field scale? double
  ---@field shift? data.Vector
  ---@field tint? data.Color
  data_IconTransform = {}
end

-- Extract the icons from a prototype's icon fields or its icons field, from a single icon
-- or from a list of icons, and returns the result as a list of icons.
---@param proto data.IconData|data.IconData[]|data.ItemPrototype|data.TechnologyPrototype|data.VirtualSignalPrototype
---@return data.IconData[]?
function get_icons(proto)
  if not proto then return end
  if proto.icons then
    return table.deepcopy(proto.icons)
  end
  if proto.icon then
    return { {
      icon = proto.icon,
      icon_size = proto.icon_size,
      icon_mipmaps = proto.icon_mipmaps,
      scale = proto.scale,
      shift = proto.shift,
      tint = proto.tint,
    } }
  end
  if proto[1] and proto[1].icon then
    return table.deepcopy(proto)
  end
end

local function vector_mul(vectors)
  local res = table.deepcopy(table.remove(vectors, 1))
  for _, vec in pairs(vectors) do
    if type(vec) == "number" then vec = { vec, vec } end -- allow scalars
    for k in pairs(vec) do
      res[k] = res[k] * vec[k]
    end
  end
  return res
end

local function vector_add(vectors)
  local res = table.deepcopy(table.remove(vectors, 1))
  for _, vec in pairs(vectors) do
    if type(vec) == "number" then vec = { vec, vec } end -- allow scalars
    for k in pairs(vec) do
      res[k] = res[k] + vec[k]
    end
  end
  return res
end

--[[
icon_combinator combines layers of icons, where each layer may be a one or more
icons, applying an abstract transform to each layer as a group.

- The first icon in the first layer (called "base" in the code) is pased through
  unaltered.
- Add a 0px or fully transparent dummy icon file as the first icon if you want
  to apply a tranform to every icon.
- Unlike the data.IconData scale and shift fields, IconTransform inputs are
  adjusted so the numbers are relative to the final icon size. e.g. a scale of
  0.5 scales the length of the sides of the icons down by 50%, and a shift of
  {0.2, 0.2} moves the icons down and to the right by 20% of the width of the
  final icon.
- The output of icon_combinator can be fed back into icon_combinator again as an
  icon layer. A transform applied to such a layer of icons is correctly shifted
  and scaled as a group as if it were a single icon.
- If you use the same base icon in multiple nested calls to icon_combinator, and
  add the `.base_icon=true` field to it, all but the first instance of the base
  icon is filtered out. This is a bit of a hack, but it is helpful for combining
  nested icon definitions.

These features hopefully make it easy to generically combine prototype icons,
programatically building up a new icon from arbitrary pieces.
]]
---@param layers { [1]:data.IconData|data.IconData[]|data.ItemPrototype|data.TechnologyPrototype, [2]: IconTransform}[]
---@return data.IconData[]
function icon_combinator(layers)
  local icons = {}
  local base, base_size
  for _, layer in pairs(layers) do
    local icons_to_add = get_icons(layer[1]) or error("failed to get icons from: " .. serpent.dump(layer))
    local scale        = layer[2].scale or 1
    local shift        = layer[2].shift or { 0, 0 }
    local tint         = layer[2].tint or { r = 1, g = 1, b = 1, a = 1 }

    if not base then
      base = table.remove(icons_to_add, 1)
      if not base.scale then base.scale = 32.0 / base.icon_size end
      base_size = base.scale * base.icon_size
      table.insert(icons, base)
    end

    for _, icon_to_add in pairs(icons_to_add) do
      if icon_to_add.base_icon then goto continue end
      if icon_to_add.shift then
        icon_to_add.shift = vector_mul { vector_add { vector_mul { icon_to_add.shift, scale / (base_size) }, shift }, base_size }
      else
        icon_to_add.shift = vector_mul { shift, base_size }
      end
      if icon_to_add.scale then
        icon_to_add.scale = icon_to_add.scale * scale
      else
        icon_to_add.scale = scale * base_size / icon_to_add.icon_size
      end
      table.insert(icons, {
        icon = icon_to_add.icon,
        icon_mipmaps = icon_to_add.icon_mipmaps,
        icon_size = icon_to_add.icon_size,
        scale = icon_to_add.scale,
        shift = icon_to_add.shift,
        tint = util.mix_color(icon_to_add.tint or { 1, 1, 1, 1 }, tint),
      })
      ::continue::
    end
  end
  return icons
end

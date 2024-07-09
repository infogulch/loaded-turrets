require "tools"

---@type data.ItemPrototype[], data.RecipePrototype[], data.EntityPrototype[], data.TechnologyPrototype[]
local items, recipes, entities, technologies = {}, {}, {}, {}

do
  local gunturret = data.raw["ammo-turret"]["gun-turret"]
  local gunturreticon = proto_icon(gunturret)

  local alphabet = "abcdefghijklmnopqrstuvwxyz"

  local ammo_names = { "firearm-magazine", "piercing-rounds-magazine", "uranium-rounds-magazine" }
  local capacities = { gunturret.automated_ammo_count, gunturret.automated_ammo_count * 2 }

  for ammoidx, ammoname in pairs(ammo_names) do
    local ammo = data.raw["ammo"][ammoname]
    local ammoicon = proto_icon(ammo)
    local ammoord = alphabet.sub(ammoidx, ammoidx + 1) .. "[" .. ammo.name .. "]"

    for capidx, cap in pairs(capacities) do
      local name = "loaded-gun-turret-" .. ammo.name .. "-" .. cap
      local localised_name = { "loaded-turrets.gun-turret-name", cap, { "item-name." .. ammo.name } }
      local capord = alphabet.sub(capidx, capidx + 1) .. "[" .. cap .. "]"
      local icons = {
        merge({}, gunturreticon, { scale = .19, shift = { -1.2, -1.2 } }),
        merge({}, ammoicon, { scale = .17, shift = { 1.2, 1.2 } }),
        merge({}, ammoicon, { scale = .15, shift = { -1, 1.2 } }),
      }
      if capidx == 1 then
        table.remove(icons, 3)
      end

      table.insert(items, {
        type = "item",
        name = name,
        localised_name = localised_name,
        localised_description = { "loaded-turrets.gun-turret-description" },
        icons = icons,
        subgroup = "loaded-turret",
        order = ammoord .. "-" .. capord,
        place_result = name,
        stack_size = data.raw["item"]["gun-turret"].stack_size / 2,
      } --[[ @as data.ItemPrototype ]])
      table.insert(recipes, {
        type = "recipe",
        name = name,
        localised_name = localised_name,
        enabled = false,
        energy_required = 0.5,
        ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { ammo.name, cap } },
        result = name,
      } --[[ @as data.RecipePrototype ]])
      table.insert(entities, merge({}, gunturret, {
        name = name,
        localised_name = localised_name,
      } --[[ @as data.EntityPrototype ]]))
    end
  end
end

do
  local mil2 = data.raw["technology"]["military-2"]
  local mil3 = data.raw["technology"]["military-3"]
  local gttechicon = proto_icon(data.raw["technology"]["gun-turret"])
  local ammo1icon = proto_icon(data.raw["ammo"]["firearm-magazine"])
  local ammo2icon = proto_icon(data.raw["ammo"]["piercing-rounds-magazine"])

  local unlocks = map(recipes, function(r) return { type = "unlock-recipe", recipe = r.name } end)

  technologies = {
    {
      type = "technology",
      name = "loaded-turret",
      unit = mil2.unit,
      effects = slice(unlocks, 1, 1),
      prerequisites = { "gun-turret", "military-2" },
      icons = {
        merge({}, gttechicon, { scale = 0.19, shift = { -3.5, -3.5 } }),
        merge({}, ammo1icon, { scale = .5, shift = { 7, 10 } }),
      },
      order = "a-j-a",
    },
    {
      type = "technology",
      name = "loaded-turret-2",
      unit = merge({}, mil3.unit, { count = mil3.unit.count / 2 }),
      effects = slice(unlocks, 2),
      prerequisites = { "loaded-turret", "military-3" },
      icons = {
        merge({}, gttechicon, { scale = 0.19, shift = { -3.5, -3.5 } }),
        merge({}, ammo2icon, { scale = .5, shift = { 7, 10 } }),
        merge({}, ammo2icon, { scale = .5, shift = { 0, 10 } }),
      },
      order = "a-j-a",
    },
  }
end

data:extend {
  {
    type = "item-subgroup",
    name = "loaded-turret",
    group = "combat",
    order = "gg",
  },
  table.unpack(merge({}, items, recipes, entities, technologies)),
}

require "tools"

---@type data.ItemSubGroup[], data.ItemPrototype[], data.RecipePrototype[], data.EntityPrototype[], data.TechnologyPrototype[]
local subgroups, items, recipes, entities, technologies = {}, {}, {}, {}, {}

for _, turret in pairs(data.raw["ammo-turret"]) do
  local turretitem = lookupitem(turret.name)

  local caps = {}
  for i, c in pairs({ turret.automated_ammo_count, turret.automated_ammo_count * 2 }) do
    local order = ("ab"):sub(i, i) .. "[" .. c .. "]"
    local subgroup = "loaded-turrets_" .. turret.name .. "_" .. c
    table.insert(caps, {
      count = c,
      order = order,
      subgroup = subgroup,
    })
    table.insert(subgroups, {
      type = "item-subgroup",
      group = "combat",
      name = subgroup,
      order = "gg-" .. turretitem.order .. "-" .. order,
    } --[[ @as data.ItemSubGroup ]])
  end

  for _, ammo in pairs(data.raw["ammo"]) do
    if not compatible_turret_ammo(turret, ammo) then goto continue end

    for capidx, cap in ipairs(caps) do
      local name = "loaded_" .. turret.name .. "_" .. ammo.name .. "_" .. cap.count
      local localised_name = { "loaded-turrets.name", { "entity-name." .. turret.name }, cap.count, { "item-name." .. ammo.name } }
      local order = turretitem.order .. "-" .. ammo.order .. "-" .. cap.order

      local turreticon = proto_icon(turret)
      local ammoicon = proto_icon(ammo)
      local ratio = turreticon.icon_size / ammoicon.icon_size
      local icons = {
        util.merge { turreticon, { scale = .19, shift = { -1.2, -1.2 } } },
        util.merge { ammoicon, { scale = .17 * ratio, shift = { 1.2 * ratio, 1.2 * ratio } } },
        util.merge { ammoicon, { scale = .15 * ratio, shift = { -1 * ratio, 1.2 * ratio } } },
      }
      if capidx == 1 then
        table.remove(icons, 3)
      end

      table.insert(items, {
        type = "item",
        name = name,
        localised_name = localised_name,
        localised_description = { "loaded-turrets.description", { "entity." .. turret.name } },
        icons = icons,
        subgroup = cap.subgroup,
        order = order,
        place_result = name,
        stack_size = data.raw["item"]["gun-turret"].stack_size / 2,
      } --[[ @as data.ItemPrototype ]])
      table.insert(recipes, {
        type = "recipe",
        name = name,
        localised_name = localised_name,
        order = order,
        enabled = false,
        energy_required = 0.5,
        ingredients = { { turretitem.name, 1 }, { "electronic-circuit", 1 }, { ammo.name, cap.count } },
        result = name,
      } --[[ @as data.RecipePrototype ]])
      table.insert(entities, util.merge { turret, {
        name = name,
        localised_name = localised_name,
        order = order,
      } })
    end
    ::continue::
  end
end

do
  local mil2 = data.raw["technology"]["military-2"]
  local mil3 = data.raw["technology"]["military-3"]
  local gttechicon = proto_icon(data.raw["technology"]["gun-turret"])
  local ammo1icon = proto_icon(data.raw["ammo"]["firearm-magazine"])
  local ammo2icon = proto_icon(data.raw["ammo"]["piercing-rounds-magazine"])

  local unlocks = {}
  for _, r in pairs(recipes) do
    table.insert(unlocks, { type = "unlock-recipe", recipe = r.name })
  end

  technologies = {
    {
      type = "technology",
      name = "loaded-turret",
      unit = mil2.unit,
      effects = slice(unlocks, 1, 1),
      prerequisites = { "gun-turret", "military-2" },
      icons = {
        util.merge { gttechicon, { scale = 0.19, shift = { -3.5, -3.5 } } },
        util.merge { ammo1icon, { scale = .5, shift = { 7, 10 } } },
      },
      order = "a-j-a",
    },
    {
      type = "technology",
      name = "loaded-turret-2",
      unit = util.merge { mil3.unit, { count = mil3.unit.count / 2 } },
      effects = slice(unlocks, 2),
      prerequisites = { "loaded-turret", "military-3" },
      icons = {
        util.merge { gttechicon, { scale = 0.19, shift = { -3.5, -3.5 } } },
        util.merge { ammo2icon, { scale = .5, shift = { 7, 10 } } },
        util.merge { ammo2icon, { scale = .5, shift = { 0, 10 } } },
      },
      order = "a-j-a",
    },
  }
end

data:extend(concat { subgroups, items, recipes, entities, technologies })

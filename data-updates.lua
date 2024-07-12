local Set = require("set")

---@type {[string]: {[string]:boolean}}
local items_by_placeresult = {}
for _, i in pairs(data.raw["item"]) do
  if i.place_result then
    local set = items_by_placeresult[i.place_result]
    if not set then
      set = Set:new()
      items_by_placeresult[i.place_result] = set
    end
    set:add { i.name }
  end
end

---@type {[string]: {[string]:boolean}}
local techs_by_recipe = {}
for _, tech in pairs(data.raw["technology"]) do
  for _, e in pairs(tech.effects or {}) do
    if e.type == "unlock-recipe" then
      local set = techs_by_recipe[e.recipe]
      if not set then
        set = Set:new()
        techs_by_recipe[e.recipe] = set
      end
      set:add { tech.name }
    end
  end
end

---@type {[string]: {[string]:boolean}}
local ammo_by_category = {}
for _, ammo in pairs(data.raw["ammo"]) do
  for _, t in pairs(ammo.ammo_type[1] and ammo.ammo_type or { ammo.ammo_type }) do
    local set = ammo_by_category[t.category]
    if not set then
      set = Set:new()
      ammo_by_category[t.category] = set
    end
    set:add { ammo.name }
  end
end

-- Extract the IconData fields from a prototype's embedded icon fields
---@param proto data.ItemPrototype|data.TechnologyPrototype
---@return data.IconData?
function proto_icon(proto)
  if not proto then return end
  return {
    icon = proto.icon,
    icon_size = proto.icon_size,
    icon_mipmaps = proto.icon_mipmaps,
  }
end

function first(tbl)
  return pairs(tbl)(tbl)
end

function keys(tbl)
  local ret = {}
  for k, _ in pairs(tbl) do
    table.insert(ret, k)
  end
  return ret
end

---@type data.ItemSubGroup[], data.ItemPrototype[], data.RecipePrototype[], data.EntityPrototype[], data.TechnologyPrototype[]
local subgroups, items, recipes, entities, technologies = {}, {}, {}, {}, {}

for _, turret in pairs(data.raw["ammo-turret"]) do
  local turretitem = data.raw["item"][first(items_by_placeresult[turret.name])]
  local _, ammocategory = first(turret.attack_parameters.ammo_categories or
    { turret.attack_parameters.ammo_category or turret.attack_parameters.ammo_type.category })
  local ammonames = keys(ammo_by_category[ammocategory])
  table.sort(ammonames, function(a, b) return data.raw["ammo"][a].order < data.raw["ammo"][b].order end)
  local techeffects = {}

  for countidx, count in pairs({ turret.automated_ammo_count, turret.automated_ammo_count * 2 }) do
    local countorder = ("ab"):sub(countidx, countidx) .. "[" .. count .. "]"
    local subgroup = "loaded-turrets_" .. turret.name .. "_" .. count

    for _, ammoname in pairs(ammonames) do
      local ammo = data.raw["ammo"][ammoname]

      local name = "loaded_" .. turret.name .. "_" .. ammo.name .. "_" .. count
      local localised_name = { "loaded-turrets.name", { "entity-name." .. turret.name }, count, { "item-name." .. ammo.name } }
      local order = turretitem.order .. "-" .. ammo.order .. "-" .. countorder

      local turreticon = proto_icon(turretitem)
      local ammoicon = proto_icon(ammo)
      local ratio = turreticon.icon_size / ammoicon.icon_size
      local icons = {
        util.merge { turreticon, { scale = .19, shift = { -1.2, -1.2 } } },
        util.merge { ammoicon, { scale = .17 * ratio, shift = { 1.2 * ratio, 1.2 * ratio } } },
        util.merge { ammoicon, { scale = .15 * ratio, shift = { -1 * ratio, 1.2 * ratio } } },
      }
      if countidx == 1 then
        table.remove(icons, 3)
      end

      table.insert(items, {
        type = "item",
        name = name,
        localised_name = localised_name,
        localised_description = { "loaded-turrets.description", { "entity-name." .. turret.name } },
        icons = icons,
        subgroup = subgroup,
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
        ingredients = { { turretitem.name, 1 }, { "electronic-circuit", 1 }, { ammo.name, count } },
        result = name,
      } --[[ @as data.RecipePrototype ]])

      table.insert(entities, util.merge { turret, {
        name = name,
        localised_name = localised_name,
        order = order,
      } })

      table.insert(techeffects, { type = "unlock-recipe", recipe = name })
    end

    if #techeffects == 0 then goto continue end

    table.insert(subgroups, {
      type = "item-subgroup",
      group = "combat",
      name = subgroup,
      order = "gg-" .. turretitem.order .. "-" .. countorder,
    } --[[ @as data.ItemSubGroup ]])
  end

  local mil2 = data.raw["technology"]["military-2"]
  local mil3 = data.raw["technology"]["military-3"]
  local turrettech = data.raw["technology"][first(techs_by_recipe[turretitem.name] or {})] or
      data.raw["technology"]["gun-turret"]
  local turrettechicon = proto_icon(turrettech)
  local ammo1icon = proto_icon(data.raw["ammo"][table.remove(ammonames, 1)])
  local ammo2icon = proto_icon(data.raw["ammo"][table.remove(ammonames, 1)]) or ammo1icon

  local ratio1 = ammo1icon.icon_size / turrettechicon.icon_size
  table.insert(technologies, {
    type = "technology",
    name = "loaded-turrets_" .. turret.name,
    localised_name = { "loaded-turrets.tech-name", { "entity-name." .. turret.name } },
    localised_description = { "loaded-turrets.tech-description", { "entity-name." .. turret.name }, { "ammo-category-name." .. ammocategory } },
    unit = util.merge { turrettech.unit, mil2.unit, { count = mil2.unit.count } },
    effects = { table.remove(techeffects) },
    prerequisites = { turrettech.name, mil2.name }, -- TODO: Trim prerequisites if turrettech subsumes mil tech
    icons = {
      util.merge { turrettechicon, { scale = 0.19, shift = { -3.5, -3.5 } } },
      util.merge { ammo1icon, { scale = .5 * ratio1, shift = { 7 * ratio1, 10 * ratio1 } } },
    },
    order = "a-j-a",
  })

  local ratio2 = ammo2icon.icon_size / turrettechicon.icon_size
  table.insert(technologies, {
    type = "technology",
    name = "loaded-turrets_" .. turret.name .. "-2",
    localised_name = { "loaded-turrets.tech-name-2", { "entity-name." .. turret.name } },
    localised_description = { "loaded-turrets.tech-description", { "entity-name." .. turret.name }, { "ammo-category-name." .. ammocategory } },
    unit = util.merge { turrettech.unit, mil3.unit, { count = mil3.unit.count / 2 } },
    effects = techeffects,
    prerequisites = { mil3.name, "loaded-turrets_" .. turret.name },
    icons = {
      util.merge { turrettechicon, { scale = 0.19, shift = { -3.5, -3.5 } } },
      util.merge { ammo2icon, { scale = .5 * ratio2, shift = { 7 * ratio2, 10 * ratio2 } } },
      util.merge { ammo2icon, { scale = .5 * ratio2, shift = { 0, 10 * ratio2 } } },
    },
    order = "a-j-a",
  })

  ::continue::
end

data:extend(subgroups)
data:extend(items)
data:extend(recipes)
data:extend(entities)
data:extend(technologies)

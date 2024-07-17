require("icons")
require("lut")

local base_icon = { icon = "__loaded-turrets__/graphics/icon-circular-transparent.png", icon_size = 64, icon_mipmaps = 3, base_icon = true }

function first(tbl)
  return pairs(tbl)(tbl)
end

---@param a data.TechnologyUnit
---@param b data.TechnologyUnit
---@return data.TechnologyUnit
function technologyunit_max(a, b)
  local ingredients = table.deepcopy(a.ingredients)
  for _, i2 in pairs(b.ingredients) do
    local i2name = i2[1] or i2.name
    for _, i1 in pairs(a.ingredients) do
      local i1name = i1[1] or i1.name
      if i1name == i2name then
        if i1[1] then
          i1[2] = math.max(i1[2], i2[2] or i2.amount)
        else
          i1.amount = math.max(i1.amount, i2[2] or i2.amount)
        end
        goto continue
      end
    end
    table.insert(ingredients, i2)
    ::continue::
  end
  return {
    time = math.max(a.time, b.time),
    count = math.max(a.count, b.count),
    ingredients = ingredients
  }
end

---@type data.ItemSubGroup[], data.ItemPrototype[], data.RecipePrototype[], data.EntityPrototype[], data.TechnologyPrototype[]
local subgroups, items, recipes, entities, technologies = {}, {}, {}, {}, {}

for _, turret in pairs(data.raw["ammo-turret"]) do
  local turretitems = items_by_placeresult[turret.name]
  if not turretitems then
    log("turret does not have an item that places it, skipping: " .. serpent.dump(turret))
    goto continue
  end
  local turretitem = data.raw["item"][first(turretitems)]
  local _, ammocategory = first(turret.attack_parameters.ammo_categories or
    { turret.attack_parameters.ammo_category or turret.attack_parameters.ammo_type.category })
  local ammos = ammo_by_category[ammocategory]
  if not ammos then
    log("no valid ammo for turret, skipping: " .. serpent.dump { turret = turret, ammo_categories = ammo_by_category })
    goto continue
  end
  local techeffects = {}

  for countidx, count in pairs({ turret.automated_ammo_count, turret.automated_ammo_count * 2 }) do
    local countorder = ("ab"):sub(countidx, countidx) .. "[" .. count .. "]"
    local subgroup = "loaded-turrets_" .. turret.name .. "_" .. count

    for _, ammo in pairs(ammos) do
      local name = "loaded-turrets_" .. turret.name .. "_" .. ammo.name .. "_" .. count
      local localised_name = { "loaded-turrets.name", { "entity-name." .. turret.name }, count, { "item-name." .. ammo.name } }
      local order = turretitem.order .. "-" .. ammo.order .. "-" .. countorder

      local icons = icon_combinator {
        { base_icon,  {} },
        { turretitem, { scale = .9, shift = { -0.1, -0.1 } } },
        { ammo,       { scale = .75, shift = { 0.2, 0.2 } } },
        { ammo,       { scale = .75, shift = { 0, 0.2 } } },
      }
      if countidx == 1 then
        table.remove(icons)
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
        stack_size = math.max(turretitem.stack_size / 2, 1),
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

  local mil2, mil3 = data.raw["technology"]["military-2"], data.raw["technology"]["military-3"]
  local turrettech = data.raw["technology"][first(techs_by_recipe[turretitem.name] or {})]
  local turrettechicons = get_icons(turrettech) or get_icons(turretitem)
  local ammo1icons = get_icons(ammos[1])
  local ammo2icons = get_icons(ammos[2]) or get_icons(ammos[1])
  local techorder = (turrettech and turrettech.order) or "a-j-a"

  local pre1, unit1
  if turrettech then
    pre1 = { turrettech.name }
    unit1 = technologyunit_max(turrettech.unit, mil2.unit)
    if not tech_transitive_prerequisites == nil and not tech_transitive_prerequisites[turrettech.name][mil2.name] then
      table.insert(pre1, mil2.name)
    end
  else
    pre1 = { mil2.name }
    unit1 = mil2.unit
  end
  table.insert(technologies, {
    type = "technology",
    name = "loaded-turrets_" .. turret.name,
    localised_name = { "loaded-turrets.tech-name", { "entity-name." .. turret.name } },
    localised_description = { "loaded-turrets.tech-description", { "entity-name." .. turret.name }, { "ammo-category-name." .. ammocategory } },
    unit = unit1,
    prerequisites = pre1,
    effects = { table.remove(techeffects, 1) },
    icons = icon_combinator {
      { base_icon,       {} },
      { turrettechicons, { scale = 0.9, shift = { -0.1, -0.1 } } },
      { ammo1icons,      { scale = .6, shift = { .2, .2 } } },
    },
    order = techorder .. "-" .. turretitem.order .. "-lt1",
  })

  local pre2 = { "loaded-turrets_" .. turret.name }
  local unit2 = technologyunit_max(util.merge { unit1, { count = unit1.count * 2 } }, mil3.unit)
  if not turrettech or tech_transitive_prerequisites == nil or not tech_transitive_prerequisites[turrettech.name][mil3.name] then
    table.insert(pre2, mil3.name)
  end
  table.insert(technologies, {
    type = "technology",
    name = "loaded-turrets_" .. turret.name .. "-2",
    localised_name = { "loaded-turrets.tech-name-2", { "entity-name." .. turret.name } },
    localised_description = { "loaded-turrets.tech-description", { "entity-name." .. turret.name }, { "ammo-category-name." .. ammocategory } },
    unit = unit2,
    prerequisites = pre2,
    effects = techeffects,
    icons = icon_combinator {
      { base_icon,       {} },
      { turrettechicons, { scale = 0.9, shift = { -0.1, -0.1 } } },
      { ammo2icons,      { scale = .6, shift = { 0.2, 0.2 } } },
      { ammo2icons,      { scale = .6, shift = { 0, 0.2 } } },
    },
    order = techorder .. "-" .. turretitem.order .. "-lt2",
  })

  ::continue::
end

data:extend(subgroups)
data:extend(items)
data:extend(recipes)
data:extend(entities)
data:extend(technologies)

log("loaded turrets: added "
  .. #items .. " items, "
  .. #subgroups .. " item subgroups, and "
  .. #technologies .. " technologies")

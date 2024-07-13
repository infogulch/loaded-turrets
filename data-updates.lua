local Set = require("set")

---@type {[string]: {[string]:true}}
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

---@type {[string]: {[string]:true}}
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

---@type {[string]: {[string]:true}}
local ammo_names_by_category = {}
for _, ammo in pairs(data.raw["ammo"]) do
  for _, t in pairs(ammo.ammo_type[1] and ammo.ammo_type or { ammo.ammo_type }) do
    local set = ammo_names_by_category[t.category]
    if not set then
      set = Set:new()
      ammo_names_by_category[t.category] = set
    end
    set:add { ammo.name }
  end
end

---@type {[string]: data.AmmoItemPrototype[]}
local ammo_by_category = {}
do
  for name, ammos in pairs(ammo_names_by_category) do
    local cat = {}
    for ammoname in pairs(ammos) do
      table.insert(cat, data.raw["ammo"][ammoname])
    end
    table.sort(cat, function(a1, a2) return a1.order < a2.order end)
    ammo_by_category[name] = cat
  end
end

---@type {[string]: {[string]:true}}
local tech_transitive_prerequisites = {}
do
  ---@type data.TechnologyPrototype[]
  local techs = {}
  for _, t in pairs(data.raw["technology"]) do
    table.insert(techs, t)
  end
  -- it would be nice if this ordered techs so prerequisites generally came
  -- first, but alas .order field is not maintained so you get quadratic perf yw
  table.sort(techs, function(a, b) return (a.order or "") < (b.order or "") end)
  local scans, steps = 0, 0
  while #techs > 0 do
    scans = scans + 1
    for idx, tech in pairs(techs) do
      steps = steps + 1
      local prereqs = Set:new(tech.prerequisites)
      for _, pname in pairs(tech.prerequisites or {}) do
        local pre = tech_transitive_prerequisites[pname]
        if not pre then goto continue end
        for p in pairs(pre) do
          prereqs:add { p }
        end
      end
      tech_transitive_prerequisites[tech.name] = prereqs
      table.remove(techs, idx)
      ::continue::
    end
  end
  log("calculated prerequisites in " .. scans .. " scans and " .. steps .. " steps")
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

---Fixes icon scale and shift to be sane
---@param icons data.IconData[]
---@return data.IconData[]
function fix_icons(icons)
  local first = icons[1]
  local res = {}
  local size = first.icon_size * (first.scale or 1)
  for _, icon in pairs(icons) do
    local ratio = first.icon_size / icon.icon_size
    if icon.scale then icon.scale = icon.scale * ratio end
    if icon.shift then icon.shift = { icon.shift[1] * size, icon.shift[2] * size } end
    table.insert(res, icon)
  end
  return res
end

function first(tbl)
  return pairs(tbl)(tbl)
end

---@type data.ItemSubGroup[], data.ItemPrototype[], data.RecipePrototype[], data.EntityPrototype[], data.TechnologyPrototype[]
local subgroups, items, recipes, entities, technologies = {}, {}, {}, {}, {}

for _, turret in pairs(data.raw["ammo-turret"]) do
  local turretitem = data.raw["item"][first(items_by_placeresult[turret.name])]
  local _, ammocategory = first(turret.attack_parameters.ammo_categories or
    { turret.attack_parameters.ammo_category or turret.attack_parameters.ammo_type.category })
  local ammos = ammo_by_category[ammocategory]
  local techeffects = {}

  for countidx, count in pairs({ turret.automated_ammo_count, turret.automated_ammo_count * 2 }) do
    local countorder = ("ab"):sub(countidx, countidx) .. "[" .. count .. "]"
    local subgroup = "loaded-turrets_" .. turret.name .. "_" .. count

    for _, ammo in pairs(ammos) do
      local name = "loaded-turrets_" .. turret.name .. "_" .. ammo.name .. "_" .. count
      local localised_name = { "loaded-turrets.name", { "entity-name." .. turret.name }, count, { "item-name." .. ammo.name } }
      local order = turretitem.order .. "-" .. ammo.order .. "-" .. countorder

      local turreticon = proto_icon(turretitem)
      local ammoicon = proto_icon(ammo)
      local icons = fix_icons {
        util.merge { turreticon, { scale = .19, shift = { -0.1, -0.1 } } },
        util.merge { ammoicon, { scale = .17, shift = { .2, .2 } } },
        util.merge { ammoicon, { scale = .17, shift = { -.05, .2 } } },
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
        stack_size = turretitem.stack_size / 2,
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
  local turrettechicon = proto_icon(turrettech or turretitem)
  local ammo1icon = proto_icon(ammos[1])
  local ammo2icon = proto_icon((ammos[2] or ammos[1]))
  local techorder = (turrettech and turrettech.order) or "a-j-a"

  local pre1, unit1
  if turrettech then
    pre1 = { turrettech.name }
    unit1 = turrettech.unit
    if not tech_transitive_prerequisites[turrettech.name][mil2.name] then
      table.insert(pre1, mil2.name)
      unit1 = util.merge { unit1, mil2.unit, { count = math.max(mil2.unit.count, unit1.count) } }
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
    icons = fix_icons {
      util.merge { turrettechicon, { scale = 0.19, shift = { 0, -0.1 } } },
      util.merge { ammo1icon, { scale = .12, shift = { .15, .15 } } },
    },
    order = techorder .. "-" .. turretitem.order .. "-lt1",
  })

  local pre2, unit2 = { "loaded-turrets_" .. turret.name }, util.merge { unit1, { count = unit1.count * 2 } }
  if turrettech and not tech_transitive_prerequisites[turrettech.name][mil3.name] then
    table.insert(pre2, mil3.name)
    unit2 = util.merge { unit2, mil3.unit, { count = math.max(unit2.count, mil3.unit.count / 2) } }
  end
  table.insert(technologies, {
    type = "technology",
    name = "loaded-turrets_" .. turret.name .. "-2",
    localised_name = { "loaded-turrets.tech-name-2", { "entity-name." .. turret.name } },
    localised_description = { "loaded-turrets.tech-description", { "entity-name." .. turret.name }, { "ammo-category-name." .. ammocategory } },
    unit = unit2,
    prerequisites = pre2,
    effects = techeffects,
    icons = fix_icons {
      util.merge { turrettechicon, { scale = 0.19, shift = { 0, -0.1 } } },
      util.merge { ammo2icon, { scale = .12, shift = { .15, .15 } } },
      util.merge { ammo2icon, { scale = .12, shift = { 0, .15 } } },
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

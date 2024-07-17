--[[
lut generates tables with pre-calculated reverse lookups to avoid scanning while
building prototypes
]]

local Set = require("set")

---@type {[string]: {[string]:true}}
items_by_placeresult = {}
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
techs_by_recipe = {}
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
ammo_names_by_category = {}
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
ammo_by_category = {}
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
tech_transitive_prerequisites = {}
do
  function resolve(tech_name)
    local stack, seen = { tech_name }, {}
    while #stack > 0 do
      local name = stack[#stack]

      if tech_transitive_prerequisites[name] then
        table.remove(stack)
        goto continue
      end

      local prereqs, ok = Set:new(data.raw["technology"][name].prerequisites or {}), true
      for _, pname in pairs(data.raw["technology"][name].prerequisites or {}) do
        local pp = tech_transitive_prerequisites[pname]
        if pp then
          prereqs:union { pp }
        else
          ok = false
          table.insert(stack, pname)
        end
      end

      if ok then
        tech_transitive_prerequisites[name] = prereqs
        table.remove(stack)
      elseif seen[name] then
        log("cycle detected calculating technology prerequisites: " .. serpent.dump(stack))
        tech_transitive_prerequisites = nil
        return "error"
      end
      seen[name] = true

      ::continue::
    end
  end

  for _, tech in pairs(data.raw["technology"]) do
    if resolve(tech.name) == "error" then break end
  end
end

-- items
data:extend {
  {
    type = "item-subgroup",
    name = "loaded-turret",
    group = "combat",
    order = "gg",
  },
  {
    type = "item",
    name = "loaded-gun-turret-firearm-magazine-x1",
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",       icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[turret]-a[gun-turret]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-piercing-rounds-magazine-x1",
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",               icon_size = 64, scale = .19, shifet = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },    icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[turret]-a[gun-turret]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-firearm-magazine-x2",
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",       icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .15, shift = { -1, 1.2 },    icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[turret]-a[gun-turret]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-piercing-rounds-magazine-x2",
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",               icon_size = 64, scale = .19, shifet = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },    icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .15, shift = { -1, 1.2 },     icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[turret]-a[gun-turret]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  -- TODO loaded-gun-turret with uranium ammo
}

local aac = data.raw["ammo-turret"]["gun-turret"]["automated_ammo_count"]

-- recipes
data:extend {
  {
    type = "recipe",
    name = "loaded-gun-turret-firearm-magazine",
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "firearm-magazine", aac } },
    result = "loaded-gun-turret-firearm-magazine-x1",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-piercing-rounds-magazine",
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "piercing-rounds-magazine", aac } },
    result = "loaded-gun-turret-piercing-rounds-magazine-x1",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-firearm-magazine-x2",
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "firearm-magazine", aac * 2 } },
    result = "loaded-gun-turret-firearm-magazine-x2",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-piercing-rounds-magazine-x2",
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "piercing-rounds-magazine", aac * 2 } },
    result = "loaded-gun-turret-piercing-rounds-magazine-x2",
  },
  -- TODO loaded-gun-turret with uranium ammo
}

-- technologies
data:extend {
  {
    type = "technology",
    name = "loaded-turret",
    unit = {
      count = data.raw["technology"]["military"]["unit"]["count"],
      time = data.raw["technology"]["military"]["unit"]["time"],
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = "loaded-gun-turret-firearm-magazine" }
    },
    prerequisites = { "gun-turret", "military", "logistic-science-pack" },
    icon = "__base__/graphics/technology/gun-turret.png", icon_size = 256, icon_mipmaps = 4,
    order = "a-j-a",
  },
  {
    type = "technology",
    name = "loaded-turret-2",
    unit = {
      count = data.raw["technology"]["military-2"]["unit"]["count"],
      time = data.raw["technology"]["military-2"]["unit"]["time"],
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = "loaded-gun-turret-firearm-magazine-x2" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-piercing-rounds-magazine" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-piercing-rounds-magazine-x2" },
    },
    prerequisites = { "loaded-turret", "military-2" },
    icon = "__base__/graphics/technology/gun-turret.png", icon_size = 256, icon_mipmaps = 4,
    order = "a-j-a",
  },
  -- TODO loaded-turret-3 after uranium ammo. more capacity?
}

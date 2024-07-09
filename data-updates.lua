local aac = data.raw["ammo-turret"]["gun-turret"]["automated_ammo_count"]

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
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.firearm-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description", { "string-mod-setting.loaded-turrets-load-delay-string" } },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",       icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "a[firearm-magazine]-a[10]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-firearm-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.firearm-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description", { "string-mod-setting.loaded-turrets-load-delay-string" } },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",       icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, scale = .15, shift = { -1, 1.2 },    icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "a[firearm-magazine]-b[20]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-piercing-rounds-magazine-x1",
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.piercing-rounds-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description" },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",               icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[piercing-rounds-magazine]-a[10]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-piercing-rounds-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.piercing-rounds-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description" },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",               icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, scale = .15, shift = { -1, 1.2 },    icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "b[piercing-rounds-magazine]-b[20]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-uranium-rounds-magazine-x1",
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.uranium-rounds-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description" },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",              icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/uranium-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "c[uranium-rounds-magazine]-a[10]",
    place_result = "gun-turret",
    stack_size = 50,
  },
  {
    type = "item",
    name = "loaded-gun-turret-uranium-rounds-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.uranium-rounds-magazine" } },
    localised_description = { "loaded-turrets.gun-turret-description" },
    icons = {
      { icon = "__base__/graphics/icons/gun-turret.png",              icon_size = 64, scale = .19, shift = { -1.2, -1.2 }, icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/uranium-rounds-magazine.png", icon_size = 64, scale = .17, shift = { 1.2, 1.2 },   icon_mipmaps = 4 },
      { icon = "__base__/graphics/icons/uranium-rounds-magazine.png", icon_size = 64, scale = .15, shift = { -1, 1.2 },    icon_mipmaps = 4 },
    },
    subgroup = "loaded-turret",
    order = "c[uranium-rounds-magazine]-b[20]",
    place_result = "gun-turret",
    stack_size = 50,
  },
}

-- recipes
data:extend {
  {
    type = "recipe",
    name = "loaded-gun-turret-firearm-magazine-x1",
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.firearm-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "firearm-magazine", aac } },
    result = "loaded-gun-turret-firearm-magazine-x1",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-firearm-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.firearm-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "firearm-magazine", aac * 2 } },
    result = "loaded-gun-turret-firearm-magazine-x2",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-piercing-rounds-magazine-x1",
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.piercing-rounds-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "piercing-rounds-magazine", aac } },
    result = "loaded-gun-turret-piercing-rounds-magazine-x1",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-piercing-rounds-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.piercing-rounds-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "piercing-rounds-magazine", aac * 2 } },
    result = "loaded-gun-turret-piercing-rounds-magazine-x2",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-uranium-rounds-magazine-x1",
    localised_name = { "loaded-turrets.gun-turret-name", aac, { "item-name.uranium-rounds-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "uranium-rounds-magazine", aac } },
    result = "loaded-gun-turret-uranium-rounds-magazine-x1",
  },
  {
    type = "recipe",
    name = "loaded-gun-turret-uranium-rounds-magazine-x2",
    localised_name = { "loaded-turrets.gun-turret-name", aac * 2, { "item-name.uranium-rounds-magazine" } },
    enabled = false,
    energy_required = 0.5,
    ingredients = { { "gun-turret", 1 }, { "electronic-circuit", 1 }, { "uranium-rounds-magazine", aac * 2 } },
    result = "loaded-gun-turret-uranium-rounds-magazine-x2",
  },
}

-- technologies
data:extend {
  {
    type = "technology",
    name = "loaded-turret",
    unit = {
      count = data.raw["technology"]["military-2"]["unit"]["count"],
      time = data.raw["technology"]["military-2"]["unit"]["time"],
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = "loaded-gun-turret-firearm-magazine-x1" }
    },
    prerequisites = { "gun-turret", "military-2" },
    icon = "__base__/graphics/technology/gun-turret.png", icon_size = 256, icon_mipmaps = 4,
    order = "a-j-a",
  },
  {
    type = "technology",
    name = "loaded-turret-2",
    unit = {
      count = data.raw["technology"]["military-3"]["unit"]["count"],
      time = data.raw["technology"]["military-3"]["unit"]["time"],
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
        { "military-science-pack",   1 },
      }
    },
    effects = {
      { type = "unlock-recipe", recipe = "loaded-gun-turret-firearm-magazine-x2" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-piercing-rounds-magazine-x1" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-piercing-rounds-magazine-x2" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-uranium-rounds-magazine-x1" },
      { type = "unlock-recipe", recipe = "loaded-gun-turret-uranium-rounds-magazine-x2" },
    },
    prerequisites = { "loaded-turret", "military-3" },
    icon = "__base__/graphics/technology/gun-turret.png", icon_size = 256, icon_mipmaps = 4,
    order = "a-j-a",
  },
}

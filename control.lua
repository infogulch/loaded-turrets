---@class LTGlobal
---@field insert_on_tick {[integer]:[{entity:LuaEntity,unit_number:integer,items:ItemStackDefinition}]}
---@field pending_unit_tick {[integer]:integer}
global = global

local function init()
  global.insert_on_tick = global.insert_on_tick or {}
  global.pending_unit_tick = global.pending_unit_tick or {}
end

script.on_init(init)
script.on_configuration_changed(init)

script.on_event(defines.events.on_tick, function(event)
  local tasks = global.insert_on_tick[event.tick]
  if not tasks then return end
  for _, task in pairs(tasks) do
    if task.entity.valid then
      local actual = task.entity.insert(task.items)
      if actual < task.items.count then
        task.items.count = task.items.count - actual
        task.entity.surface.spill_item_stack(task.entity.position, task.items)
      end
    end
    global.pending_unit_tick[task.unit_number] = nil
  end
  global.insert_on_tick[event.tick] = nil
end)

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.on_entity_cloned|EventData.script_raised_revive
function built(event)
  local entity = event.created_entity or event.destination or event.entity
  local ammo_type, count = entity.name:match('^loaded[-]turrets_.*_(.*)_(%d+)$')
  if ammo_type then
    -- don't insert into a cloned entity unless the source is also pending
    if event.name == defines.events.on_entity_cloned and not global.pending_unit_tick[event.source.unit_number] then return end
    local tick = event.tick + settings.global["loaded-turrets-load-delay-in-ticks"].value
    local list = global.insert_on_tick[tick]
    if not list then
      list = {}
      global.insert_on_tick[tick] = list
    end
    global.pending_unit_tick[entity.unit_number] = tick
    table.insert(list, {
      entity = entity,
      unit_number = entity.unit_number,
      items = { name = ammo_type, count = tonumber(count) }
    })
  end
end

script.on_event(defines.events.on_built_entity, built, { { filter = "turret" } })
script.on_event(defines.events.on_robot_built_entity, built, { { filter = "turret" } })
script.on_event(defines.events.on_entity_cloned, built, { { filter = "turret" } })
script.on_event(defines.events.script_raised_revive, built, { { filter = "turret" } })

---@param event EventData.on_player_mined_entity|EventData.on_robot_mined_entity
function mined(event)
  local unit_number = event.entity.unit_number or 0
  local tick = global.pending_unit_tick[unit_number]
  if not tick then return end
  local tasks = global.insert_on_tick[tick]
  for i, task in pairs(tasks) do
    if task.unit_number == unit_number then
      event.buffer.insert(task.items)
      tasks[i] = nil
      global.pending_unit_tick[unit_number] = nil
      return
    end
  end
end

script.on_event(defines.events.on_player_mined_entity, mined, { { filter = "turret" } })
script.on_event(defines.events.on_robot_mined_entity, mined, { { filter = "turret" } })

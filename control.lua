---@class LTGlobal
---@field insert_on_tick {[integer]:[{entity:LuaEntity,unit_number:integer,items:ItemStackDefinition}]}
---@field pending_unit_tick {[integer]:integer}
global = { insert_on_tick = {}, pending_unit_tick = {} }

script.on_event(defines.events.on_tick,
    function(event)
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
    end
)

script.on_event(defines.events.on_built_entity, function(event)
    local ammo_type, count = event["item"]["name"]:match('^loaded[-]gun[-]turret[-](.*[-]magazine)[-]x(%d+)$')
    if ammo_type then
        local tick = event.tick + settings.global["loaded-turrets-load-delay-in-ticks"].value
        local list = global.insert_on_tick[tick]
        if not list then
            list = {}
            global.insert_on_tick[tick] = list
        end
        global.pending_unit_tick[event.created_entity.unit_number] = tick
        table.insert(list, {
            entity = event.created_entity,
            unit_number = event.created_entity.unit_number,
            items = { name = ammo_type, count = tonumber(count) * event.created_entity.prototype.automated_ammo_count }
        })
    end
end, { { filter = "turret" } })

script.on_event(defines.events.on_player_mined_entity, function(event)
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
end, { { filter = "turret" } })

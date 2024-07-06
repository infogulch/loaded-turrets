global.insert_on_tick = {}
global.pending_unit_tick = {}

function mt()
    setmetatable(global.insert_on_tick, {
        __index = function(t, k)
            local v = {}
            t[k] = v
            return v
        end
    })
end

script.on_load(mt)
mt()

script.on_event(defines.events.on_tick,
    function(event)
        local tasks = rawget(global.insert_on_tick, event.tick)
        if not tasks then return end
        for _, task in pairs(tasks) do
            if task.entity.valid then
                task.entity.insert(task.items)
                -- TODO: what if inserted less than count?
            end
            global.pending_unit_tick[task.unit_number] = nil
        end
        global.insert_on_tick[event.tick] = nil
    end
)

script.on_event(defines.events.on_built_entity, function(event)
    local ammo_type, count = event["item"]["name"]:match('^loaded[-]gun[-]turret[-](.*[-]magazine)[-]x(%d+)$')
    if ammo_type then
        local tick = event.tick + 90
        global.pending_unit_tick[event.created_entity.unit_number] = tick
        table.insert(global.insert_on_tick[tick], {
            entity = event.created_entity,
            unit_number = event.created_entity.unit_number,
            items = { name = ammo_type, count = tonumber(count) * event.created_entity.prototype.automated_ammo_count }
        })
    end
end, { { filter = "turret" } })

script.on_event(defines.events.on_player_mined_entity, function(event)
    local tick = global.pending_unit_tick[event.entity.unit_number]
    if not tick then return end
    local unit_number = event.unit_number
    local tasks = rawget(global.insert_on_tick, tick)
    for i, task in pairs(tasks) do
        if task.entity.unit_number == unit_number then
            event.buffer.insert(task.items)
            tasks[i] = nil
            global.pending_unit_tick[event.entity.unit_number] = nil
            return
        end
    end
end, { { filter = "turret" } })

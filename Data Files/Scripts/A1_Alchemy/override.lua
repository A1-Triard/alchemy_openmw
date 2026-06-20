local I = require('openmw.interfaces')
local types = require('openmw.types')
local world = require('openmw.world')

I.ItemUsage.addHandlerForType(types.Apparatus, function(object, actor)
    actor:sendEvent("OpenA1Alchemy", { apparatus = object })
    return false
end)

return {
    eventHandlers = {
        A1AlchemyPotion = function(data)
            if data.id then
                local o = world.createObject(data.id, data.count)
                o:moveInto(types.Actor.inventory(data.player))
            end
            local ingr1 = data.ingr1
            ingr1:remove(1)
            local ingr2 = data.ingr2
            ingr2:remove(1)
        end,
    },
}

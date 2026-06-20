local I = require('openmw.interfaces')
local types = require('openmw.types')
local world = require('openmw.world')
local core = require('openmw.core')
local async = require('openmw.async')

I.ItemUsage.addHandlerForType(types.Apparatus, function(object, actor)
    actor:sendEvent("OpenA1Alchemy", { apparatus = object })
    return false
end)

local alchemyBookIndex = 0

return {
    engineHandlers = {
        onSave = function()
            return alchemyBookIndex
        end,
        onLoad = function(data)
            if data then
                alchemyBookIndex = data
            end
        end,
    },
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
        A1AlchemySkill = function(data)
            local bookId = 'A1_AlchemyBook' .. alchemyBookIndex
            alchemyBookIndex = alchemyBookIndex + 1
            local bookRecordDraft = types.Book.createRecordDraft({
                enchant = nil,
                enchantCapacity = 0,
                icon = 'icons\\m\\tx_scroll_open_01.tga',
                id = bookId,
                isScroll = true,
                model = 'meshes\\m\\text_scroll_01.nif',
                mwscript = nil,
                name = 'Навык алхимии вырос',
                skill = 'alchemy',
                text
                    =  '<DIV ALIGN="LEFT"><FONT COLOR="000000" SIZE="3" FACE="Magic Cards"><BR>'
                    .. 'Ваш навык алхимии вырос.<BR>',
                value = 0,
                weight = 0,
            })
            local bookRecord = world.createRecord(bookRecordDraft)
            local book = world.createObject(bookRecord.id)
            book:moveInto(types.Actor.inventory(data.player))
            core.sendGlobalEvent('UseItem', { object = book, actor = data.player, force = true })
            async:newUnsavableSimulationTimer(0, function()
                book:remove(1)
            end)
        end,
    },
}

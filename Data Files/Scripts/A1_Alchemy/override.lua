local I = require('openmw.interfaces')
local types = require('openmw.types')

I.ItemUsage.addHandlerForType(types.Apparatus, function(object, actor)
    if I.UiMode then
        I.UiMode.setMode(I.UiMode.getMode()) 
    end
    if I.ItemSelection and I.ItemSelection.getSelectedObject then
        local selectedObj = I.ItemSelection.getSelectedObject()
        if selectedObj and selectedObj == object then
            I.ItemSelection.setSelectedObject(nil)
        end
    end
    actor:sendEvent("OpenA1Alchemy", { apparatus = object })
    return false
end)

return {
}

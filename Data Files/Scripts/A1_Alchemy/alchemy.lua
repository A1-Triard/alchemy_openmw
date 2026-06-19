local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local util = require('openmw.util') 
local async = require('openmw.async')
local input = require('openmw.input')

local function createButton(text, textMinWidth, textTemplate, click, mouseMove)
    return {
        template = I.MWUI.templates.boxThick,
        events = {
            mouseClick = async:callback(click),
            mouseMove = async:callback(mouseMove),
        },
        content = ui.content({
            {
                template = I.MWUI.templates.padding,
                content = ui.content({
                    {
                        type = ui.TYPE.Flex,
                        props = {
                            horizontal = false,
                            arrange = ui.ALIGNMENT.Center,
                        },
                        content = ui.content({
                            {
                                type = ui.TYPE.Widget,
                                props = {
                                    size = util.vector2(textMinWidth, 0),
                                },
                            },
                            {
                                template = textTemplate,
                                props = {
                                    text = text,
                                },
                            },
                        })
                    },
                }),
            }
        }),
    }
end

local alchemyMenu = nil
local alchemyMenuCreateButtonHovered = false

local function closeAlchemyMenu()
    if alchemyMenu then
        alchemyMenu:destroy()
        alchemyMenu = nil
        I.UI.setMode(nil)
        I.UI.setMode('Interface')
        return true
    else
        return false
    end
end

local updateAlchemyMenu = nil

local function createAlchemyMenu(hoverCreateButton)
    local createButtonTemplate
    if hoverCreateButton then
        createButtonTemplate = I.MWUI.templates.textHeader
    else
        createButtonTemplate = I.MWUI.templates.textNormal
    end
    return {
        layer = 'Windows',
        template = I.MWUI.templates.boxTransparentThick,
        props = {
            relativePosition = util.vector2(0.5, 0.5),
            anchor = util.vector2(0.5, 0.5),
        }, 
        events = {
            mouseMove = async:callback(function(e)
                updateAlchemyMenu(false)
            end),
        },
        content = ui.content({
            {
                template = I.MWUI.templates.padding,
                content = ui.content({
                    {
                        type = ui.TYPE.Flex,
                        props = {
                            horizontal = false,
                        },
                        content = ui.content({
                            {
                                template = I.MWUI.templates.box,
                                content = ui.content({
                                    {
                                        type = ui.TYPE.Widget,
                                        props = {
                                            size = util.vector2(400, 300),
                                        },
                                    },
                                }),
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                type = ui.TYPE.Flex,
                                props = {
                                    horizontal = true,
                                    align = ui.ALIGNMENT.End,
                                },
                                external = {
                                    stretch = 1,
                                },
                                content = ui.content({
                                    createButton('Создать', 80, createButtonTemplate, function()
                                    end, function(e)
                                        updateAlchemyMenu(true)
                                    end),
                                    {
                                        template = I.MWUI.templates.interval,
                                    },
                                    createButton('Отмена', 80, I.MWUI.templates.textHeader, function()
                                        closeAlchemyMenu()
                                    end, function(e)
                                    end),
                                }),
                            },
                        }),
                    },
                }),
            },
        }),
    }
end

updateAlchemyMenu = function(hoverCreateButton)
    if alchemyMenu and hoverCreateButton ~= alchemyMenuCreateButtonHovered then
        alchemyMenuCreateButtonHovered = hoverCreateButton
        alchemyMenu.layout = createAlchemyMenu(hoverCreateButton)
        alchemyMenu:update()
    end
end

local function openAlchemyMenu(data)
    closeAlchemyMenu()
    I.UI.setMode(nil)
    I.UI.setMode('Interface', { windows = { } })
    alchemyMenu = ui.create(createAlchemyMenu(false))
    alchemyMenuCreateButtonHovered = false
end

local function onKeyPress(key)
    if key.code == input.KEY.Escape then
        return closeAlchemyMenu()
    end
    return false
end

return {
    eventHandlers = {
        OpenA1Alchemy = openAlchemyMenu,
    },
    engineHandlers = {
        onKeyPress = onKeyPress,
    },
}


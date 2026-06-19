local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local util = require('openmw.util') 
local async = require('openmw.async')
local input = require('openmw.input')
local types = require('openmw.types')
local self = require('openmw.self')

local mortar = nil
local retort = nil
local alembic = nil
local calcinator = nil

local function findApparatus(apparatus)
    mortar = nil
    retort = nil
    alembic = nil
    calcinator = nil
    local inv = types.Actor.inventory(self.object)
    for _, item in ipairs(inv:getAll(types.Apparatus)) do
        local record = types.Apparatus.record(item)
        if record.type == types.Apparatus.TYPE.MortarPestle then
            if not mortar or types.Apparatus.record(mortar).quiality < record.quiality then
                mortar = item
            end
        elseif record.type == types.Apparatus.TYPE.Retort then
            if not retort or types.Apparatus.record(retort).quiality < record.quiality then
                retort = item
            end
        elseif record.type == types.Apparatus.TYPE.Alembic then
            if not alembic or types.Apparatus.record(alembic).quiality < record.quiality then
                alembic = item
            end
        else -- record.type == types.Apparatus.TYPE.Calcinator
            if not calcinator or types.Apparatus.record(calcinator).quiality < record.quiality then
                calcinator = item
            end
        end
    end
    local record = types.Apparatus.record(apparatus)
    if record.type == types.Apparatus.TYPE.MortarPestle then
        mortar = apparatus
    elseif record.type == types.Apparatus.TYPE.Retort then
        retort = apparatus
    elseif record.type == types.Apparatus.TYPE.Alembic then
        alembic = apparatus
    else -- record.type == types.Apparatus.TYPE.Calcinator
        calcinator = apparatus
    end
end

local function createApparatusTooltip(object, position)
    local quality = string.format('%.2f', types.Apparatus.record(object).quality)
    return {
        layer = 'Windows',
        template = I.MWUI.templates.boxSolid,
        props = {
            position = position,
            anchor = util.vector2(0.4, 0),
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
                                template = I.MWUI.templates.textHeader,
                                props = {
                                    text = types.Apparatus.record(object).name,
                                },
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                template = I.MWUI.templates.textNormal,
                                props = {
                                    text = 'Качество: ' .. quality,
                                },
                            },
                        }),
                    },
                }),
            },
        }),
    }
end

local apparatusTooltip = nil

local function updateApparatusTooltip(apparatus, position)
    if apparatus and apparatusTooltip then
        apparatusTooltip.layout = createApparatusTooltip(apparatus, position)
        apparatusTooltip:update()
    elseif apparatus then
        apparatusTooltip = ui.create(createApparatusTooltip(apparatus, position))
    elseif apparatusTooltip then
        apparatusTooltip:destroy()
        apparatusTooltip = nil
    end
end

local function createApparatusItem(object)
    local image
    if object then
        local icon = string.gsub(types.Apparatus.record(object).icon, '\\', '/')
        image = {
            type = ui.TYPE.Image,
            props = {
                size = util.vector2(32, 32),
                resource = ui.texture({
                    size = util.vector2(32, 32),
                    path = icon,
                }),
            },
        }
    else
        image = {
            type = ui.TYPE.Widget,
            props = {
                size = util.vector2(32, 32),
            },
        }
    end
    return {
        template = I.MWUI.templates.padding,
        events = {
            mouseMove = async:callback(function(e)
                updateApparatusTooltip(object, e.position + util.vector2(0, 30))
            end),
        },
        content = ui.content({
            image,
        }),
    }
end

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
        if apparatusTooltip then
            apparatusTooltip:destroy()
            apparatusTooltip = nil
        end
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
                updateApparatusTooltip(nil, util.vector2(0, 0))
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
                                template = I.MWUI.templates.textHeader,
                                props = {
                                    text = 'Аппарат',
                                },
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                type = ui.TYPE.Flex,
                                props = {
                                    horizontal = true,
                                },
                                content = ui.content({
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createApparatusItem(mortar),
                                        }),
                                    },
                                    {
                                        template = I.MWUI.templates.interval,
                                    },
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createApparatusItem(retort),
                                        }),
                                    },
                                    {
                                        template = I.MWUI.templates.interval,
                                    },
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createApparatusItem(alembic),
                                        }),
                                    },
                                    {
                                        template = I.MWUI.templates.interval,
                                    },
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createApparatusItem(calcinator),
                                        }),
                                    },
                                }),
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                template = I.MWUI.templates.textHeader,
                                props = {
                                    text = 'Ингридиенты',
                                },
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
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
    findApparatus(data.apparatus)
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


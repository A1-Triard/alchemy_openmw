local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local util = require('openmw.util') 
local async = require('openmw.async')
local input = require('openmw.input')
local types = require('openmw.types')
local self = require('openmw.self')
local core = require('openmw.core')

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
        layer = 'Notification',
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

local wortChanceValue = core.getGMST('fWortChanceValue')

local function createIngredientTooltip(object, position)
    local weight = string.format('%.1f', types.Ingredient.record(object).weight)
    local value = tostring(types.Ingredient.record(object).value)
    local alchemy = types.NPC.stats.skills.alchemy(self.object).modified
    local visibleEffectsCount = math.floor(alchemy / wortChanceValue)
    local info = {
        {
            template = I.MWUI.templates.textHeader,
            props = {
                text = types.Ingredient.record(object).name .. ' (' .. object.count .. ')',
            },
        },
        {
            template = I.MWUI.templates.interval,
        },
        {
            template = I.MWUI.templates.textNormal,
            props = {
                text = 'Вес: ' .. weight,
            },
        },
        {
            template = I.MWUI.templates.interval,
        },
        {
            template = I.MWUI.templates.textNormal,
            props = {
                text = 'Цена: ' .. value,
            },
        },
    }
    for n, e in ipairs(types.Ingredient.record(object).effects) do
        local name
        local icon
        if n <= visibleEffectsCount then
            name = e.effect.name
            icon = {
                type = ui.TYPE.Image,
                props = {
                    size = util.vector2(16, 16),
                    resource = ui.texture({
                        size = util.vector2(16, 16),
                        path = string.gsub(e.effect.icon, '\\', '/'),
                    }),
                },
            }
        else
            name = '?'
            icon = nil
        end
        table.insert(info, {
            template = I.MWUI.templates.interval,
        })
        if icon then
            table.insert(info, {
                type = ui.TYPE.Flex,
                props = {
                    horizontal = true,
                },
                content = ui.content({
                    icon,
                    {
                        template = I.MWUI.templates.interval,
                    },
                    {
                        template = I.MWUI.templates.textNormal,
                        props = {
                            text = name,
                        },
                    },
                }),
            })
        else
            table.insert(info, {
                template = I.MWUI.templates.textNormal,
                props = {
                    text = name,
                },
            })
        end
    end
    return {
        layer = 'Notification',
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
                        content = ui.content(info),
                    },
                }),
            },
        }),
    }
end

local function createTooltip(object, position)
    if types.Ingredient.objectIsInstance(object) then
        return createIngredientTooltip(object, position)
    else
        return createApparatusTooltip(object, position)
    end
end

local tooltip = nil
local tooltipType = nil
local tooltipPosition
local hideTooltipPosition = nil

local function updateTooltip(object, position)
    if object and tooltip then
        tooltipPosition = position + util.vector2(0, 30)
        if tooltipPosition == hideTooltipPosition then
            return
        end
        hideTooltipPosition = nil
        if object.type == tooltipType then
            tooltip.layout = createTooltip(object, tooltipPosition)
            tooltip:update()
        else
            tooltip:destroy()
            tooltip = ui.create(createTooltip(object, tooltipPosition))
            tooltipType = object.type
        end
    elseif object then
        tooltipPosition = position + util.vector2(0, 30)
        if tooltipPosition == hideTooltipPosition then
            return
        end
        hideTooltipPosition = nil
        tooltip = ui.create(createTooltip(object, tooltipPosition))
        tooltipType = object.type
    elseif tooltip then
        tooltip:destroy()
        tooltip = nil
    end
end

local function hideTooltip()
    hideTooltipPosition = tooltipPosition
    updateTooltip(nil, nil)
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
                updateTooltip(object, e.position)
            end),
        },
        content = ui.content({
            image,
        }),
    }
end

local ingredient1 = nil
local ingredient2 = nil

local updateAlchemyMenu = nil

local function createIngredientItem(object)
    local image
    if object then
        local icon = string.gsub(types.Ingredient.record(object).icon, '\\', '/')
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
                updateTooltip(object, e.position)
            end),
            mouseClick = async:callback(function()
                if object then
                    if ingredient1 == object then
                        ingredient1 = nil
                    else
                        ingredient2 = nil
                    end
                    hideTooltip()
                    updateAlchemyMenu(nil)
                end
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
        if tooltip then
            tooltip:destroy()
            tooltip = nil
            hideTooltipPosition = nil
        end
        alchemyMenu:destroy()
        alchemyMenu = nil
        ingredient1 = nil
        ingredient2 = nil
        mortar = nil
        retort = nil
        alembic = nil
        calcinator = nil
        I.UI.setMode(nil)
        I.UI.setMode('Interface')
        return true
    else
        return false
    end
end

local function createInventory()
    local ingrs = { }
    local inv = types.Actor.inventory(self.object)
    for _, item in ipairs(inv:getAll(types.Ingredient)) do
        if item ~= ingredient1 and item ~= ingredient2 then
            local icon = string.gsub(types.Ingredient.record(item).icon, '\\', '/')
            table.insert(ingrs, {
                template = I.MWUI.templates.padding,
                events = {
                    mouseMove = async:callback(function(e)
                        updateTooltip(item, e.position)
                    end),
                    mouseClick = async:callback(function()
                        if ingredient1 then
                            ingredient2 = item
                        else
                            ingredient1 = item
                        end
                        hideTooltip()
                        updateAlchemyMenu(nil)
                    end),
                },
                content = ui.content({
                    {
                        type = ui.TYPE.Image,
                        props = {
                            size = util.vector2(32, 32),
                            resource = ui.texture({
                                size = util.vector2(32, 32),
                                path = icon,
                            }),
                        },
                    },
                }),
            })
        end
    end
    return {
        type = ui.TYPE.Flex,
        props = {
            horizontal = false,
            size = util.vector2(400, 300),
            autoSize = false,
            wrap = true,
        },
        content = ui.content(ingrs),
    }
end

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
                updateTooltip(nil, nil)
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
                                type = ui.TYPE.Flex,
                                props = {
                                    horizontal = true,
                                },
                                content = ui.content({
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createIngredientItem(ingredient1),
                                        }),
                                    },
                                    {
                                        template = I.MWUI.templates.interval,
                                    },
                                    {
                                        template = I.MWUI.templates.box,
                                        content = ui.content({
                                            createIngredientItem(ingredient2),
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
                                    text = 'Инвентарь',
                                },
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                template = I.MWUI.templates.box,
                                content = ui.content({
                                    createInventory(),
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
        alchemyMenuCreateButtonHovered = hoverCreateButton == true
        alchemyMenu.layout = createAlchemyMenu(alchemyMenuCreateButtonHovered)
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


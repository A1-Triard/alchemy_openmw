local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local util = require('openmw.util') 
local async = require('openmw.async')
local input = require('openmw.input')
local types = require('openmw.types')
local self = require('openmw.self')
local core = require('openmw.core')
local ambient = require('openmw.ambient')

local function potion5(broken, cheap, standard, qualitative, exclusive)
    return {
        type = 5,
        broken = broken,
        cheap = cheap,
        standard = standard,
        qualitative = qualitative,
        exclusive = exclusive,
    }
end

local function potion1(standard, difficulty)
    return {
        type = 1,
        standard = standard,
        difficulty = difficulty,
    }
end

local potions = {
    ['restorehealth'] = potion5(
        'p_restore_health_b', 'p_restore_health_c', 'p_restore_health_s',
        'p_restore_health_q', 'p_restore_health_e'
    ),
    ['restorefatigue'] = potion5(
        'p_restore_fatigue_b', 'p_restore_fatigue_c', 'p_restore_fatigue_s',
        'p_restore_fatigue_q', 'p_restore_fatigue_e'
    ),
    ['restoremagicka'] = potion5(
        'p_restore_magicka_b', 'p_restore_magicka_c', 'p_restore_magicka_s',
        'p_restore_magicka_q', 'p_restore_magicka_e'
    ),
    ['waterwalking'] = potion5(
        'p_water_walking_b', 'p_water_walking_c', 'p_water_walking_s',
        'p_water_walking_q', 'p_water_walking_e'
    ),
    ['waterbreathing'] = potion5(
        'p_water_breathing_b', 'p_water_breathing_c', 'p_water_breathing_s',
        'p_water_breathing_q', 'p_water_breathing_e'
    ),
    ['levitate'] = potion5(
        'p_levitation_b', 'p_levitation_c', 'p_levitation_s',
        'p_levitation_q', 'p_levitation_e'
    ),
    ['telekinesis'] = potion5(
        'p_telekinesis_b', 'p_telekinesis_c', 'p_telekinesis_s',
        'p_telekinesis_q', 'p_telekinesis_e'
    ),
    ['cureblightdisease'] = potion1('p_cure_blight_s', 200),
    ['curecommondisease'] = potion1('p_cure_common_s', 400),
    ['detectkey'] = potion5(
        'p_detect_key_b', 'p_detect_key_c', 'p_detect_key_s', 'p_detect_key_q', 'p_detect_key_e'
    ),
    ['curepoison'] = potion1('p_cure_poison_s', 400),
    ['feather'] = potion5('p_feather_b', 'p_feather_c', 'p_feather_s', 'p_feather_q', 'p_feather_e'),
    ['resistfire'] = potion5(
        'p_fire_resistance_b', 'p_fire_resistance_c', 'p_fire resistance_s',
        'p_fire_resistance_q', 'p_fire_resistance_e'
    ),
    ['restoreattribute:personality'] = potion5(
        'p_restore_personality_b', 'p_restore_personality_c', 'p_restore_personality_s',
        'p_restore_personality_q', 'p_restore_personality_e'
    ),
    ['fortifymagicka'] = potion5(
        'p_fortify_magicka_b', 'p_fortify_magicka_c', 'p_fortify_magicka_s',
        'p_fortify_magicka_q', 'p_fortify_magicka_e'
    ),
    ['nighteye'] = potion5(
        'p_night-eye_b', 'p_night-eye_c', 'p_night-eye_s', 'p_night-eye_q', 'p_night-eye_e'
    ),
    ['detectanimal'] = potion5(
        'p_detect_creatures_b', 'p_detect_creatures_c', 'p_detect_creatures_s',
        'p_detect_creatures_q', 'p_detect_creatures_e'
    ),
    ['cureparalyzation'] = potion1('p_cure_paralyzation_s', 400),
    ['detectenchantment'] = potion5(
        'p_detect_enchantment_b', 'p_detect_enchantment_c', 'p_detect_enchantment_s',
        'p_detect_enchantment_q', 'p_detect_enchantment_e'
    ),
    ['dispel'] = potion5('p_dispel_b', 'p_dispel_c', 'p_dispel_s', 'p_dispel_q', 'p_dispel_e'),
    ['fireshield'] = potion5(
        'p_fire_shield_b', 'p_fire_shield_c', 'p_fire_shield_s', 'p_fire_shield_q', 'p_fire_shield_e'
    ),
    ['fortifyattribute:agility'] = potion5(
        'p_fortify_agility_b', 'p_fortify_agility_c', 'p_fortify_agility_s',
        'p_fortify_agility_q', 'p_fortify_agility_e'
    ),
    ['fortifyattackbonus'] = potion5(
        'p_fortify_attack_b', 'p_fortify_attack_c', 'p_fortify_attack_s',
        'p_fortify_attack_q', 'p_fortify_attack_e'
    ),
    ['fortifyattribute:endurance'] = potion5(
        'p_fortify_endurance_b', 'p_fortify_endurance_c', 'p_fortify_endurance_s',
        'p_fortify_endurance_q', 'p_fortify_endurance_e'
    ),
    ['fortifyfatigue'] = potion5(
        'p_fortify_fatigue_b', 'p_fortify_fatigue_c', 'p_fortify_fatigue_s',
        'p_fortify_fatigue_q', 'p_fortify_fatigue_e'
    ),
    ['fortifyhealth'] = potion5(
        'p_fortify_health_b', 'p_fortify_health_c', 'p_fortify_health_s',
        'p_fortify_health_q', 'p_fortify_health_e'
    ),
    ['fortifyattribute:intelligence'] = potion5(
        'p_fortify_intelligence_b', 'p_fortify_intelligence_c', 'p_fortify_intelligence_s',
        'p_fortify_intelligence_q', 'p_fortify_intelligence_e'
    ),
    ['fortifyattribute:luck'] = potion5(
        'p_fortify_luck_b', 'p_fortify_luck_c', 'p_fortify_luck_s', 'p_fortify_luck_q', 'p_fortify_luck_e'
    ),
    ['fortifyattribute:personality'] = potion5(
        'p_fortify_personality_b', 'p_fortify_personality_c', 'p_fortify_personality_s',
        'p_fortify_personality_q', 'p_fortify_personality_e'
    ),
    ['fortifyattribute:speed'] = potion5(
        'p_fortify_speed_b', 'p_fortify_speed_c', 'p_fortify_speed_s',
        'p_fortify_speed_q', 'p_fortify_speed_e'
    ),
    ['fortifyattribute:strength'] = potion5(
        'p_fortify_strength_b', 'p_fortify_strength_c', 'p_fortify_strength_s',
        'p_fortify_strength_q', 'p_fortify_strength_e'
    ),
    ['fortifyattribute:willpower'] = potion5(
        'p_fortify_willpower_b', 'p_fortify_willpower_c', 'p_fortify_willpower_s',
        'p_fortify_willpower_q', 'p_fortify_willpower_e'
    ),
    ['resistfrost'] = potion5(
        'p_frost_resistance_b', 'p_frost_resistance_c', 'p_frost_resistance_s',
        'p_frost_resistance_q', 'p_frost_resistance_e'
    ),
    ['frostshield'] = potion5(
        'p_frost_shield_b', 'p_frost_shield_c', 'p_frost_shield_s', 'p_frost_shield_q', 'p_frost_shield_e'
    ),
    ['invisibility'] = potion5(
        'p_invisibility_b', 'p_invisibility_c', 'p_invisibility_s', 'p_invisibility_q', 'p_invisibility_e'
    ),
    ['lightningshield'] = potion5(
        'p_lightning shield_b', 'p_lightning shield_c', 'p_lightning shield_s',
        'p_lightning shield_q', 'p_lightning shield_e'
    ),
    ['resistmagicka'] = potion5(
        'p_magicka_resistance_b', 'p_magicka_resistance_c', 'p_magicka_resistance_s',
        'p_magicka_resistance_q', 'p_magicka_resistance_e'
    ),
    ['resistpoison'] = potion5(
        'p_poison_resistance_b', 'p_poison_resistance_c', 'p_poison_resistance_s',
        'p_poison_resistance_q', 'p_poison_resistance_e'
    ),
    ['reflect'] = potion5(
        'p_reflection_b', 'p_reflection_c', 'p_reflection_s', 'p_reflection_q', 'p_reflection_e'
    ),
    ['restoreattribute:agility'] = potion5(
        'p_restore_agility_b', 'p_restore_agility_c', 'p_restore_agility_s',
        'p_restore_agility_q', 'p_restore_agility_e'
    ),
    ['restoreattribute:endurance'] = potion5(
        'p_restore_endurance_b', 'p_restore_endurance_c', 'p_restore_endurance_s',
        'p_restore_endurance_q', 'p_restore_endurance_e'
    ),
    ['restoreattribute:intelligence'] = potion5(
        'p_restore_intelligence_b', 'p_restore_intelligence_c', 'p_restore_intelligence_s',
        'p_restore_intelligence_q', 'p_restore_intelligence_e'
    ),
    ['restoreattribute:luck'] = potion5(
        'p_restore_luck_b', 'p_restore_luck_c', 'p_restore_luck_s', 'p_restore_luck_q', 'p_restore_luck_e'
    ),
    ['restoreattribute:speed'] = potion5(
        'p_restore_speed_b', 'p_restore_speed_c', 'p_restore_speed_s', 'p_restore_speed_q', 'p_restore_speed_e'
    ),
    ['restoreattribute:strength'] = potion5(
        'p_restore_strength_b', 'p_restore_strength_c', 'p_restore_strength_s',
        'p_restore_strength_q', 'p_restore_strength_e'
    ),
    ['restoreattribute:willpower'] = potion5(
        'p_restore_willpower_b', 'p_restore_willpower_c', 'p_restore_willpower_s',
        'p_restore_willpower_q', 'p_restore_willpower_e'
    ),
    ['spellabsorption'] = potion5(
        'p_spell_absorption_b', 'p_spell_absorption_c', 'p_spell_absorption_s',
        'p_spell_absorption_q', 'p_spell_absorption_e'
    ),
    ['swiftswim'] = potion5(
        'p_swift_swim_b', 'p_swift_swim_c', 'p_swift_swim_s', 'p_swift_swim_q', 'p_swift_swim_e'
    ),
    ['mark'] = potion1('p_mark_s', 400),
    ['recall'] = potion1('p_recall_s', 100),
    ['resistcommondisease'] = potion5(
        'p_disease_resistance_b', 'p_disease_resistance_c', 'p_disease_resistance_s',
        'p_disease_resistance_q', 'p_disease_resistance_e'
    ),
    ['shield'] = potion5('p_silence_b', 'p_silence_c', 'p_silence_s', 'p_silence_q', 'p_silence_e'),
    ['jump'] = potion5('p_jump_b', 'p_jump_c', 'p_jump_s', 'p_jump_q', 'p_jump_e'),
    ['slowfall'] = potion5('p_slowfall_b', 'p_slowfall_c', 'p_slowfall_s', 'p_slowfall_q', 'p_slowfall_e'),
    ['chameleon'] = potion5(
        'p_chameleon_b', 'p_chameleon_c', 'p_chameleon_s', 'p_chameleon_q', 'p_chameleon_e'
    ),
    ['light'] = potion5('p_light_b', 'p_light_c', 'p_light_s', 'p_light_q', 'p_light_e'),
    ['sanctuary'] = potion5(
        'p_sanctuary_b', 'p_sanctuary_c', 'p_sanctuary_s', 'p_sanctuary_q', 'p_sanctuary_e'
    ),
    ['almsiviintervention'] = potion1('p_almsivi_intervention_s', 100),
    ['resistshock'] = potion5(
        'p_shock_resistance_b', 'p_shock_resistance_c', 'p_shock_resistance_s',
        'p_shock_resistance_q', 'p_shock_resistance_e'
    ),
    ['resistblightdisease'] = potion5(
        'p_blight_resistance_b', 'p_blight_resistance_c', 'p_blight_resistance_s',
        'p_blight_resistance_q', 'p_blight_resistance_e'
    ),
    ['resistnormalweapons'] = potion5('p_burden_b', 'p_burden_c', 'p_burden_s', 'p_burden_q', 'p_burden_e'),
    ['resistparalysis'] = potion5(
        'p_paralyze_b', 'p_paralyze_c', 'p_paralyze_s', 'p_paralyze_q', 'p_paralyze_e'
    ),
    ['summoncenturionsphere'] = potion5(
        'p_summon_centurion_sphere_b', 'p_summon_centurion_sphere_c', 'p_summon_centurion_sphere_s',
        'p_summon_centurion_sphere_q', 'p_summon_centurion_sphere_e'
    ),
}

local function potion(effect)
    local id = effect.effect.id
    if id == 'restoreattribute' or id == 'fortifyattribute' then
        id = id .. ':' .. effect.affectedAttribute
    end
    return potions[id]
end

local function alchemy()
    local alchemy = types.NPC.stats.skills.alchemy(self.object).modified
    local luck = types.Actor.stats.attributes.luck(self.object).modified
    local int = types.Actor.stats.attributes.intelligence(self.object).modified
    return alchemy + 0.1 * (int + luck)
end

local function mortarValue(quality)
    if quality < 0.75 then
        return 50
    elseif quality < 1.1 then
        return 68
    elseif quality < 1.35 then
        return 86
    else
        return 104
    end
end

local function retortValue(quality)
    if quality < 0.25 then
        return 50
    elseif quality < 0.75 then
        return 62
    elseif quality < 1.1 then
        return 75
    elseif quality < 1.35 then
        return 87
    else
        return 100
    end
end

local function alembicValue(quality)
    if quality < 0.1 then
        return 41
    elseif quality < 0.75 then
        return 59
    elseif quality < 1.1 then
        return 77
    elseif quality < 1.35 then
        return 95
    else
        return 113
    end
end

local function calcinatorValue(quality)
    if quality < 0.25 then
        return 0
    elseif quality < 0.75 then
        return 3
    elseif quality < 1.1 then
        return 6
    elseif quality < 1.35 then
        return 10
    else
        return 20
    end
end

local function makePotion5(mortar, retort, alembic, calcinator)
    local alch = alchemy()
    if alch < retort then
        retort = alch
    end
    alch = alch + calcinator
    if alch < mortar then
        mortar = alch
    end
    if alch < alembic then
        alembic = alch
    end
    alembic = alembic - 9
    if alembic > mortar then
        alembic = mortar
    end
    if alembic < 15 then
        return { res = 0, train = 0 }
    end
    if math.random() * 100 >= retort then
        return { res = 0, train = 0 }
    end
    alch = alembic + math.random() * (mortar + 1 - alembic)
    if alch < 33 then
        return { res = 1, train = 1 }
    elseif alch < 51 then
        return { res = 2, train = 1 }
    elseif alch < 69 then
        return { res = 3, train = 1 }
    elseif alch < 87 then
        return { res = 4, train = 1 }
    else
        return { res = 5, train = 1 }
    end
end

local function makePotion1(mortar, retort, alembic, calcinator, difficulty)
    local alch = alchemy()
    if alch < retort then
        retort = alch
    end
    alch = alch + calcinator
    if alch < mortar then
        mortar = alch
    end
    if alch < alembic then
        alembic = alch
    end
    alembic = alembic - 9
    if alembic > mortar then
        alembic = mortar
    end
    if alembic < 15 then
        return { res = 0, train = 0 }
    end
    if math.random() * 100 >= retort then
        return { res = 0, train = 0 }
    end
    alch = alembic + math.random() * (mortar + 1 - alembic)
    if alch < 33 then
        alch = 16
    elseif alch < 51 then
        alch = 8
    elseif alch < 69 then
        alch = 4
    elseif alch < 87 then
        alch = 2
    else
        alch = 1
    end
    alch = difficulty / alch
    local train = 100 / alch
    local res = 0
    if alch >= 100 then
        alch = alch - 100
        res = 1
    end
    if math.random() * 100 < alch then
        res = res + 1
    end
    return { res = res, train = train }
end

local function commonEffects(ingr1, ingr2)
    if ingr1.icon == ingr2.icon then
        return { }
    end
    local res = { }
    for n1, e1 in ipairs(ingr1.effects) do
        for n2, e2 in ipairs(ingr2.effects) do
            if
                    e1.effect.id == e2.effect.id
                and e1.affectedSkill == e2.affectedSkill
                and e1.affectedAttribute == e2.affectedAttribute
            then
                table.insert(res, { effect = e1, level = math.max(n1, n2) })
            end
        end
    end
    return res
end

local negativeEffects = {
    ['burden'] = true,
    ['firedamage'] = true,
    ['shockdamage'] = true,
    ['frostdamage'] = true,
    ['drainattribute'] = true,
    ['drainhealth'] = true,
    ['drainmagicka'] = true,
    ['drainfatigue'] = true,
    ['drainskill'] = true,
    ['damageattribute'] = true,
    ['damagehealth'] = true,
    ['damagemagicka'] = true,
    ['damagefatigue'] = true,
    ['damageskill'] = true,
    ['poison'] = true,
    ['weaknesstofire'] = true,
    ['weaknesstofrost'] = true,
    ['weaknesstoshock'] = true,
    ['weaknesstomagicka'] = true,
    ['weaknesstocommondisease'] = true,
    ['weaknesstoblightdisease'] = true,
    ['weaknesstocorprusdisease'] = true,
    ['weaknesstopoison'] = true,
    ['weaknesstonormalweapons'] = true,
    ['disintegrateweapon'] = true,
    ['disintegratearmor'] = true,
    ['paralyze'] = true,
    ['silence'] = true,
    ['blind'] = true,
    ['sound'] = true,
    ['stuntedmagicka'] = true,
}

local function isNegativeEffect(e)
    if negativeEffects[e.id] then
        return true
    else
        return false
    end
end

local trainAlchemy = nil

local mortar = nil
local retort = nil
local alembic = nil
local calcinator = nil

local function makePotion(effect, ingr1, ingr2)
    local p = potion(effect)
    local m
    if mortar then
        m = types.Apparatus.record(mortar).quality
    else
        m = 0
    end
    local r
    if retort then
        r = types.Apparatus.record(retort).quality
    else
        r = 0
    end
    local a
    if alembic then
        a = types.Apparatus.record(alembic).quality
    else
        a = 0
    end
    local c
    if calcinator then
        c = types.Apparatus.record(calcinator).quality
    else
        c = 0
    end
    m = mortarValue(m)
    r = retortValue(r)
    a = alembicValue(a)
    c = calcinatorValue(c)
    if ingr1.count == 0 or ingr2.count == 0 then
        ui.showMessage('Недостаточно ингредиентов')
        return
    end
    if p.type == 1 then
        local x = makePotion1(m, r, a, c, p.difficulty)
        local count = x.res
        local train = x.train
        if count == 0 then
            core.sendGlobalEvent('A1AlchemyPotion', {
                player = self.object, id = nil, count = 0, ingr1 = ingr1, ingr2 = ingr2
            })
            ui.showMessage('Вам не удалось создать зелье')
            ambient.playSound('potion fail', nil)
        else
            core.sendGlobalEvent('A1AlchemyPotion', {
                player = self.object, id = p.standard, count = count, ingr1 = ingr1, ingr2 = ingr2
            })
            ui.showMessage('Вы создали зелье')
            ambient.playSound('potion success', nil)
            trainAlchemy(train)
        end
    else
        local x = makePotion5(m, r, a, c)
        local quality = x.res
        local train = x.train
        if quality == 0 then
            core.sendGlobalEvent('A1AlchemyPotion', {
                player = self.object, id = nil, count = 0, ingr1 = ingr1, ingr2 = ingr2
            })
            ui.showMessage('Вам не удалось создать зелье')
            ambient.playSound('potion fail', nil)
        else
            local id
            if quality == 1 then
                id = p.broken
            elseif quality == 2 then
                id = p.cheap
            elseif quality == 3 then
                id = p.standard
            elseif quality == 4 then
                id = p.qualitative
            else
                id = p.exclusive
            end
            core.sendGlobalEvent('A1AlchemyPotion', {
                player = self.object, id = id, count = 1, ingr1 = ingr1, ingr2 = ingr2
            })
            ui.showMessage('Вы создали зелье')
            ambient.playSound('potion success', nil)
            trainAlchemy(train)
        end
    end
end

local function findApparatus(apparatus)
    mortar = nil
    retort = nil
    alembic = nil
    calcinator = nil
    local inv = types.Actor.inventory(self.object)
    for _, item in ipairs(inv:getAll(types.Apparatus)) do
        local record = types.Apparatus.record(item)
        if record.type == types.Apparatus.TYPE.MortarPestle then
            if not mortar or types.Apparatus.record(mortar).quality < record.quality then
                mortar = item
            end
        elseif record.type == types.Apparatus.TYPE.Retort then
            if not retort or types.Apparatus.record(retort).quality < record.quality then
                retort = item
            end
        elseif record.type == types.Apparatus.TYPE.Alembic then
            if not alembic or types.Apparatus.record(alembic).quality < record.quality then
                alembic = item
            end
        else -- record.type == types.Apparatus.TYPE.Calcinator
            if not calcinator or types.Apparatus.record(calcinator).quality < record.quality then
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

local attributes = {
    ['agility'] = 'Ловкость',
    ['endurance'] = 'Выносливость',
    ['intelligence'] = 'Интеллект',
    ['luck'] = 'Удача',
    ['personality'] = 'Привлекательность',
    ['speed'] = 'Скорость',
    ['strength'] = 'Сила',
    ['willpower'] = 'Сила воли',
}

local function attributeName(attr)
    return attributes[attr]
end

local function effectName(effect)
    if effect.effect.id == 'restoreattribute' then
        return 'Восстановить: ' .. attributeName(effect.affectedAttribute)
    elseif effect.effect.id == 'fortifyattribute' then
        return 'Увеличить: ' .. attributeName(effect.affectedAttribute)
    elseif effect.effect.id == 'damageattribute' then
        return 'Отнять: ' .. attributeName(effect.affectedAttribute)
    elseif effect.effect.id == 'drainattribute' then
        return 'Уменьшить: ' .. attributeName(effect.affectedAttribute)
    else
        return effect.effect.name
    end
end

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
            name = effectName(e)
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
                    arrange = ui.ALIGNMENT.Center,
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
        },
        content = ui.content({
            image,
        }),
    }
end

local function createButton(content, contentMinWidth, click, mouseMove)
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
                                    size = util.vector2(contentMinWidth, 0),
                                },
                            },
                            content,
                        })
                    },
                }),
            }
        }),
    }
end

local alchemyMenu = nil
local alchemyMenuCreateButtonHovered = -1

local function closeAlchemyMenu()
    if alchemyMenu then
        if tooltip then
            tooltip:destroy()
            tooltip = nil
            hideTooltipPosition = nil
        end
        alchemyMenu:destroy()
        alchemyMenu = nil
        alchemyMenuCreateButtonHovered = -1
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

local alchemyProgress = 0

trainAlchemy = function(train)
    local alch = alchemy()
    if alch < 2 then
        alch = 2
    end
    alchemyProgress = alchemyProgress + 200 * train / alch
    if alchemyProgress > 100 then
        alchemyProgress = 0
        closeAlchemyMenu()
        core.sendGlobalEvent('A1AlchemySkill', { player = self.object })
    end
end

local function scan()
    local res = { }
    local inv = types.Actor.inventory(self.object)
    local ingrs = inv:getAll(types.Ingredient)
    for _, ingr1 in ipairs(ingrs) do
        for _, ingr2 in ipairs(ingrs) do
            if types.Ingredient.record(ingr2).id > types.Ingredient.record(ingr1).id then
                local effects = commonEffects(types.Ingredient.record(ingr1), types.Ingredient.record(ingr2))
                local hasNegativeEffects = false
                for _, e in ipairs(effects) do
                    if isNegativeEffect(e.effect.effect) then
                        hasNegativeEffects = true
                        break
                    end
                end
                if not hasNegativeEffects then
                    for _, e in ipairs(effects) do
                        table.insert(res, { ingr1 = ingr1, ingr2 = ingr2, effect = e.effect, level = e.level })
                    end
                end
            end
        end
    end
    table.sort(res, function(a, b) return a.level < b.level end)
    return res
end

local function split(a, n)
    local res = { }
    local cur = { }
    for _, x in ipairs(a) do
        table.insert(cur, x)
        if #cur >= n then
            table.insert(res, cur)
            cur = { }
        end
    end
    if #cur ~= 0 then
        table.insert(res, cur)
    end
    return res
end

local function createAlchemyList(scanRes, bi, hoverCreateButton)
    local alchemy = types.NPC.stats.skills.alchemy(self.object).modified
    local visibleEffectsCount = math.floor(alchemy / wortChanceValue)
    local res = { }
    for i, e in ipairs(scanRes) do
        local buttonIndexCopy = bi.buttonIndex
        local createButtonTemplate
        if hoverCreateButton == bi.buttonIndex then
            createButtonTemplate = I.MWUI.templates.textHeader
        else
            createButtonTemplate = I.MWUI.templates.textNormal
        end
        local name
        local icon
        if e.level <= visibleEffectsCount then
            name = effectName(e.effect)
            icon = {
                type = ui.TYPE.Image,
                props = {
                    size = util.vector2(16, 16),
                    resource = ui.texture({
                        size = util.vector2(16, 16),
                        path = string.gsub(e.effect.effect.icon, '\\', '/'),
                    }),
                },
            }
        else
            name = '?'
            icon = nil
        end
        local effectInfo
        if icon then
            effectInfo = {
                type = ui.TYPE.Flex,
                props = {
                    horizontal = true,
                    arrange = ui.ALIGNMENT.Center,
                },
                content = ui.content({
                    icon,
                    {
                        template = I.MWUI.templates.interval,
                    },
                    {
                        template = createButtonTemplate,
                        props = {
                            text = name,
                        },
                    },
                }),
            }
        else
            effectInfo = {
                template = createButtonTemplate,
                props = {
                    text = name,
                },
            }
        end
        if i ~= 1 then
            table.insert(res, {
                template = I.MWUI.templates.interval,
            })
        end
        local effectCopy = e.effect
        local ingr1Copy = e.ingr1
        local ingr2Copy = e.ingr2
        table.insert(res, {
            type = ui.TYPE.Flex,
            props = {
                horizontal = true,
                arrange = ui.ALIGNMENT.Center,
            },
            content = ui.content({
                {
                    template = I.MWUI.templates.box,
                    content = ui.content({
                        createIngredientItem(e.ingr1),
                    }),
                },
                {
                    template = I.MWUI.templates.interval,
                },
                {
                    template = I.MWUI.templates.textNormal,
                    props = {
                        text = '+',
                    },
                },
                {
                    template = I.MWUI.templates.interval,
                },
                {
                    template = I.MWUI.templates.box,
                    content = ui.content({
                        createIngredientItem(e.ingr2),
                    }),
                },
                {
                    template = I.MWUI.templates.interval,
                },
                {
                    template = I.MWUI.templates.textNormal,
                    props = {
                        text = '=',
                    },
                },
                {
                    template = I.MWUI.templates.interval,
                },
                createButton(
                    effectInfo,
                    40,
                    function()
                        makePotion(effectCopy, ingr1Copy, ingr2Copy)
                        updateAlchemyMenu(-1)
                    end,
                    function(e)
                        updateAlchemyMenu(buttonIndexCopy)
                    end
                ),
            }),
        })
        bi.buttonIndex = bi.buttonIndex + 1
    end
    return res
end

local function createColumns(scanRes, hoverCreateButton)
    local splittedScanRes = split(scanRes, 12)
    local columns = { }
    local bi = { buttonIndex = 0 }
    for i, column in ipairs(splittedScanRes) do
        if i ~= 1 then
            table.insert(columns, {
                template = I.MWUI.templates.interval,
            })
        end
        table.insert(columns, {
            type = ui.TYPE.Flex,
            props = {
                horizontal = false,
            },
            content = ui.content(createAlchemyList(column, bi, hoverCreateButton)),
        })
    end
    return {
        type = ui.TYPE.Flex,
        props = {
            horizontal = true,
        },
        content = ui.content(columns),
    }
end

local function createAlchemyMenu(hoverCreateButton)
    local scanRes = scan()
    local createText
    local createTextTemplate
    if #scanRes ~= 0 then
        createText = 'Создать'
        createTextTemplate = I.MWUI.templates.textHeader
    else
        createText = 'Недостаточно ингредиентов'
        createTextTemplate = I.MWUI.templates.textNormal
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
                updateAlchemyMenu(-1)
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
                                template = createTextTemplate,
                                props = {
                                    text = createText,
                                },
                            },
                            {
                                template = I.MWUI.templates.interval,
                            },
                            createColumns(scanRes, hoverCreateButton),
                            {
                                template = I.MWUI.templates.interval,
                            },
                            {
                                type = ui.TYPE.Flex,
                                props = {
                                    horizontal = true,
                                    align = ui.ALIGNMENT.Center,
                                },
                                external = {
                                    stretch = 1,
                                },
                                content = ui.content({
                                    createButton({
                                        template = I.MWUI.templates.textHeader,
                                        props = {
                                            text = 'Закрыть',
                                        },
                                    }, 80, function()
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
        onSave = function()
            return alchemyProgress
        end,
        onLoad = function(data)
            if data then
                alchemyProgress = data
            end
        end,
    },
}


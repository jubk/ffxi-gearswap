elemental_obi_table = {
    Ice = "Hyorin Obi",
    Lightning = "Rairin Obi",
    Fire = "Karin Obi",
    Dark = "Anrin Obi",
    Light = "Korin Obi",
    Wind = "Furin Obi",
    Earth = "Dorin Obi",
    Water = "Suirin Obi"
}

element_to_storm_buff = {
    Ice = "Hailstorm",
    Lightning = "Thunderstorm",
    Fire = "Firestorm",
    Dark = "Voidstorm",
    Light = "Aurorastorm",
    Wind = "Windstorm",
    Earth = "Sandstorm",
    Water = "Rainstorm"
}

weather_to_intensity = {
    ['Hot spells'] = 1,
    ['Heat waves'] = 2,
    ['Rain'] = 1,
    ['Squalls'] = 2,
    ['Dust storms'] = 1,
    ['Sand storms'] = 2,
    ['Winds'] = 1,
    ['Gales'] = 2,
    ['Snow'] = 1,
    ['Blizzards'] = 2,
    ['Thunder'] = 1,
    ['Thunderstorms'] = 2,
    ['Auroras'] = 1,
    ['Stellar glare'] = 2,
    ['Gloom'] = 1,
    ['Darkness'] = 2
}

opposing_elements = {
    Ice = "Fire",
    Lightning = "Earth",
    Fire = "Water",
    Dark = "Light",
    Light = "Dark",
    Wind = "Ice",
    Earth = "Wind",
    Water = "Lightning"
}

-- Determines whether to use the combined obi
function use_obi(spell)
    -- Helixes always get weather/day bonuses, so they do not need the
    -- obi.
    if spell.english:find("helix") then
        return nil
    end

    local bonus = 0;

    if element_to_storm_buff[spell.element] then
        bonus = bonus + 1;
    end
    if spell.element == world.day_element then
        bonus = bonus + 1;
    end
    if spell.element == world.weather_element then
        bonus = bonus + weather_to_intensity[world.weather];
    end

    local opposing = opposing_elements[spell.element]
    if element_to_storm_buff[opposing] then
        bonus = bonus - 1;
    end
    if opposing == world.day_element then
        bonus = bonus - 1;
    end
    if opposing == world.weather_element then
        bonus = bonus - weather_to_intensity[world.weather];
    end

    if bonus > 0 then
        return true
    else
        return false
    end
end

_has_combined_obi = false;

function set_has_hachirin_no_obi(new_value)
    _has_combined_obi = new_value
end

function get_obi(spell)
    -- Helixes always get weather/day bonuses, so they do not need the
    -- obi.
    if spell.english:find("helix") then
        return nil
    end

    local stormBuff = element_to_storm_buff[spell.element] or false;

    if (stormBuff and buffactive[stormBuff]) or
       spell.element == world.day_element or
       spell.element == world.weather_element then
        return elemental_obi_table[spell.element];
    end
    return nil;
end

function get_twilight_cape(spell)
    local stormBuff = element_to_storm_buff[spell.element] or false;

    if (stormBuff and buffactive[stormBuff]) or
       spell.element == world.day_element or
       spell.element == world.weather_element then
        return "Twilight Cape";
    end
    return nil;
end

function get_day_and_weather_gear(spell)
    if _has_combined_obi then
        if use_obi(spell) then
            return {
                waist = "Hachirin-no-Obi",
                back = "Twilight Cape"
            }
        end
    else
        local stormBuff = element_to_storm_buff[spell.element] or false;

        if (stormBuff and buffactive[stormBuff]) or
           spell.element == world.day_element or
           spell.element == world.weather_element then
            return {
                waist = elemental_obi_table[spell.element],
                back = "Twilight Cape"
            };
        end
    end

    return nil
end
elemental_obi_table = {
    Ice = "Hyorin Obi",
    Thunder = "Rairin Obi",
    Fire = "Karin Obi",
    Dark = "Anrin Obi",
    Light = "Korin Obi",
    Wind = "Furin Obi",
    Earth = "Dorin Obi",
    Water = "Suirin Obi"
}

element_to_storm_buff = {
    Ice = "Hailstorm",
    Thunder = "Thunderstorm",
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
    Thunder = "Earth",
    Fire = "Water",
    Dark = "Light",
    Light = "Dark",
    Wind = "Ice",
    Earth = "Wind",
    Water = "Thunder"
}

-- Determines whether to use the combined obi
function use_obi(spell)
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

function get_obi(spell)
    local stormBuff = element_to_storm_buff[spell.element] or false;

    if (stormBuff and buffactive[stormBuff]) or
       spell.element == world.day_element or
       spell.element == world.weather_element then
        return elemental_obi_table[spell.element];
    end
    return nil;
end

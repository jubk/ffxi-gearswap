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

function get_obi(spell)
    local stormBuff = element_to_storm_buff[spell.element] or false;

    if (stormBuff and buffactive[stormBuff]) or
       spell.element == world.day_element or
       spell.element == world.weather_element then
        return elemental_obi_table[spell.element];
    end
    return nil;
end

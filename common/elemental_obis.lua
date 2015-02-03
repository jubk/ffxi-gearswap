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

function get_obi(spell)
    if spell.element == world.day_element or
        spell.element == world.weather_element then
        return elemental_obi_table[spell.element]
    end
    return nil;
end

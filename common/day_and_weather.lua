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

stormbuff_level = 1;

function set_stormbuff_level(new_level)
    stormbuff_level = new_level
end

function stormbuff_is_active(elem)
    local stormbuff = element_to_storm_buff[elem] or false;

    return (stormbuff and buffactive[stormbuff])
end

function zone_weather_is_active(elem)
    return (elem == world.weather_element)
end

function weather_is_active(elem)
    return stormbuff_is_active(elem) or zone_weather_is_active(elem)
end

function day_is_active(elem)
    return (elem == world.day_element)
end

function get_weather_intensity(spell)
    local weatherbonus = 0;
    local opposing = opposing_elements[spell.element]

    if stormbuff_is_active(spell.element) then
        weatherbonus = weatherbonus + stormbuff_level;
    elseif stormbuff_is_active(opposing) then
        weatherbonus = weatherbonus - stormbuff_level;
    end
    if zone_weather_is_active(spell.element) then
        weatherbonus = weatherbonus + weather_to_intensity[world.weather];
    elseif zone_weather_is_active(opposing) then
        weatherbonus = weatherbonus - weather_to_intensity[world.weather];
    end

    -- Cap intensity at 2
    if weatherbonus > 2 then
        return 2
    elseif weatherbonus < -2 then
        return -2
    else
        return weatherbonus
    end
end

-- Determines whether to use the combined obi
function use_hachirin_no_obi(spell)
    -- Helixes always get weather/day bonuses, so they do not need the
    -- obi.
    if spell.english:find("helix") then
        return nil
    end

    local bonus = 0;

    if day_is_active(spell.element) then
        bonus = bonus + 1;
    elseif day_is_active(opposing_elements[spell.element]) then
        bonus = bonus - 1;
    end

    bonus = bonus + get_weather_intensity(spell)

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

    if weather_is_active(spell.element) or day_is_active(spell.element) then
        return elemental_obi_table[spell.element];
    end
    return nil;
end

function get_twilight_cape(spell)
    -- Helixes always get weather/day bonuses, so they do not need the
    -- obi.
    if spell.english:find("helix") then
        return nil
    end

    if weather_is_active(spell.element) or day_is_active(spell.element) then
        return "Twilight Cape";
    end
    return nil;
end

function get_day_and_weather_gear(spell)
    if _has_combined_obi then
        if use_hachirin_no_obi(spell) then
            return {
                waist = "Hachirin-no-Obi",
                back = "Twilight Cape"
            }
        end
    else
        local obi = get_obi(spell)
        if obi then
            return {
                waist = obi,
                back = "Twilight Cape"
            };
        end
    end

    return nil
end
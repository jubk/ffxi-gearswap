spell_to_buff_map = {
    Stoneskin = { ["Stoneskin"] = 37 },
    ["Utsusemi: Ichi"] = {
        ["Copy Image (2)"] = 444,
        ["Copy Image (3)"] = 445,
        ["Copy Image (4+)"] = 446
    },
    ["Spectral Jig"] = { ["Sneak"] = 71 },
    ["Sneak"] = { ["Sneak"] = 71 },
    ["Monomi: Ichi"] = { ["Sneak"] = 71 }
}

function cancel_buffs(spell)
    -- We're only interested in spells that target ourselves.
    if not spell.target.type == 'SELF' then
        return false;
    end

    s = spell_to_buff_map[spell.english];
    if s == nil then
        return false
    end

    for name,id in pairs(s) do
        if buffactive[name] then
            send_command("cancel " .. id);
            return true;
        end
    end

    return false
end

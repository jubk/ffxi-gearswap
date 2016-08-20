include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Seething Bomblet",
        head="Sulevia's Mask +1",
        body="Sulevia's Plate. +1",
        hands="Sulev. Gauntlets +1",
        legs="Sulevi. Cuisses +1",
        feet="Sulev. Leggings +1",
        neck="Sanctity Necklace",
        waist="Sailfi Belt",
        left_ear="Digni. Earring",
        right_ear="Steelflash Earring",
        left_ring="Cacoethic Ring",
        right_ring="Strigoi Ring",
        back="Kayapa Cape",
    }
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    equip(sets.base)

    if '/magic' == spell.prefix then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end

end

function midcast(spell)
    cancel_buffs(spell);
end

function aftercast(spell)
    equip(sets.base)
end

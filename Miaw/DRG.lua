include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Staunch Tathlum",
        head="Sulevia's Mask +2",
        body="Sulevia's Plate. +2",
        hands="Sulev. Gauntlets +2",
        legs="Sulev. Cuisses +2",
        feet="Sulev. Leggings +2",
        neck="Sanctity Necklace",
        waist="Kentarch Belt +1",
        left_ear="Zwazo Earring",
        right_ear="Digni. Earring",
        left_ring="Cacoethic Ring",
        right_ring="Cacoethic Ring +1",
        back="Updraft Mantle",
    }

    sets.idle = set_combine(sets.base, {})
    sets.resting = set_combine(sets.base, {})
    sets.engaged = set_combine(sets.base, {})

    sets.fastcast = set_combine(sets.base, {})
    sets.magic_accuracy = set_combine(sets.base, {})

    sets.ws = {}
    sets.ws.base = set_combine(sets.base, {
        right_ring="Apate Ring",
        waist="Fotia Belt",
        neck="Fotia Gorget",
    })

    sets.ja = {}
    sets.ja.base = set_combine(sets.base, {})
    sets.ja.Angon = set_combine(sets.ja.base, {
        ammo="Angon",
    })

    MidCastGear = nil
    AfterCastGear = {}

end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    AfterCastGear = sets.base
    MidCastGear = nil

    if '/magic' == spell.prefix then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');

        equip(sets.fastcast)
        MidCastGear = sets.magic_accuracy
    elseif '/weaponskill' == spell.prefix then
        if sets.ws[spell.english] then
            equip(sets.ws[spell.english])
        else
            equip(sets.ws.base)
        end
    elseif '/jobability' == spell.prefix then
        if sets.ja[spell.english] then
            equip(sets.ja[spell.english])
        else
            equip(sets.ja.base)
        end
    else
        equip(sets.base)
    end

end

function midcast(spell)
    cancel_buffs(spell);
    if MidCastGear ~= nil then
        equip(MidCastgear)
    end
end

function aftercast(spell)
    equip(AfterCastGear)
end

function status_change(new,old)
    if "Idle" == new then
        equip(set_combine(SituationalGear, sets.idle))
    elseif "Resting" == new then
        equip(set_combine(SituationalGear, sets.resting))
    elseif "Engaged" == new then
        equip(set_combine(SituationalGear, sets.engaged))
    end
end

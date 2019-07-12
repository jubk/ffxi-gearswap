include("remove_silence");
include("cancel_buffs");

local herc_matk = require("shared/herc_matk_gear");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Seething Bomblet",
        head="Meghanada Visor +2",
        body="Meg. Cuirie +2",
        hands="Plun. Armlets +1",
        legs="Meg. Chausses +2",
        feet="Skulk. Poulaines",
        neck="Sanctity Necklace",
        waist="Kentarch Belt +1",
        left_ear="Steelflash Earring",
        right_ear="Digni. Earring",
        left_ring="Cacoethic Ring",
        right_ring="Cacoethic Ring +1",
        back={
            name="Canny Cape",
            augments={'DEX+3','AGI+2','"Dual Wield"+4',}
        },
    }

    sets.idle = set_combine(sets.base, {
        feet="Jute Boots +1",
    })
    sets.resting = set_combine(sets.base, {})
    sets.engaged = {
        Damage = set_combine(sets.base, {
            hands="Meg. Gloves +2",
            feet="Meg. Jam. +2",
        }),
        TH = set_combine(sets.base, {}),
    }

    sets.fastcast = set_combine(sets.base, {})
    sets.magic_accuracy = set_combine(sets.base, {})

    sets.ws = {}
    sets.ws.base = set_combine(sets.base, {
        right_ring="Apate Ring",
        waist="Fotia Belt",
        neck="Fotia Gorget",
    })
    sets.ws['Aeolian Edge'] = set_combine(sets.base, {
        ammo="Seething Bomblet",
        head=herc_matk.head,
        hands=herc_matk.body,
        hands=herc_matk.hands,
        legs=herc_matk.legs,
        feet=herc_matk.feet,
        left_ear="Friomisi Earring",
        right_ear="Hecate's Earring",
        left_ring="Arvina Ringlet +1",
        right_ring="Shiva Ring +1",
    })

    sets.ja = {}
    sets.ja.base = set_combine(sets.base, {})

    MidCastGear = nil
    AfterCastGear = {}

    engaged_mode = 'Damage'
    engaged_modes = {'Damage', 'TH'}
    engaged_idx = 1

end

function cycle_engaged()
    engaged_idx = engaged_idx + 1
    if engaged_idx > 2 then
        engaged_idx = 1
    end
    engaged_mode = engaged_modes[engaged_idx]
    add_to_chat(128, "Engaged mode set to '" .. engaged_mode .. "'")
end

function filtered_action(spell)
    if "Thunder IV" == spell.english then
        cycle_engaged()
        return cancel_spell()
    end
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
        equip(sets.idle)
    elseif "Resting" == new then
        equip(sets.resting)
    elseif "Engaged" == new then
        equip(sets.engaged[engaged_mode])
    end
end

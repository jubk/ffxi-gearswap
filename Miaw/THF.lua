include("remove_silence");
include("cancel_buffs");

local herc_matk = require("shared/herc_matk_gear");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Seething Bomblet",
        head="Meghanada Visor +2",
        body="Meg. Cuirie +1",
        hands="Plun. Armlets +1",
        legs="Meg. Chausses +1",
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
    sets.ws['Aeolian Edge'] = set_combine(sets.base, {
        ammo="Seething Bomblet",
        head=herc_matk.head,
        body={
            name="Rawhide Vest",
            augments={'HP+50','Accuracy+15','Evasion+20',}
        },
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
        equip(sets.engaged)
    end
end

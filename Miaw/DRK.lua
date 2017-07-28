include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Seething Bomblet",
        head="Sulevia's Mask +2",
        body="Sulevia's Plate. +1",
        hands="Sulev. Gauntlets +1",
        legs="Sulevi. Cuisses +2",
        feet="Sulev. Leggings +2",
        neck="Sanctity Necklace",
        waist="Sailfi Belt",
        left_ear="Bladeborn Earring",
        right_ear="Steelflash Earring",
        left_ring="Cacoethic Ring",
        right_ring="Strigoi Ring",
        back="Kayapa Cape",
    }

    sets.fastcast = {
        -- fast cast 2
        ammo="Sapience Orb",
        -- fast cast +12
        head="Carmine Mask",
        -- fast cast 10
        feet={ name="Odyssean Greaves", augments={'Accuracy+10','"Fast Cast"+5','Attack+13',}},
        -- fast cast 4
        neck="Voltsurge Torque",
        -- fast cast 2
        left_ear="Loquac. Earring",
        -- fast cast 2
        left_ring="Prolix Ring",
    }

    sets.magic_accuracy = {
        -- macc 8, matk 4
        ammo="Pemphredo Tathlum",
        -- macc 35,
        head={ name="Founder's Corona", augments={'DEX+9','Accuracy+14','Mag. Acc.+15','Magic dmg. taken -4%',}},
        -- macc 35, matk 35
        body={ name="Found. Breastplate", augments={'Accuracy+15','Mag. Acc.+15','Attack+15','"Mag.Atk.Bns."+15',}},
        -- matk 15
        legs="Augury Cuisses",
        -- macc 10
        feet={ name="Odyssean Greaves", augments={'Accuracy+10','"Fast Cast"+5','Attack+13',}},
        -- macc 10, matk 10
        neck="Sanctity Necklace",
        -- macc 10
        left_ear="Digni. Earring",
        -- matk 10
        right_ear="Friomisi Earring",
        -- macc 3
        left_ring="Arvina Ringlet +1",
        -- macc 7
        right_ring="Etana Ring",
        -- macc 5, matk 10
        back="Izdubar Mantle",
    }

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

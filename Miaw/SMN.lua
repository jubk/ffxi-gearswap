include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        main = "Espiritus",
        sub="Elan Strap",
        ammo="Sancus Sachet +1",
        head="Tali'ah Turban +1",
        body="Tali'ah Manteel +2",
        hands="Tali'ah Gages +1",
        legs="Tali'ah Sera. +2",
        feet="Tali'ah Crackows +1",
        neck="Empath Necklace",
        -- perp. cost -2
        waist="Lucidity Sash",
        -- mdt -3, Fast cast +1
        left_ear="Etiolation Earring",
        -- perp. cost -2, blood pact delay -2
        right_ear="Evans Earring",
        left_ring="Tali'ah Ring",
        right_ring="Varar Ring",
        -- Pet acc/atk/racc/ratk +20, avatar lvl +1, bp damage +5
        back="Campestres's Cape",
    }

    sets.idle = set_combine(sets.base, {})
    sets.idle_pet = set_combine(sets.idle, {
        -- perp. cost -6
        body="Beck. Doublet +1",
        -- perp cost -4
        feet="Con. Pigaches +1",
    })
    sets.rest = set_combine(sets.base, {})

    sets.fastcast = set_combine(sets.base, {
        head={
            name="Merlinic Hood",
            augments={
                'Mag. Acc.+19 "Mag.Atk.Bns."+19',
                '"Fast Cast"+6',
                'CHR+5',
            }
        },
        -- Fast cast +8
        body="Shango Robe",
        -- Fast cast +4
        neck = "Voltsurge Torque",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- TODO: hands
        -- Fast cast +4
        back = "Swith Cape +1",
        -- Fast cast +4
        legs="Gyve Trousers",
        -- Fast cast +10
        feet={
            name="Merlinic Crackows",
            augments={
                '"Fast Cast"+5',
                '"Mag.Atk.Bns."+4',
            }
        },
        -- Fast cast +2
        right_ear="Loquac. Earring",
        -- Fast cast +2
        left_ring="Prolix Ring",
    })
    sets.magic_accuracy = set_combine(sets.base, {
    })

    -- Thanks to https://pastebin.com/raw/Fa5PtueC
    Magic_BPs = S{
        -- No TP PBs
        'Holy Mist',
        'Nether Blast',
        'Aerial Blast',
        'Searing Light',
        'Diamond Dust',
        'Earthen Fury',
        'Zantetsuken',
        'Tidal Wave',
        'Judgment Bolt',
        'Inferno',
        'Howling Moon',
        'Ruinous Omen',
        'Night Terror',
        'Thunderspark',
        -- TP BPs
        'Impact',
        'Conflag Strike',
        'Level ? Holy',
        'Lunar Bay'
    }
    Merit_BPs = S{
        'Meteor Strike',
        'Geocrush',
        'Grand Fall',
        'Wind Blade',
        'Heavenly Strike',
        'Thunderstorm'
    }
    Physical_BPs_TP = S{
        'Rock Buster',
        'Mountain Buster',
        'Crescent Fang',
        'Spinning Dive'
    }

    sets.bloodpacts = {}
    sets.bloodpacts.precast = set_combine(sets.base, {
        -- Blood pact ability delay -9
        head="Accord Hat +1",
        -- Blood pact delay -7
        body="Shomonjijoe",
        -- Blood pact ability delay -6
        hands="Con. Bracers +1",
        -- perp. cost -2, blood pact delay -2
        right_ear="Evans Earring",
        -- blood pact delay -3
        back="Samanisi Cape",
    })
    sets.bloodpacts.base = set_combine(sets.base, {
        --  Blood pact +3
        left_ear="Esper Earring",
        -- SMN skill +5
        right_ear="Andoaa Earring",
    })
    sets.bloodpacts.damage = set_combine(sets.bloodpacts.base, {
        -- TODO: neck: Shulmanu Collar, from Fu in Omen
        -- TODO: waist: Incarnation Sash, from Plouton in Vagary
        -- TODO: ear: Enmerkar Earring, from Kyou in Omen

        -- smn skill +14, blood pact damage +11
        body="Beck. Doublet +1",
        -- pet:atk +20, pet:matk+20, blood pact +5
        hands="Merlinic Dastanas",
        -- pet:acc 8, pet:racc: 8, pet:acc: 7, blood pact +12
        legs={
            name="Enticer's Pants",
            augments={
                'MP+25',
                'Pet: Accuracy+8 Pet: Rng. Acc.+8',
                'Pet: Mag. Acc.+7',
            }
        },
    })

    MidCastGear = nil
    AfterCastGear = {}
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return
    end

    if pet.isvalid then
        AfterCastGear = sets.idle_pet
    else
        AfterCastGear = sets.base
    end
    MidCastGear = nil

    if "/pet" == spell.prefix then
        equip(sets.bloodpacts.precast)
        MidCastGear = sets.bloodpacts.base
        if spell.english == "Assault" then
            -- Nothing
        elseif spell.english == "Retreat" then
            -- Nothing
        elseif spell.english == "Release" then
            -- Nothing
        elseif spell.english == "Avatar's Favor" then
            -- Nothing
        elseif spell.type=="BloodPactRage" then
            if Magic_BPs:contains(spell.english) then
                -- Nothing
            else
                MidCastGear = sets.bloodpacts.damage
            end
        elseif spell.type=="BloodPactMagic" then
            -- Nothing
        end
        -- If doing Astral Conduit, go straight for MidCastGear since BP
        -- is instant.
        if buffactive["Astral Conduit"] then
            equip(MidCastGear)
        end
    elseif '/magic' == spell.prefix then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');

        if spell.type == "SummonerPact" then
            AfterCastGear = sets.idle_pet
        end

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

function status_change(new,old)
    if "Idle" == new then
        if pet.isvalid then
            equip(sets.idle_pet)
        else
            equip(sets.idle)
        end
    elseif "Engaged" == new then
        -- Nothing
    elseif "Resting" == new then
        equip(sets.resting);
    end
end

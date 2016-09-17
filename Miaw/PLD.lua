include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("cyclable_sets");

function get_sets()
    -- sets
    sets.tanking = {
        -- mdef +4
        ammo = "Vanir Battery",
        -- mdef +2, haste +7, enmity +5, pdt -5%, cover eff dur +9
        head = "Rev. Coronet +1",

        -- TODO: Souveran cuirass/Bushin abjuration: body/Pakecet T3 NM/
        --       Bewitched cuirass/100k
        -- dt -10, mdef +4, enmity +8, haste +3, cover: dam-to-mp 35, +fealty
        body = "Cab. Surcoat +1",
        -- mdef +4, regen +1, refresh +1
        neck = "Coatl Gorget +1",
        -- mdt -2, atk +6
        ear1 = "Merman's Earring",
        -- mdt -2, atk +6
        ear2 = "Merman's Earring",
        -- acc +42, atk +31, m.def.bonus 1, mdt -2, pdt -3, haste 4
        hands="Odyssean Gauntlets",
        -- cure recieved +5, dt -7, knockback dist -2
        ring1 = "Vocane Ring",
        -- dt -10
        ring2 = "Defending Ring",
        -- acc +15, dt -3, enmity +3, phalanx +4
        back = "Weard Mantle",
        -- dt -3
        waist = "Nierenschutz",
        -- mdef +3, haste +5, acc+37, dam.taken -3%
        legs="Souveran Diechlings",

        -- mdef +2, haste +3, enmity +6, sentinel +15, mdt -5
        feet = "Cab. Leggings +1"
    }

    sets.enmity = set_combine(
        sets.tanking,
        {
            -- enmity +7
            head = "Cab. Coronet +1",
            -- enmity +2
            ammo = "Sapience Orb",
            -- enmity +5
            neck = "Invidia Torque",
            -- enmity +10
            body = "Creed Cuirass +2",
            -- mdef +1, haste +4, enmity +7, shield bash +25
            hands = "Cab. Gauntlets +1",
            -- enmity +6
            legs = "Cab. Breeches",
            -- enmity +3
            ring2 = "Sattva Ring",
            -- enmity +5, mdef +4
            waist = "Creed Baudrier",
            -- enmity +6, evasion +15, resist gravity +15
            back = "Fravashi Mantle",
        }
    );

    sets.fastcast = set_combine(
        sets.tanking,
        {
            -- cast time -2, recast -1
            ammo = "Incantor Stone",
            -- fast cast +12
            head="Carmine Mask",
            -- fast cast +4
            neck = "Voltsurge Torque",
            -- Fast cast +2
            right_ear="Loquac. Earring",
            -- Fast cast +10
            feet="Odyssean Greaves"
        }
    );

    sets.fastcast_cure = set_combine(
        sets.fastcast,
        {
            -- cure spellcasting time -10%
            body="Jumalik Mail",
        }
    );
    sets.cure = set_combine(
        sets.enmity,
        {
            -- cure potency +15, mnd+16
            body="Jumalik Mail",
            -- Cure potency 5-6, MND +3
            ear1 = "Nourish. Earring",
            -- Cure effect recieved +5
            left_ring="Vocane Ring",
            -- Cure effect recieved +7
            legs="Souveran Diechlings",
            -- Cure potency +7
            feet="Odyssean Greaves",
            -- Cure potency +7
            back="Solemnity Cape",
        }
    );

    sets.ws = {};
    sets.ws.base = set_combine(
        sets.tanking, {
            -- acc +34
            head="Founder's Corona",

            -- acc +7
            left_ring="Patricius Ring",
            -- acc +7
            right_ring="Yacuruna Ring",

            -- acc +35, matk +35, macc +35
            body = "Found. Breastplate",

            -- acc +5
            neck = "Voltsurge Torque",

            -- acc +8
            left_ear="Steelflash Earring",

            -- acc +20
            waist="Olseni Belt",

            -- acc +7
            ring1 = "Yacaruna Ring",

            -- acc +7
            ring1 = "Patricius Ring",

            -- Acc +25
            feet="Founder's Greaves"
        }
    );
    sets.ws['Atonement'] = sets.enmity;
    sets.ws['Requiescat'] = set_combine(
        sets.ws.base, {
            -- MND 29
            hands = "Cab. Gauntlets +1",
            legs="Carmine Cuisses"
        }
    );
    sets.ws.magic = set_combine(
        sets.ws.base, {
            -- mdam +10
            ammo="Ghastly Tathlum",
            -- matk/macc +35
            body="Found. Breastplate",
            -- matk/macc +34
            feet="Founder's Greaves",
            -- macc +10, matk +10
            neck="Sanctity Necklace",
            -- matk +6
            left_ear="Hecate's Earring",
            -- matk +10
            right_ear="Friomisi Earring",
            -- macc +3, matk +3
            left_ring="Arvina Ringlet +1",
            -- macc +5, matk +10
            back="Izdubar Mantle",
        }
    );
    sets.ws['Burning Blade'] = set_combine(
        sets.ws.magic, { legs="Carmine Cuisses" }
    );
    sets.ws['Red Lotus Blade'] = sets.ws['Burning Blade'];
    sets.ws['Shining Blade'] = sets.ws.magic
    sets.ws['Seraph Blade'] = sets.ws.magic

    sets.ws['Gust Slash'] = sets.ws.magic
    sets.ws['Cyclone'] = sets.ws.magic
    sets.ws['Aoelian Edge'] = sets.ws.magic

    sets.ws['Frostbite'] = sets.ws.magic
    sets.ws['Freezebite'] = sets.ws.magic

    sets.ws['Shining Strike'] = sets.ws.magic
    sets.ws['Seraph Strike'] = sets.ws.magic

    sets.ws['Thunder Thrust'] = sets.ws.magic
    sets.ws['Raiden Thrust'] = sets.ws.magic


    sets.resting = set_combine(
        sets.tanking,
        {
            -- Refresh +2
            body = "Twilight Mail",
            -- rmp +4
            waist = "Austerity Belt",
            -- rmp +3
            feet = "Lord's sabatons",
        }
    );

    sets.idle = set_combine(
        sets.tanking, {
            legs="Carmine Cuisses"
        }
    );

    EnmityJobabilities = {
        "Provoke",
        "Sentinel",
        "Rampart",
        "Shield Bash",
        "Chivalry",
        "Invincible",
        "Animated Flourish"
    }

    SituationalGear = {
        -- Adjusted in status_change for twilight mail refresh
        body = nil,
        -- For purity ring
        right_ring = nil,
    }
    MidCastGear = {}
    AfterCastGear = {}

    set_has_hachirin_no_obi(true);
end

function status_change(new,old)
    if (player.max_mp - player.mp) > 100 then
        SituationalGear['body'] = "Twilight Mail"
    else
        SituationalGear['body'] = nil
    end

    if "Idle" == new then
        equip(set_combine(SituationalGear, sets.idle))
    elseif "Resting" == new then
        equip(set_combine(SituationalGear, sets.resting))
    elseif "Engaged" == new then
        SituationalGear['body'] = nil
        equip(set_combine(SituationalGear, sets.tanking))
    end
end

function pretarget(spell)
    MidCastGear = {}
    AfterCastGear = {}
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    if buffactive['Curse'] then
        SituationalGear.right_ring = "Purity Ring"
    else
        SituationalGear.right_ring = nil
    end

    if '/magic' == spell.prefix  then
        local toEquip = set_combine(SituationalGear, sets.fastcast);

        if spell.skill == 'Healing Magic' then
            -- Speed up cure spells with fastcast
            toEquip = set_combine(SituationalGear, sets.fastcast_cure);
            -- Equip healing gear midcast for healing spells
            MidCastGear = set_combine(MidCastGear, sets.cure)
        elseif "Flash" == spell.english or "Blind" == spell.english then
            -- Equip enmity gear for flash and blind spells
            toEquip = set_combine(toEquip, sets.enmity)
        end

        equip(toEquip)
        
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    elseif '/weaponskill' == spell.prefix then
        if sets.ws[spell.english] then
            equip(sets.ws[spell.english]);
        else
            equip(sets.ws.base);
        end
    elseif '/jobability' == spell.prefix  then
        local toEquip = {}
        if table.contains(EnmityJobabilities, spell.name) then
            toEquip = set_combine(toEquip, sets.enmity)
        end

        if "Holy Circle" == spell.english then
            toEquip['feet'] = "Gallant Leggings"
        elseif "Sentinel" == spell.english then
            toEquip['feet'] = "Cab. Leggings +1"
            MidCastGear['feet'] = nil
            AfterCastGear['feet'] = nil
        elseif "Cover" == spell.english or
            "Fealty" == spell.english then
            SituationalGear['body'] = "Cab. Surcoat +1"
            toEquip['body'] = "Cab. Surcoat +1"
            MidCastGear['body'] = "Cab. Surcoat +1"
            AfterCastGear['body'] = "Cab. Surcoat +1"
        elseif "Shield Bash" == spell.english then
            toEquip['hands'] = "Cab. Gauntlets +1"
            MidCastGear['hands'] = "Cab. Gauntlets +1"
        elseif "Rampart" == spell.english then
            toEquip['head'] = "Cab. Coronet +1"
        elseif "Invincible" == spell.english then
            toEquip['legs'] = "Cab. Breeches"
        end
        equip(toEquip)
    end
end

function midcast(spell)
    cancel_buffs(spell);
    if table.length(MidCastGear) > 0 then
        equip(MidCastGear)
    end
end

function aftercast(spell)
    if buffactive['Curse'] then
        SituationalGear.right_ring = "Purity Ring"
    else
        SituationalGear.right_ring = nil
    end

    if player.status == "Idle" then
        equip(set_combine(
            set_combine(SituationalGear, sets.idle),
            AfterCastGear
        ));
    else
        equip(set_combine(
            set_combine(SituationalGear, sets.tanking),
            AfterCastGear
        ));
    end
end

function filtered_action(spell)
end

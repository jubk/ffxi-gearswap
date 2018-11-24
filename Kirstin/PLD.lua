include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("cyclable_sets");

function get_sets()
    -- sets
    sets.tanking = {
        -- Damaga taken -2, +10 resist to all debuffs
        ammo="Staunch Tathlum",
        head="Sulevia's Mask +2",
        body="Cab. Surcoat +1",
        hands="Sulev. Gauntlets +1",
        legs="Sulevi. Cuisses +2",
        feet="Sulev. Leggings +2",
        -- Refresh +1
        neck="Coatl Gorget +1",
        waist="Nierenschutz",
        -- mdt -2
        left_ear="Merman's Earring",
        right_ear="Odnowa Earring +1",
        left_ring="Fortified Ring",
        right_ring="Defending ring",
        back="Weard Mantle",
    }

    sets.enmity = set_combine(
        sets.tanking,
        {
            -- Enmity +7
            head="Cab. Coronet +1",
            -- Enmity +5
            waist="Creed Baudrier",
            -- Enmity +2
            left_ear="Friomisi Earring",
            right_ear="Cryptic Earring",
            left_ring="Vengeful Ring",
        }
    );

    sets.fastcast = set_combine(
        sets.tanking,
        {
            -- cast time -2, recast -1
            ammo = "Incantor Stone",
            hands = "Leyline Gloves",
            feet = "Odyssean Greaves",
            -- Fast cast +4
            left_ring="Kishar Ring",
            right_ring="Prolix Ring",
            right_ear="Loquac. Earring",
        }
    );

    sets.fastcast_cure = set_combine(
        sets.fastcast,
        {
            -- cure cast time -4
            neck="Diemer Gorget",
            -- cure cast time -3
            left_ear="Nourish. Earring",
            -- cure cast time -5
            right_ear="Mendi. Earring",
        }
    );
    sets.cure = set_combine(
        sets.enmity,
        {
            -- cure pot +4
            neck="Phalaina Locket",
            -- cure pot +2
            left_ear="Nourish. Earring",
            -- cure pot +5
            right_ear="Mendi. Earring",
        }
    );

    sets.ws = {};
    sets.ws.base = set_combine(
        sets.tanking, {
            -- atk 10, matk 10, acc 10, macc 10
            neck="Sanctity Necklace",
            -- acc 40, atk 44, SC bonus
            body="Sulevia's Plate. +2",
            -- atk 15, matk 7, acc 15, macc 7
            waist="Eschan Stone",
            -- acc 10, macc 10
            left_ear="Digni. Earring",
        }
    );
    sets.ws['Atonement'] = sets.enmity;
    sets.ws['Requiescat'] = set_combine(
        sets.ws.base, {
        }
    );
    sets.ws.magic = set_combine(
        sets.ws.base, {
            -- macc 32, matk 30
            hands = "Leyline Gloves",
            -- macc 30+, matk 29+
            body="Found. Breastplate",
            -- matk 15
            legs="Augury Cuisses",
            -- matk 29
            feet="Founder's Greaves",
            -- Matk 10, Enmity +2
            left_ear="Friomisi Earring",
        }
    );
    sets.ws['Burning Blade'] = set_combine(
        sets.ws.magic, {}
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
        }
    );

    sets.idle = set_combine(
        sets.tanking, {
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
            SituationalGear['feet'] = "Cab. Leggings +1"
            toEquip['feet'] = "Cab. Leggings +1"
            AfterCastGear['feet'] = "Cab. Leggings +1"
        elseif "Cover" == spell.english then
            SituationalGear['body'] = "Cab. Surcoat +1"
            toEquip['body'] = "Cab. Surcoat +1"
            AfterCastGear['body'] = "Cab. Surcoat +1"
        elseif "Fealty" == spell.english then
            toEquip['body'] = "Cab. Surcoat +1"
        elseif "Shield Bash" == spell.english or
            "Chivalry" == spell.english then
            toEquip['hands'] = "Cab. Gauntlets +1"
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

    if SituationalGear.body == "Cab. Surcoat +1" and
        not buffactive["Cover"] then
        SituationalGear.body = nil
    end

    if SituationalGear['feet'] == "Cab. Leggings +1" and
        not buffactive["Sentinel"] then
        SituationalGear['feet'] = nil
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

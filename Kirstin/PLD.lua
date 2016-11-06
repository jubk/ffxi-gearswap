include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("cyclable_sets");

function get_sets()
    -- sets
    sets.tanking = {
        ammo="Incantor Stone",
        head="Sulevia's Mask +1",
        body="Cab. Surcoat +1",
        hands="Sulev. Gauntlets +1",
        legs="Sulevi. Cuisses +1",
        feet="Sulev. Leggings +1",
        neck="Sanctity Necklace",
        waist="Eschan Stone",
        left_ear="Nourish. Earring",
        right_ear="Cryptic Earring",
        left_ring="Fortified Ring",
        right_ring="Patricius Ring",
        back="Tantalic Cape",
    }

    sets.enmity = set_combine(
        sets.tanking,
        {
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
            right_ring="Prolix Ring",
            right_ear="Loquac. Earring",
        }
    );

    sets.fastcast_cure = set_combine(
        sets.fastcast,
        {
        }
    );
    sets.cure = set_combine(
        sets.enmity,
        {
        }
    );

    sets.ws = {};
    sets.ws.base = set_combine(
        sets.tanking, {
        }
    );
    sets.ws['Atonement'] = sets.enmity;
    sets.ws['Requiescat'] = set_combine(
        sets.ws.base, {
        }
    );
    sets.ws.magic = set_combine(
        sets.ws.base, {
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

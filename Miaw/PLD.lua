include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("cyclable_sets");

function get_sets()
    -- sets
    sets.melee = {}
    sets.melee['Tanking'] = {
        ammo = "Vanir Battery",
        body = "Cab. Surcoat +1",
        neck = "Coatl Gorget +1",
        ear1 = "Merman's Earring",
        ear2 = "Merman's Earring",
        hands = "Cab. Gauntlets +1",
        ring1 = "Vocane Ring",
        ring2 = "Defending Ring",
        back = "Weard Mantle",
        waist = "Nierenschutz",
        legs = "Rev. Breeches +1",
        feet = "Cab. Leggings +1"
    }

    sets.melee['Enmity'] = set_combine(
        sets.melee['Tanking'],
        {
            head = "Rev. Coronet +1",
            neck = "Invidia Torque",
            body = "Creed Cuirass +2",
            ring1 = "Odium Ring",
            ring2 = "Sattva Ring",
            waist = "Creed Baudrier",
            back = "Fravashi Mantle",
        }
    );

    sets.melee['FastCast'] = set_combine(
        sets.melee['Tanking'],
        {
            ammo = "Incantor Stone",
            head = "Creed Armet +2",
            neck = "Jeweled Collar",
            ear2 = "Moonshade Earring",
        }
    );

    sets.melee['Healing'] = set_combine(
        sets.melee['Enmity'],
        {
            head = "Rev. Coronet +1",
            body = "Cab. Surcoat +1",
            ear1 = "Nourish. Earring",
            ring1 = "Solemn Ring",
            ring2 = "Diamond Ring"
        }
    );

    sets.melee['Ws'] = set_combine(
        sets.melee['Tanking'],
        {
            head = "Rev. Coronet +1",
            neck = "Chivalrous Chain",
            ring1 = "Spiral Ring",
            ring2 = "Ruby Ring",
            back = "Atheling Mantle",
        }
    );

    sets.melee['Tp'] = set_combine(
        sets.melee['Tanking'],
        {
            neck = "Chivalrous Chain",
            ring1 = "Spiral Ring",
            ring2 = "Ruby Ring",
            waist = "Swift Belt",
            back = "Atheling Mantle",
        }
    );

    sets.melee['Resting'] = set_combine(
        sets.melee['Tanking'],
        {
            body = "Twilight Mail",
            waist = "Austerity Belt",
            feet = "Lord's sabatons",
        }
    );

    sets.melee['Idle'] = set_combine(
        sets.melee['Tanking'], {}
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
        -- Changed with engaged/idle status
        head = "Rev. Coronet +1",
        -- Adjusted in status_change for twilight mail refresh
        body = nil,
    }
    MidCastGear = {}
    AfterCastGear = {}
end

function status_change(new,old)
    SituationalGear['head'] = "Rev. Coronet +1"
    if (player.max_mp - player.mp) > 100 then
        SituationalGear['body'] = "Twilight Mail"
    else
        SituationalGear['body'] = nil
    end

    if "Idle" == new then
        equip(set_combine(SituationalGear, sets.melee.Idle))
    elseif "Resting" == new then
        equip(set_combine(SituationalGear, sets.melee.Resting))
    elseif "Engaged" == new then
        SituationalGear['body'] = nil
        equip(set_combine(SituationalGear, sets.melee.Tanking))
    end
end

function pretarget(spell)
    -- TODO: adjust situational gear
    MidCastGear = {}
    AfterCastGear = {}

    ---- Reset feet item after sentinel wears off
    --if "Cab. Leggings" == SituationalGear['feet'] and
    --    not buffactive['sentinel'] then
    --    SituationalGear['feet'] = nil
    --    AfterCastGear['feet'] = nil
    --end
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    if '/magic' == spell.prefix  then
        local toEquip = set_combine(SituationalGear, sets.melee.FastCast);

        if spell.skill == 'Healing Magic' then
            -- Equip healing gear midcast for healing spells
            MidCastGear = set_combine(MidCastGear, sets.melee.Healing)
        elseif "Flash" == spell.english or "Blind" == spell.english then
            -- Equip enmity gear for flash and blind spells
            toEquip = set_combine(toEquip, sets.melee.Enmity)
        end

        equip(toEquip)
        
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    elseif '/weaponskill' == spell.prefix then
        equip(sets.melee.Ws)
    elseif '/jobability' == spell.prefix  then
        local toEquip = {}
        if table.contains(EnmityJobabilities, spell.name) then
            toEquip = set_combine(toEquip, sets.melee.Enmity)
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
        elseif "Rampart" == spell.english then
            toEquip['head'] = "Valor Coronet"
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
    equip(set_combine(
        set_combine(SituationalGear, sets.melee.Tanking),
        AfterCastGear
    ));
end

function filtered_action(spell)
    if(spell.name == "Thunder IV") then
        cancel_spell();
        return;
    end
end

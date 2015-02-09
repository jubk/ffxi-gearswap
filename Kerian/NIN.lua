include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

function get_sets()
    -- sets
    sets.base = {
        ammo = "Happo shuriken",
        body = "Koga Chainmail +2",
        neck = "Ej necklace",
        ear1 = "Suppanomimi",
--        ear2 = "Brutal earring",
        ear2 = "Steelflash earring",
--        hands = "Iga tekko +1",
        hands = "Sasuke tekko",
        ring1 = "Rajas ring",
        ring2 = "Keen ring",
--        back = "Blithe mantle",
        back = "Attacker's mantle",
--        waist = "Cetl belt",
        waist = "Anguinus belt",
        legs = "Mochizuki hakama",
        feet = "Hachiya kyahan",
    }
    
    sets.melee = {}
    sets.melee['Acc'] = set_combine(
        sets.base,
        {
            ear2 = "Steelflash Earring",
            hands = "Sasuke tekko",
            waist = "Anguinus belt",
            back = "Attacker's Mantle",
        }
    );

    sets.ws = {};
    local ws_base = set_combine(
        sets.base,
        {
            neck = "Light gorget",
            back = "Amemet mantle +1",
            hands = "Ochimusha kote",
            waist = "Light belt",
            ear1 = "Coral earring",
            ear2 = "Centaurus Earring",
        }
    );
    
    sets.ws['Base'] = ws_base;
    
    -- F.eks. :
    --sets.ws['Blade: Shun'] = set_combine(ws_base,
    --    head = "Totallyawesomeübergear +1"
    --)


    sets.fastcast = set_combine(
        sets.base,
        {
            ear2 = "Loquacious earring",
        }
    );


    sets.idle = set_combine(
        sets.base,
        {}
    );

    sets.resting = set_combine(
        sets.base,
        {}
    );

    sets.healing = set_combine(
        sets.base,
        {}
    );

    sets.enmity = set_combine(
        sets.base,
        {}
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

    SituationalGear = {}
    MidCastGear = {}
    AfterCastGear = {}

    --melee_modes = {}
    --melee_idx = 0;
    --melee_modes_count = 0;
    --for name,_ in pairs(s) do
    --    if name != 'Base' then
    --        melee_modes[melee_modes_count] = name;
    --        melee_modes_count = melee_modes_count + 1;
    --    end
    --end
    --set_melee_mode_by_name('Acc')
end

--function set_melee_mode_by_index(index)
--    melee_idx = index;
--    current_melee_mode = melee_modes[melee_idx];
--    add_to_chat(128, "Melee mode set to '" .. current_melee_mode); .. "'";
--end
--
--function set_melee_mode_by_name(new_name)
--    for idx,name in pairs(s) do
--        if name == new_name then
--            set_melee_mode_by_id(index)
--            return
--        end
--    end
--end
--
--function cycle_melee_modes()
--    local new_idx = melee_idx + 1;
--    if new_idx >= melee_modes_count then
--        new_idx = 0
--    end
--    set_melee_mode_by_id(new_idx)
--end

function status_change(new,old)
    -- Make changes to situational gear here if necessary
    -- Situational gear will override Base and melee gearsets.

    if "Idle" == new then
        equip(set_combine(SituationalGear, sets.idle))
    elseif "Resting" == new then
        equip(set_combine(SituationalGear, sets.resting))
    elseif "Engaged" == new then
        -- TODO: Make dynamic
        equip(set_combine(SituationalGear, sets.base))
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

    if '/magic' == spell.prefix  then
        local toEquip = set_combine(SituationalGear, sets.fastcast);

        if spell.skill == 'Healing Magic' then
            -- Equip healing gear midcast for healing spells
            MidCastGear = set_combine(MidCastGear, sets.healing)
        elseif "Flash" == spell.english or "Blind" == spell.english then
            -- Equip enmity gear for flash and blind spells
            toEquip = set_combine(toEquip, sets.enmity)
        end

        equip(toEquip)
        
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    elseif '/weaponskill' == spell.prefix then
        local specific = sets.ws[spell.english];
        if specific == nil then
            equip(specific)
        else
            equip(sets.ws['Base'])
        end
    elseif '/jobability' == spell.prefix  then
        local toEquip = {}
        if table.contains(EnmityJobabilities, spell.name) then
            toEquip = set_combine(toEquip, sets.enmity)
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
        set_combine(SituationalGear, sets.base),
        AfterCastGear
    ));
end

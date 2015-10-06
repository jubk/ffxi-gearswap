include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("cyclable_sets");

function get_sets()
    -- sets
    sets.melee = {}
    sets.melee['Tanking'] = {
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
        -- mdef +1, haste +4, enmity +7, shield bash +25
        hands = "Cab. Gauntlets +1",
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

    sets.melee['Enmity'] = set_combine(
        sets.melee['Tanking'],
        {
            -- enmity +7
            head = "Cab. Coronet +1",
            -- enmity +5
            neck = "Invidia Torque",
            -- enmity +10
            body = "Creed Cuirass +2",
            -- enmity +6
            legs = "Cab. Breeches",
            -- TODO: ring1 = "Odium Ring",
            -- enmity +3
            ring2 = "Sattva Ring",
            -- enmity +5, mdef +4
            waist = "Creed Baudrier",
            -- enmity +6, evasion +15, resist gravity +15
            back = "Fravashi Mantle",
        }
    );

    sets.melee['FastCast'] = set_combine(
        sets.melee['Tanking'],
        {
            -- cast time -2, recast -1
            ammo = "Incantor Stone",
            -- fast cast +5
            head = "Creed Armet +2",
            -- fast cast +3
            neck = "Jeweled Collar",
            -- Occ. quickens spells
            ear2 = "Moonshade Earring",
        }
    );

    sets.melee['Healing'] = set_combine(
        sets.melee['Enmity'],
        {
            -- MND +19
            body = "Cab. Surcoat +1",
            -- Cure potency 5-6, MND +3
            ear1 = "Nourish. Earring",
            -- MND +5
            ring1 = "Solemn Ring",
        }
    );

    sets.melee['WS'] = {};
    sets.melee['WS']['base'] = set_combine(
        sets.melee['Tanking'], {
            -- acc +25
            body = "Twilight Mail",

            -- acc +7
            ring1 = "Yacaruna Ring",

            -- acc +7
            ring1 = "Patricius Ring",
        }
    );
    sets.melee['WS']['Atonement'] = sets.melee['Enmity'];
    sets.melee['WS']['Requiescat'] = set_combine(
        sets.melee['WS']['base'], {
            legs="Carmine Cuisses"
        }
    );
    sets.melee['WS']['Burning Blade'] = set_combine(
        sets.melee['WS']['base'], {
            ammo="Ghastly Tathlum",
            body="Cab. Surcoat +1",
            legs="Carmine Cuisses",
            neck="Stoicheion Medal",
            left_ear="Hecate's Earring",
            right_ear="Moldavite Earring",
            left_ring="Arvina Ringlet +1",
            right_ring={
                name="Demon's Ring",
                augments={
                    '"Mag.Atk.Bns."+3',
                    '"Resist Curse"+3',
                    '"Resist Blind"+2',
                }
            },
        }
    );
    sets.melee['WS']['Burning Blade'] = sets.melee['WS']['Red Lotus Blade'];

    sets.melee['Tp'] = set_combine(
        sets.melee['Tanking'],
        {
            -- STR +5, VIT +5, INT +5
            ring1 = "Spiral Ring",
            -- STR +4
            ring2 = "Ruby Ring",
            -- Attack +20
            back = "Atheling Mantle",
        }
    );

    sets.melee['Resting'] = set_combine(
        sets.melee['Tanking'],
        {
            -- Refresh +2
            body = "Twilight Mail",
            -- rmp +4
            waist = "Austerity Belt",
            -- rmp +3
            feet = "Lord's sabatons",
        }
    );

    sets.melee['Idle'] = set_combine(
        sets.melee['Tanking'], {
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
        if sets.melee.WS[spell.english] then
            equip(sets.melee.WS[spell.english]);
        else
            equip(sets.melee.WS.base);
        end
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
    if player.status == "Idle" then
        equip(set_combine(
            set_combine(SituationalGear, sets.melee.Idle),
            AfterCastGear
        ));
    else
        equip(set_combine(
            set_combine(SituationalGear, sets.melee.Tanking),
            AfterCastGear
        ));
    end
end

function filtered_action(spell)
end

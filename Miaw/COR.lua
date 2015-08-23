
include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

function get_sets()
    -- Variables

    CurrentRoll = nil;
    CurrentLucky = 0;
    CurrentUnlucky = 0;

    -- TODO: Write Elemental stuff include

    CheapAmmoList = {
        "Orichalc. Bullet",
        "Steel Bullet",
        "Bullet",
        "Paktong Bullet",
        "Iron Bullet",
        "Bronze Bullet",
        "Tin Bullet",
        "Eminent Bullet",
    };

    HighDamageAmmoList = {
        "Bronze Bullet",
        "Tin Bullet",
        "Bullet",
        "Paktong Bullet",
        "Iron Bullet",
        "Corsair Bullet",
        "Steel Bullet",
        "Orichalc. Bullet",
        "Eminent Bullet",
    };

    -- SlugwinderAmmo defaults to HighDamAmmo, but uses these if available:
    SlugWinderAmmoList = {
        "Corsair Bullet"
    };
    -- QuickDrawAmmo defaults to HighDamAmmo, but uses these if available:
    QuickDrawAmmoList = {
        "Orichalc. Bullet",
        "Eminent Bullet",
        "Animikii Bullet",
    };


    DontWasteBullets = {
        "Oberon's Bullet",
        "Animikii Bullet",
    };

    -- Fallbacks for unconfigured ammo
    CheapAmmo = "Iron Bullet";
    HighDamAmmo = "Steel Bullet";
    SlugWinderAmmo = "Corsair Bullet";
    QuickDrawAmmo = "Oberon's Bullet";

    self_command("updateammo");

    ShootingDelay = 7.7; -- (gun delay + ammo delay) / 110 plus a bit extra
    PreShootingDelay = 0.2;

    MidCastGear = {};
    AfterCastGear = {};

    marksmanship_ws = {
        'Hot Shot',
        'Split Shot',
        'Sniper Shot',
        'Slug Shot',
        'Blast Shot',
        'Heavy Shot',
        'Detonator',
        'Numbing Shot',
        'Last Stand',
        'Coronach',
        'Trueflight',
        'Leaden Salute',
        'Wildfire'
    }

    LuckyRolls = {
        ["Magus's Roll"]        = { lucky = 2, unlucky = 6 },
        ["Choral Roll"]         = { lucky = 2, unlucky = 6 },
        ["Samurai Roll"]        = { lucky = 2, unlucky = 6 },
        ["Scholar's Roll"]      = { lucky = 2, unlucky = 6 },
        ["Caster's Roll"]       = { lucky = 2, unlucky = 7 },
        ["Companion's Roll"]    = { lucky = 2, unlucky = 10 },
        ["Healer's Roll"]       = { lucky = 3, unlucky = 7 },
        ["Monk's Roll"]         = { lucky = 3, unlucky = 7 },
        ["Drachen Roll"]        = { lucky = 3, unlucky = 7 },
        ["Gallant's Roll"]      = { lucky = 3, unlucky = 7 },
        ["Dancer's Roll"]       = { lucky = 3, unlucky = 7 },
        ["Bolter's Roll"]       = { lucky = 3, unlucky = 9 },
        ["Courser's Roll"]      = { lucky = 3, unlucky = 9 },
        ["Allies' Roll"]        = { lucky = 3, unlucky = 10 },
        ["Ninja Roll"]          = { lucky = 4, unlucky = 8 },
        ["Hunter's Roll"]       = { lucky = 4, unlucky = 8 },
        ["Chaos Roll"]          = { lucky = 4, unlucky = 8 },
        ["Puppet Roll"]         = { lucky = 4, unlucky = 8 },
        ["Beast Roll"]          = { lucky = 4, unlucky = 8 },
        ["Warlock's Roll"]      = { lucky = 4, unlucky = 8 },
        ["Blitzer's Roll"]      = { lucky = 4, unlucky = 9 },
        ["Miser's Roll"]        = { lucky = 5, unlucky = 7 },
        ["Tactician's Roll"]    = { lucky = 5, unlucky = 8 },
        ["Corsair's Roll"]      = { lucky = 5, unlucky = 9 },
        ["Evoker's Roll"]       = { lucky = 5, unlucky = 9 },
        ["Rogue's Roll"]        = { lucky = 5, unlucky = 9 },
        ["Fighter's Roll"]      = { lucky = 5, unlucky = 9 },
        ["Wizard's Roll"]       = { lucky = 5, unlucky = 9 }
    }

    -- sets
    sets.elemental = {}
    sets.elemental['Standard'] = {
        head = "Laksamana's Hat +1",
        neck = "Stoicheion medal",
        ear1 = "Volley Earring",
        ear2 = "Hecate's Earring",
        body = "Lanun Frac +1",
        hands = "Lak. Gants +1",
        ring1 = "Solemn Ring",
        ring2 = "Sattva Ring",
        back = "Navarch's Mantle",
        waist = "Aquiline Belt",
        legs = "Lak. Trews +1",
        feet = "Vanir Boots",
    };
    sets.elemental['QuickDraw'] = set_combine(
        sets.elemental['Standard'],
        {
            neck = "Stoicheion medal",
            ear1 = "Moldavite Earring",
            ear2 = "Hecate's Earring",
            body = "Navarch's Frac +2",
            hands = "Schutzen Mittens",
            ring1 = "Demon's Ring",
            ring2 = "Arvina Ringlet +1",
            waist = "Aquiline Belt",
            -- +20% damage from matching element for 15 seconds
            feet = "Chasseur's Bottes",
            back = "Forban Cape",
        }
    );

    sets.elemental['WildFire'] = set_combine(
        sets.elemental['QuickDraw'],
        {
            head = "Imp. Wing Hair. +1",
            body = "Lanun Frac +1",
            hands = "Schutzen Mittens",
            ring1 = "Solemn Ring",
            ring2 = "Arvina Ringlet +1",
            feet = "Vanir Boots",
        }
    );

    sets.elemental['WildFireBrew'] = set_combine(
        sets.elemental['QuickDraw'],
        {
            body = "Navarch's Frac +2",
            ring1 = "Demon's Ring",
            ring2 = "Strendu Ring",
        }
    );

    sets.elemental['Idle'] = set_combine(
        sets.elemental['Standard'], {
            feet = "Hermes' Sandals",
        }
    );

    sets.elemental['Resting'] = set_combine(
        sets.elemental['Standard'], {}
    );

    sets.elemental['ratk'] = set_combine(
        sets.elemental['Standard'],
        {
            ear1 = "Drone earring",
            ear2 = "Drone earring",
            back = "Amemet Mantle +1",
            ring1 = "Solemn Ring",
            ring2 = "Jalzahn's Ring",
            feet = "Chasseur's Bottes",
        }
    );

    sets.elemental['racc'] = set_combine(
        sets.elemental['Standard'],
        {
            neck = "Spectacles",
            ring1 = "Behemoth Ring",
            ring2 = "Jalzahn's Ring",
            feet = "Chasseur's Bottes",
        }
    );

    sets.elemental['ws'] = set_combine(
        sets.elemental['Standard'],
        {
            ring1 = "Spiral Ring",
            ring2 = "Ruby Ring",
            back = "Amemet Mantle +1",
            feet = "Chasseur's Bottes",
        }
    );

end

function get_roll_equipment(spellname)
    local rollEquip = {
        hands = "Navarch's Gants +2",
        head = "Comm. Tricorne",
        ring2 = "Barataria Ring"
    }

    if "Courser's Roll" == spellname then
        rollEquip.feet = "Chasseur's Bottes";
    elseif "Tactician's Roll" == spellname  then
        rollEquip.body = "Navarch's Frac +2"
    end

    return rollEquip;
end

function stop_wasting_bullets()
    local ammo = player.equipment.ammo
    if table.contains(DontWasteBullets, ammo) then
        add_to_chat(
            128,
            'Cancelling ranged attack, ' .. ammo .. ' equipped'
        );
        equip({ ammo = CheapAmmo })
        cancel_spell();
        return true;
    end
    return false
end

function pretarget(spell)
    MidCastGear = {}
    AfterCastGear = {};
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    if '/weaponskill' == spell.prefix then
        local chosenSet = sets.elemental.ratk

        -- Handle all weaponskill stuff
        if table.contains(marksmanship_ws, spell.name) then
            if stop_wasting_bullets() then
                return;
            end

            -- We want to equip cheap ammo after shooting
            AfterCastGear.ammo = CheapAmmo

            local chosenAmmo = CheapAmmo;

            if 'Slug Shot' == spell.name then
                chosenSet = sets.elemental.racc
                chosenAmmo = SlugWinderAmmo
            elseif 'Wildfire' == spell.name then
                if "Fire" == world.weather_element or
                    "Fire" == world.day_element then
                    MidCastGear.waist = 'Karin Obi'
                end

                if buffactive['transcendency'] then
                    chosenAmmo = "Orichalc. Bullet";
                    chosenSet = sets.elemental.WildFireBrew
                    if "Fire" == world.day_element then
                        MidCastGear.ring1 = 'Zodiac Ring'
                    end
                else
                    chosenSet = sets.elemental.WildFire
                end
            elseif 'Leaden Salute' == spell.name then
                chosenSet = sets.elemental.WildFire
            else
                chosenAmmo = HighDamAmmo
            end
            chosenSet = set_combine(chosenSet, { ammo = chosenAmmo });
        else
            chosenSet = sets.elemental.ws;
        end
        equip(chosenSet);
    elseif '/range' == spell.prefix then
        if stop_wasting_bullets() then
            return;
        end

        -- Fall back to cheap ammo after shooting
        AfterCastGear.ammo = CheapAmmo

        equip(set_combine(sets.elemental.ratk, { ammo = SlugWinderAmmo }));
    elseif '/magic' == spell.prefix  then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    elseif '/jobability' == spell.prefix  then
        if string.endswith(spell.name, ' Roll') then
            local rollData = LuckyRolls[spell.english];
            if rollData then
                CurrentRoll = spell.english;
                CurrentLucky = rollData.lucky
                CurrentUnlucky = rollData.unlucky

                add_to_chat(128, (
                    CurrentRoll .. ': ' ..
                    'Lucky: ' .. CurrentLucky .. ', ' ..
                    'Unlucky: ' .. CurrentUnlucky
                ));

                equip(get_roll_equipment(spell.english));
            else
                add_to_chat(128, 'Unknown roll ' .. spell.name);
            end
        elseif 'Double-Up' == spell.name then
            add_to_chat(128,
                'Double-Up on ' .. CurrentRoll .. ': ' ..
                'Lucky: ' .. CurrentLucky .. ', ' ..
                'Unlucky: ' .. CurrentUnlucky
            );
            equip(get_roll_equipment(CurrentRoll));
        elseif string.endswith(spell.name, ' Shot') then
            local qdEquip = { ammo = QuickDrawAmmo };

            -- Equip cheap ammo afterwards
            AfterCastGear.ammo = CheapAmmo

            -- TODO: test if this works!
            -- Check for elemental obi
            daw_gear = get_day_and_weather_gear(spell);
            if daw_gear then
                qdEquip = set_combine(qdEquip, daw_gear)
            end

            -- Use Zodiac ring on non dark/light days when matching day
            if spell.element == world.day_element and
                not 'Dark' == world.day_element and
                not 'Light' == world.day_element then
                qdEquip.ring1 = 'Zodiac Ring';
            end

            equip(set_combine(sets.elemental.QuickDraw, qdEquip))
        elseif 'Triple Shot' == spell.name then
            equip({ body = "Navarch's Frac +2" })
        end
    end
end

function midcast(spell)
    cancel_buffs(spell);
    if table.length(MidCastGear) > 0 then
        equip(MidCastGear)
    end
end

function aftercast(spell)
    equip(set_combine(sets.elemental.Standard, AfterCastGear));
end

function status_change(new,old)
    if "Idle" == new then
        equip(sets.elemental.Idle);
    elseif "Resting" == new then
        equip(sets.elemental.resting);
    end
end

function filtered_action(spell)
    -- Trigger updateammo by trying to cast Thunder IV
    if(spell.name == "Thunder IV") then
        cancel_spell();
        self_command("updateammo");
        return;
    end
end

function self_command(command)
    if "updateammo" == command then
        for i, ammo in ipairs(CheapAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo] then
                CheapAmmo = ammo;
            end
        end
        for i, ammo in ipairs(HighDamageAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo] then
                HighDamAmmo = ammo;
            end
        end
        SlugWinderAmmo = HighDamAmmo;
        for i, ammo in ipairs(SlugWinderAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo] then
                SlugWinderAmmo = ammo;
            end
        end
        QuickDrawAmmo = HighDamAmmo;
        for i, ammo in ipairs(QuickDrawAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo] then
                QuickDrawAmmo = ammo;
            end
        end

        add_to_chat(128, "Ammo summary:");
        add_to_chat(128, "- High Damage Ammo: " .. HighDamAmmo);
        add_to_chat(128, "- SlugWinder Ammo:  " .. SlugWinderAmmo);
        add_to_chat(128, "- Quick Draw Ammo:  " .. QuickDrawAmmo);
        add_to_chat(128, "- Cheap Ammo:       " .. CheapAmmo);
    end
end


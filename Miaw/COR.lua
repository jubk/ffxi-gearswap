
include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

function get_sets()
    -- Variables

    CurrentRoll = nil;
    CurrentLucky = 0;
    CurrentUnlucky = 0;

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
    sets.base = {
        head = "Laksamana's Hat +1",
        neck = "Stoicheion medal",
        ear1 = "Volley Earring",
        ear2 = "Hecate's Earring",
        -- Matk +25, acc +15 (or more), +15 atk
        body="Rawhide Vest",
        hands="Pursuer's Cuffs",
        -- hands = "Lak. Gants +1",
        ring1 = "Solemn Ring",
        ring2 = "Sattva Ring",
        back="Gunslinger's Cape",
        waist = "Aquiline Belt",
        legs = "Lak. Trews +1",
        feet = "Vanir Boots",
    };
    sets.quickdraw = set_combine(
        sets.base,
        {
            neck = "Stoicheion medal",
            left_ear="Friomisi Earring",
            right_ear="Hecate's Earring",
            -- TODO: Carmine Fin. Ga./Shinryu Abjuration: Hands/
            --       Bewitched finger gauntlets/7mill/Tenodera T1 EschaNM
            hands="Pursuer's Cuffs",
            -- hands = "Schutzen Mittens",
            ring1 = "Demon's Ring",
            ring2 = "Arvina Ringlet +1",
            waist = "Aquiline Belt",
            -- +20% damage from matching element for 15 seconds
            feet = "Chasseur's Bottes",
            -- matk +14, macc +10
            back="Gunslinger's Cape",
            -- AGI+20. macc +20, mdam +20
            -- back="Camulus's Mantle",
        }
    );

    sets.wildfire = set_combine(
        sets.quickdraw,
        {
            head = "Imp. Wing Hair. +1",
            -- hands = "Schutzen Mittens",
            ring1 = "Solemn Ring",
            ring2 = "Arvina Ringlet +1",
            -- TODO: Adhemar gamashes/Vexed Gamashes/10mill
            feet = "Vanir Boots",
            -- AGI+20. macc +20, mdam +20, wsdam +10
            back="Camulus's Mantle",
        }
    );

    sets.wildfirebrew = set_combine(
        sets.quickdraw,
        {
            ring1 = "Demon's Ring",
            ring2 = "Strendu Ring",
            -- AGI+20. macc +20, mdam +20, wsdam +10
            back="Camulus's Mantle",
        }
    );

    sets.idle = set_combine(
        sets.base, {
            feet = "Hermes' Sandals",
        }
    );

    sets.resting = set_combine(sets.base, {});

    sets.ranged_accuracy = set_combine(
        sets.base,
        {
            -- racc +42
            head="Meghanada Visor +1",
            -- racc +44
            body="Meg. Cuirie +1",
            -- racc +41
            hands="Meg. Gloves +1",
            -- racc +43
            legs="Meg. Chausses +1",
            -- racc +40
            feet="Meg. Jam. +1",
            -- racc +10
            neck="Sanctity Necklace",
            -- racc +10
            waist="Yemaya Belt",
            -- racc +15
            left_ring="Cacoethic Ring",
            -- racc +20
            back="Gunslinger's Cape",
        }
    );

    sets.ranged_attack = set_combine(sets.ranged_accuracy,{});

    sets.ws = set_combine(
        sets.base,
        {
            feet = "Chasseur's Bottes",
        }
    );

    set_has_hachirin_no_obi(true);
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
        local chosenSet = sets.ranged_attack

        -- Handle all weaponskill stuff
        if table.contains(marksmanship_ws, spell.name) then
            if stop_wasting_bullets() then
                return;
            end

            -- We want to equip cheap ammo after shooting
            AfterCastGear.ammo = CheapAmmo

            local chosenAmmo = CheapAmmo;

            if 'Slug Shot' == spell.name then
                chosenSet = sets.ranged_accuracy
                chosenAmmo = SlugWinderAmmo
            elseif 'Wildfire' == spell.name then
                if "Fire" == world.weather_element or
                    "Fire" == world.day_element then
                    MidCastGear.waist = 'Karin Obi'
                end

                if buffactive['transcendency'] then
                    chosenAmmo = "Orichalc. Bullet";
                    chosenSet = sets.wildfirebrew
                    if "Fire" == world.day_element then
                        MidCastGear.ring1 = 'Zodiac Ring'
                    end
                else
                    chosenSet = sets.wildfire
                end
            elseif 'Leaden Salute' == spell.name then
                chosenSet = sets.wildfire
            else
                chosenAmmo = HighDamAmmo
            end
            chosenSet = set_combine(chosenSet, { ammo = chosenAmmo });
        else
            chosenSet = sets.ws;
        end
        equip(chosenSet);
    elseif '/range' == spell.prefix then
        if stop_wasting_bullets() then
            return;
        end

        -- Fall back to cheap ammo after shooting
        AfterCastGear.ammo = CheapAmmo

        equip(set_combine(sets.ranged_attack, { ammo = SlugWinderAmmo }));
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

            equip(set_combine(sets.quickdraw, qdEquip))
        elseif 'Triple Shot' == spell.name then
            equip({ body = "Navarch's Frac +2" })
        elseif 'Random Deal' == spell.english then
            equip({ body = "Lanun Frac +1" })
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
    if "Idle" == player.status then
        equip(set_combine(sets.idle, AfterCastGear));
    else
        equip(set_combine(sets.base, AfterCastGear));
    end
end

function status_change(new,old)
    if "Idle" == new then
        equip(sets.idle);
    elseif "Resting" == new then
        equip(sets.resting);
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
            if player.inventory[ammo] or player.wardrobe[ammo]
               or player.wardrobe2[ammo] or player.wardrobe3[ammo]
               or player.wardrobe4[ammo] then
                CheapAmmo = ammo;
            end
        end
        for i, ammo in ipairs(HighDamageAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo]
               or player.wardrobe2[ammo] or player.wardrobe3[ammo]
               or player.wardrobe4[ammo] then
                HighDamAmmo = ammo;
            end
        end
        SlugWinderAmmo = HighDamAmmo;
        for i, ammo in ipairs(SlugWinderAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo]
               or player.wardrobe2[ammo] or player.wardrobe3[ammo]
               or player.wardrobe4[ammo] then
                SlugWinderAmmo = ammo;
            end
        end
        QuickDrawAmmo = HighDamAmmo;
        for i, ammo in ipairs(QuickDrawAmmoList) do
            if player.inventory[ammo] or player.wardrobe[ammo]
               or player.wardrobe2[ammo] or player.wardrobe3[ammo]
               or player.wardrobe4[ammo] then
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


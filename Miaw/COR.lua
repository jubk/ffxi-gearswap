
include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

local herc_matk = require("shared/herc_matk_gear");

--              AF/Relic/Empyrean gear status
--
--  AF       | Base | B +1 | Rf | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |      |    |   X   |       |       |
--   body    |      |      |    |       |       |   X   |
--   hands   |      |      |    |   X   |       |       |
--   legs    |      |      |    |       |   X   |       |
--   feet    |      |      |    |       |       |       |
--
--  Relic    | Base | Base +1 | Base +2 | RF | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |         |         | X  |       |       |       |
--   body    |      |         |         |    |   X   |       |       |
--   hands   |      |         |         |    |   X   |       |       |
--   legs    |      |         |         | X  |       |       |       |
--   feet    |      |         |         |    |       |       |   X   |
--
--  Empyrean | Base | Base +1 | Base +2 | RF | Rf +1 |
--   head    |      |         |         | X  |       |
--   body    |      |         |         | X  |       |
--   hands   |      |         |         |    |   X   |
--   legs    |      |         |    X    |    |       |
--   feet    |      |         |         | X  |       |
--

local AF = {
    head="Lak. Hat +1",
    body="Laksa. Frac +3",
    hands="Lak. Gants +1",
    legs="Laksa. Trews +2",
};

local relic = {
    head="Lanun Tricorne",
    body="Lanun Frac +1",
    hands="Lanun Gants +1",
    legs="Lanun Trews",
    feet="Lanun Bottes +3",
};

local empy = {
    head="Chass. Tricorne",
    body="Chasseur's Frac +1",
    hands="Chasseur's Gants +1",
    legs="Chas. Culottes",
    feet="Chasseur's Bottes",
};

local ambu = {
    head="Meghanada Visor +2",
    body="Meg. Cuirie +2",
    hands="Meg. Gloves +2",
    legs="Meg. Chausses +2",
    feet="Meg. Jam. +2",
}

local capes = {
    storetp = {
        name="Camulus's Mantle",
        augments={
            'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10',
        }
    },
    matk = {
        name="Camulus's Mantle",
        augments={
            'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10',
            'Weapon skill damage +10%',
        }
    },
}

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua');
end

function job_setup()
    -- Variables

    CurrentRoll = nil;
    CurrentLucky = 0;
    CurrentUnlucky = 0;

    CheapAmmoList = {
        "Divine Bullet",
        "Devastating Bullet",
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
        "Midrium Bullet",
        "Eminent Bullet",
        "Divine Bullet",
        "Devastating Bullet",
    };

    -- QuickDrawAmmo defaults to HighDamAmmo, but uses these if available:
    QuickDrawAmmoList = {
        "Orichalc. Bullet",
        "Eminent Bullet",
        "Animikii Bullet",
    };

    DontWasteBullets = T{
        "Oberon's Bullet",
        "Animikii Bullet",
    };

    -- Fallbacks for unconfigured ammo
    CheapAmmo = "Devastating Bullet";
    HighDamAmmo = "Devastating Bullet";
    QuickDrawAmmo = "Animikii Bullet";

    job_self_command("updateammo");

    marksmanship_ws = T{
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

    -- Add missing spell mappings
    extra_spell_mappings = {
        ['Light Shot'] = 'QuickDrawAcc', ['Dark Shot'] = 'QuickDrawAcc',
        ['Earth Shot'] = 'QuickDraw', ['Water Shot'] = 'QuickDraw',
        ['Wind Shot'] = 'QuickDraw', ['Fire Shot'] = 'QuickDraw',
        ['Ice Shot'] = 'QuickDraw', ['Thunder Shot'] = 'QuickDraw',
    }
    for k,v in pairs(extra_spell_mappings) do spell_maps[k] = v end

    magic_ws = {
        'Leaden Salute', 'Wildfire', 'Red Lotus Blade', 'Burning Blade',
        'Hot Shot', 'Shining Blade', 'Aeolian Edge', 'Cyclone',
        'Gust Slash', 'Energy Drain', 'Energy Steal'
    }

end

function init_gear_sets()

    -- sets
    sets.base = {
        head=ambu.head,
        body=ambu.body,
        hands=ambu.hands,
        legs=ambu.legs,
        feet=ambu.feet,
        neck="Sanctity Necklace",
        waist="Eschan Stone",
        left_ear="Digni. Earring",
        right_ear="Steelflash Earring",
        left_ring="Cacoethic Ring +1",
        right_ring="Arvina Ringlet +1",
        back="Gunslinger's Cape",
    };

    sets.precast.RA = set_combine(
        sets.base,
        {
            -- COR gifts: 10 snapshot
            -- Flurry is 15, flurry II is 30

            -- Snapshot +5
            head="Aurore Beret +1",
            -- Snapshot +9
            hands = relic.hands,
            -- Snapshot 10
            feet=ambu.feet,
            -- Rapid shot +20
            body=AF.body,
            -- Snapshot 8
            legs=AF.legs,
            -- Snapshot 6.5
            back="Navarch's Mantle",
            -- Snapshot 3
            waist="Impulse Belt",

            -- Total: 53.5
            -- Cap with no buffs: 60
            -- Cap with flurry: 45
            -- Cap with flurry II: 30
        }
    );

    sets.precast.JA.QuickDraw = set_combine(
        sets.base,
        {
            head=herc_matk.head,
            -- matk +29, macc +30
            body="Samnuha Coat",
            hands=herc_matk.hands,
            legs=herc_matk.legs,
            -- Quickdraw +22
            feet=empy.feet,
            -- matk 10, macc 10
            neck="Sanctity Necklace",
            -- matk 7, macc 7
            waist="Eschan Stone",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 6
            right_ear="Hecate's Earring",
            -- macc 7
            left_ring="Etana Ring",
            -- macc 3, matk 3
            right_ring="Arvina Ringlet +1",
            -- matk 14, macc 10
            back="Gunslinger's Cape",
        }
    );
    sets.precast.JA.QuickDrawAcc = set_combine(sets.precast.QuickDraw, {})

    -- +18% runspeed
    sets.idle = set_combine(sets.base, { legs="Carmine Cuisses +1" });

    sets.resting = set_combine(sets.base, {});

    sets.engaged = set_combine(sets.base, {});

    sets.midcast.RA = set_combine(
        sets.base,
        {
            -- racc +48, ratk +44
            head=ambu.head,
            -- racc +46, store TP +6, crit +9
            body="Mummu Jacket +2",
            -- racc +47, ratk +43
            hands=ambu.hands,
            -- racc +49, ratk +45
            legs=ambu.legs,
            -- racc +46, ratk +42
            feet=ambu.feet,
            -- ratk 25, store tp +5
            neck="Ocachi Gorget",
            -- racc +10, ratk +10, store tp +4
            waist="Yemaya Belt",
            -- racc +16
            left_ring="Cacoethic Ring +1",
            -- racc +6, ratk +6
            right_ring="Meghanada Ring",
            -- racc +4, store tp +2
            right_ear="Volley Earring",
            -- racc +30, ratk 20, AGI +20, store tp +10
            back=capes.storetp,
            -- TODO: Envervating Earring, vagary body boss
        }
    );


    sets.precast.WS = set_combine(sets.base, {
        -- wsd +10%
        body=AF.body,
        -- wsd +10,
        feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- WS boost
        waist="Fotia Belt",
    })

    sets.precast.WS.Magic = set_combine(
        sets.precast.WS,
        {
            head=herc_matk.head,
            -- matk +29, macc +30
            body="Samnuha Coat",
            hands=herc_matk.hands,
            legs=herc_matk.legs,
            -- matk +48, WSD+5
            feet=relic.feet,
            -- WS boost
            neck="Fotia Gorget",
            -- WS boost
            waist="Fotia Belt",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 8
            right_ear="Hecate's Earring",
            -- macc 7
            left_ring="Etana Ring",
            -- TODO: Acumen ring, matk 4%
            -- macc 3, matk 3, AGI 5
            right_ring="Arvina Ringlet +1",
            -- macc 20, mdam 20, wsdam 10, AGI 20
            back=capes.matk,
        }
    )

    sets.precast.WS.Marksmanship = set_combine(sets.midcast.RA, {
        ammo=HighDamAmmo,
        head={
            name="Herculean Helm",
            augments={
                'Weapon skill damage +4%',
                'DEX+9',
                'Rng.Acc.+6',
                'Rng.Atk.+10',
            }
        },
        -- racc 57, ratk 35, wsd +10%
        body=AF.body,
        legs={
            name="Herculean Trousers",
            augments={
                'Rng.Acc.+15',
                'Weapon skill damage +3%',
                'STR+10',
                'Rng.Atk.+13',
            }
        },
        -- wsd +10,
        feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- WS boost
        waist="Fotia Belt",
    });

    sets.precast.WS["Wildfire"] = set_combine(
        sets.precast.WS.Magic,
        { ammo=CheapAmmo, }
    );
    sets.precast.WS["Leaden Salute"] = set_combine(
        sets.precast.WS["Wildfire"],
        {
            head="Pixie Hairpin +1",
            left_ring="Apate Ring",
            neck="Sanctity Necklace",
            waist="Eschan Stone",
        }
    );

    sets.precast.FC = set_combine(
        sets.base,
        {
            -- fast cast +12
            head="Carmine Mask",
            -- fast cast +4
            neck = "Voltsurge Torque",
            -- fast cast +2
            body="Samnuha Coat",
            -- Fast cast +2
            right_ear="Loquac. Earring",
            -- fast cast 2
            left_ring="Prolix Ring",
        }
    );

    sets.TripleShot = set_combine(
        sets.midcast.RA,
        {
            -- Triple shot +4, Triple Shot Damage +10
            head="Oshosi Mask",
            -- Triple shot +12
            body=empy.body,
            -- racc +4, store tp +2
            right_ear="Volley Earring",
            -- Triple Shot +5
            back=capes.storetp,
        }
    )

    sets.precast.CorsairRoll = {
        -- duration +50
        hands=empy.hands,
        -- phantom roll effects +50 (chance to proc job-present-boost)
        head = relic.head,
        -- phantom roll +7
        neck="Regal Necklace",
        -- increased area of effect
        left_ring="Luzaf's Ring",
        -- duration +30
        back=capes.matk,
    }

    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(
        sets.precast.CorsairRoll, { head=empy.head }
    )
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(
        sets.precast.CorsairRoll, { hands=empy.hands }
    )
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(
        sets.precast.CorsairRoll, {body=empy.body}
    )
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(
        sets.precast.CorsairRoll, { legs=empy.legs }
    )
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(
        sets.precast.CorsairRoll, { feet = empy.feet }
    )

    sets.precast.JA['Triple Shot'] = set_combine(
        sets.base, { body=empy.body }
    )
    sets.precast.JA['Random Deal'] = set_combine(
        sets.base, { body=relic.body }
    )
    sets.precast.JA['Wild Card'] = set_combine(
        sets.base, { feet=relic.feet }
    )
    sets.precast.JA['Snake Eye'] = set_combine(
        sets.base, { legs=relic.legs }
    )

    set_has_hachirin_no_obi(true);
    -- COR can't equip Twilight Cape
    set_has_twilight_cape(false);
end

function stop_wasting_bullets(eventArgs)
    local ammo = player.equipment.ammo
    if table.contains(DontWasteBullets, ammo) then
        add_to_chat(
            128,
            'Cancelling ranged attack, ' .. ammo .. ' equipped'
        );
        equip({ ammo = CheapAmmo })
        eventArgs.cancel = true
        return true;
    end
    return false
end

function job_pretarget(spell, eventArgs)
    if table.contains(magic_ws, spell.english) then
        classes.CustomClass = "Magic"
    end
end

function job_precast(spell, eventArgs)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    if '/weaponskill' == spell.prefix then
        if table.contains(marksmanship_ws, spell.english) then
            if stop_wasting_bullets(eventArgs) then
                return;
            end
        end
        equip(get_day_and_weather_gear(spell))
    elseif '/range' == spell.prefix then
        if stop_wasting_bullets(eventArgs) then
            return;
        end
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
            else
                add_to_chat(128, 'Unknown roll ' .. spell.name);
            end
        elseif 'Double-Up' == spell.name then
            add_to_chat(128,
                'Double-Up on ' .. CurrentRoll .. ': ' ..
                'Lucky: ' .. CurrentLucky .. ', ' ..
                'Unlucky: ' .. CurrentUnlucky
            );
        elseif spell.english:endswith(' Shot') then
            equip(get_day_and_weather_gear(spell))
        end
    end
end

function job_post_precast(spell, eventArgs)
    if '/weaponskill' == spell.prefix then
        equip(get_day_and_weather_gear(spell))
    elseif '/jobability' == spell.prefix  then
        if spell.english:endswith(' Shot') then
            equip(get_day_and_weather_gear(spell))
        end
    end
end

function job_post_midcast(spell, eventArgs)
    if '/magic' == spell.prefix  then
        equip(get_day_and_weather_gear(spell))
    end
    if spell.action_type == 'Ranged Attack' and buffactive['Triple Shot'] then
        equip(sets.TripleShot)
    end
end


function job_aftercast(spell, eventArgs)
    equip({ ammo=CheapAmmo })
end

function filtered_action(spell)
    -- Trigger updateammo by trying to cast Thunder IV
    if(spell.name == "Thunder IV") then
        cancel_spell();
        self_command("updateammo");
        return;
    end
end

function job_self_command(command)
    if "updateammo" == command then
        local sacks = {
            player.inventory,
            player.wardrobe, player.wardrobe2,
            player.wardrobe3, player.wardrobe4,
        }
        for i, ammo in ipairs(CheapAmmoList) do
            for i, sack in ipairs(sacks) do
                if sack[ammo] then
                    CheapAmmo = ammo;
                    break
                end
            end
        end
        for i, ammo in ipairs(HighDamageAmmoList) do
            for i, sack in ipairs(sacks) do
                if sack[ammo] then
                    HighDamAmmo = ammo;
                    break
                end
            end
        end
        QuickDrawAmmo = HighDamAmmo;
        for i, ammo in ipairs(QuickDrawAmmoList) do
            for i, sack in ipairs(sacks) do
                if sack[ammo] then
                    QuickDrawAmmo = ammo;
                    break
                end
            end
        end

        add_to_chat(128, "Ammo summary:");
        add_to_chat(128, "- High Damage Ammo: " .. HighDamAmmo);
        add_to_chat(128, "- Quick Draw Ammo:  " .. QuickDrawAmmo);
        add_to_chat(128, "- Cheap Ammo:       " .. CheapAmmo);
    end
end

include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

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
--   head    |      |         |         |    |       |   X   |       |
--   body    |      |         |         |    |       |       |   X   |
--   hands   |      |         |         |    |   X   |       |       |
--   legs    |      |         |         |    |   X   |       |       |
--   feet    |      |         |         |    |       |       |   X   |
--
--  Empyrean | Base | Base +1 | Base +2 | RF | Rf +1 |
--   head    |      |         |         |    |   X   |
--   body    |      |         |         |    |   X   |
--   hands   |      |         |         |    |   X   |
--   legs    |      |         |         |    |   X   |
--   feet    |      |         |         |    |   X   |
--

local AF = {
    head="Lak. Hat +1",
    body="Lak. Frac +1",
    hands="Lak. Gants +1",
    legs="Laksa. Trews +1",
    feet="Lak. Bottes +1",
};

local relic = {
    head="Comm. Tricorne",
    body="Commodore Frac",
    hands="Commodore Gants",
    legs="Comm. Trews",
    feet="Comm. Bottes",
};

local empy = {
    head="Navarch's Tricorne",
    body="Nvrch. Frac +2",
    hands="Navarch's Gants",
    legs="Navarch's Culottes",
    feet="Chass. Bottes",
};

local ambu = {
    head="Meghanada Visor +1",
    body="Meg. Cuirie +1",
    hands="Meg. Gloves +1",
    legs="Meg. Chausses +1",
    feet="Meg. Jam. +1",
}

local capes = {
    --storetp = {
    --    name="Camulus's Mantle",
    --    augments={
    --        'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','"Store TP"+10',
    --    }
    --},
    --matk = {
    --    name="Camulus's Mantle",
    --    augments={
    --        'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10',
    --        'Weapon skill damage +10%',
    --    }
    --},
    --ranged_ws={
    --    name="Camulus's Mantle",
    --    augments={
    --        'AGI+20','Rng.Acc.+20 Rng.Atk.+20',
    --        'AGI+10','Weapon skill damage +10%',
    --    }
    --},
    --melee_tp={
    --    name="Camulus's Mantle",
    --    augments={
    --        'DEX+20','Accuracy+20 Attack+20','Accuracy+5','"Store TP"+10',
    --    }
    --},
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
        "Orichalc. Bullet",
        "Steel Bullet",
        "Bullet",
        "Paktong Bullet",
        "Iron Bullet",
        "Bronze Bullet",
        "Tin Bullet",
        "Eminent Bullet",
        "Chrono Bullet",
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
        "Chrono Bullet",
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
    CheapAmmo = "Bronze Bullet";
    HighDamAmmo = "Bronze Bullet";
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
        left_ring="Cacoethic Ring",
        right_ring="Defending Ring",
        back="Gunslinger's Cape",
    };

    sets.precast.RA = set_combine(
        sets.base,
        {
            -- COR gifts: 10 snapshot
            -- Flurry is 15, flurry II is 30

            -- Snapshot +5
            --head="Aurore Beret +1",
            -- Rapid shot +20
            --body=AF.body,
            -- Snapshot +9
            --hands = relic.hands,
            -- Snapshot +10, Triple shot +5
            --legs="Oshosi Trousers",
            -- Snapshot 10
            feet=ambu.feet,
            -- snapshot +2, racc +15
            --neck="Commodore Charm",
            -- Snapshot 3
            --waist="Impulse Belt",
            -- Snapshot 6.5
            --back="Navarch's Mantle",

            -- Total: 57.5
            -- Cap with no buffs: 70
            -- Cap with flurry: 55
            -- Cap with flurry II: 40
        }
    );

    sets.precast.JA.QuickDraw = set_combine(
        sets.base,
        {
            --head=herc_matk.head,
            -- matk +29, macc +30
            body="Samnuha Coat",
            --hands=herc_matk.hands,
            --legs=herc_matk.legs,
            -- Quickdraw +25
            feet=empy.feet,
            -- matk 10, macc 10
            neck="Sanctity Necklace",
            -- matk 7, macc 7
            waist="Eschan Stone",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 6
            right_ear="Hecate's Earring",
            -- matk 4
            left_ring="Acumen Ring",
            -- macc 3, matk 3
            --right_ring="Arvina Ringlet +1",
            -- Store TP +10
            --capes.storetp
        }
    );
    sets.precast.JA.QuickDrawAcc = set_combine(sets.precast.QuickDraw, {
        -- macc +15
        --neck="Commodore Charm",
    })

    -- +18% runspeed
    sets.idle = set_combine(sets.base, { legs="Carmine Cuisses +1" });

    sets.resting = set_combine(sets.base, {});

    sets.engaged = set_combine(sets.base, {
        -- Store TP +6
        --body="Mummu Jacket +2",
        -- Store TP +7, DA +3, TA +3
        legs="Samnuha Tights",
        -- Store TP +8
        neck="Iskur Gorget",
        -- Store TP +3, acc +6, DA +3
        right_ear="Cessance Earring",
        -- Store TP +1-5, DA +3
        waist="Kentarch Belt +1",
        -- Store TP +5
        right_ring="K'ayres Ring",

        -- store tp +10
        --back=capes.melee_tp,
    });
    -- Comment in for hybrid
    --sets.engaged = set_combine(sets.engaged, {neck="Loricate Torque +1",right_ring="Defending Ring",});

    sets.midcast.RA = set_combine(
        sets.base,
        {
            -- racc +48, ratk +44
            --head=ambu.head,
            -- racc +46, store TP +6, crit +9
            --body="Mummu Jacket +2",
            -- racc +47, ratk +43
            hands=ambu.hands,
            -- racc +49, ratk +45
            legs=ambu.legs,
            -- racc +46, ratk +42
            feet=ambu.feet,
            -- racc +30, ratk 30, store tp +8
            neck="Iskur Gorget",
            -- racc +10, ratk +10, store tp +4
            waist="Yemaya Belt",
            -- ratk +25, AGI+10, matk +10, recycle +10
            --left_ring="Dingir Ring",
            -- racc +6, ratk +6
            --right_ring="Meghanada Ring",
            -- ratk +4, store tp +4, agi +2
            left_ear="Neritic Earring",
            -- racc +4, store tp +2
            --right_ear="Volley Earring",
            -- racc +30, ratk 20, AGI +20, store tp +10
            --back=capes.storetp,
            -- TODO: Envervating Earring, vagary body boss
        }
    );


    sets.precast.WS = set_combine(sets.base, {
        -- wsd +10%
        --body=AF.body,
        -- wsd +10,
        --feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- ratk +25, matk +10, agi +10, recycle +10
        --left_ring="Dingir Ring",
        -- Atk +20, ratk +20, AGI+10
        --right_ring="Regal Ring",
        -- WS boost
        waist="Fotia Belt",
    })

    sets.precast.WS.Magic = set_combine(
        sets.precast.WS,
        {
            --head=herc_matk.head,
            -- matk +29, macc +30
            body="Samnuha Coat",
            --hands=herc_matk.hands,
            --legs=herc_matk.legs,
            -- matk +48, WSD+5
            --feet=relic.feet,
            -- WS boost
            neck="Fotia Gorget",
            -- WS boost
            waist="Fotia Belt",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 8
            right_ear="Hecate's Earring",
            -- ratk +25, matk +10, agi +10, recycle +10
            --left_ring="Dingir Ring",
            -- macc 3, matk 3, AGI 5
            --right_ring="Arvina Ringlet +1",
            -- macc 20, mdam 20, wsdam 10, AGI 20
            --back=capes.matk,
        }
    )

    sets.precast.WS.Marksmanship = set_combine(sets.midcast.RA, {
        ammo=HighDamAmmo,
        -- racc 27, ratk 72
        --head=relic.head,
        -- racc 57, ratk 35, wsd +10%
        body=AF.body,
        --legs="Herculean Trousers",
        -- wsd +10,
        --feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- WS boost
        waist="Fotia Belt",
        -- wsd +2
        right_ear="Ishvara Earring",
        -- Ratk +20, AGI+10
        --right_ring="Regal Ring",
        -- racc 20, ratk 20, wsd +10%
        --back=capes.ranged_ws,
    });

    sets.precast.WS["Wildfire"] = set_combine(
        sets.precast.WS.Magic,
        {
            --body=relic.body,
        }
    );
    sets.precast.WS["Leaden Salute"] = set_combine(
        sets.precast.WS["Wildfire"],
        {
            head="Pixie Hairpin +1",
            neck="Sanctity Necklace",
            --right_ear={name="Moonshade Earring",augments={'Rng.Atk.+4','TP Bonus +250',}},
            -- matk 4
            left_ring="Acumen Ring",
            --right_ring="Archon Ring",
            waist="Eschan Stone",
        }
    );
    sets.precast.WS["Last Stand"] = set_combine(
        sets.precast.WS.Marksmanship,
        {
            --left_ear={name="Moonshade Earring",augments={'Rng.Atk.+4','TP Bonus +250',}},
        }
    )

    sets.precast.WS["Savage Blade"] = set_combine(
        sets.precast.WS,
        {
            head="Meghanada Visor +1",
            --body=AF.body,
            hands="Meg. Gloves +1",
            legs="Meg. Chausses +1",
            --feet=relic.feet,
            waist="Eschan Stone",
            --left_ear={name="Moonshade Earring",augments={'Rng.Atk.+4','TP Bonus +250',}},
            right_ear="Ishvara Earring",
            left_ring="Cacoethic Ring",
            --right_ring="Apate Ring",
            --back=capes.ranged_ws
        }
    )

    sets.precast.FC = set_combine(
        sets.base,
        {
            -- fast cast +12
            --head="Carmine Mask",
            -- fast cast +4
            neck = "Voltsurge Torque",
            -- fast cast +3
            body="Samnuha Coat",
            -- Fast cast +2
            right_ear="Loquac. Earring",
            -- fast cast 2
            left_ring="Prolix Ring",
            -- fast cast 4
            right_ring="Kishar Ring",
        }
    );

    sets.TripleShot = set_combine(
        sets.midcast.RA,
        {
            -- Triple shot +4, Triple Shot Damage +10
            --head="Oshosi Mask",
            -- Triple shot +12
            body=empy.body,
            -- Snapshot +10, Triple shot +5
            --legs="Oshosi Trousers",
            -- racc +4, store tp +2
            --right_ear="Volley Earring",
            -- Triple Shot +5
            --back=capes.storetp,
        }
    )

    sets.precast.CorsairRoll = {
        -- phantom roll effects +50 (chance to proc job-present-boost)
        head = relic.head,
        -- duration +50
        --hands=empy.hands,
        -- phantom roll +7
        --neck="Regal Necklace",
        -- increased area of effect
        left_ring="Luzaf's Ring",
        -- phantom roll +5
        right_ring="Barataria Ring",
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
    if table.contains(magic_ws, spell.english)
       and not sets.precast.WS[spell.english] then
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

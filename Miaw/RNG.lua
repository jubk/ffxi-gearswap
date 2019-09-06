
include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

local herc_matk = require("shared/herc_matk_gear");
local herc_ratk_gear = require("shared/herc_ratk_gear");

-- MG inventory system
local mg_inv = require("mg-inventory");

local AF = {
    head = "Orion Beret +2",
    body = "Hunter's Jerkin",
    hands = "Hunter's Bracers",
    legs = "Hunter's Braccae",
    feet = "Hunter's Socks",
};

local relic = {
    head = "Scout's Beret",
    body = "Scout's Jerkin",
    -- hands = "Scout's Bracers",
    legs = "Scout's Braccae",
    feet = "Scout's Socks",
};

local empy = {
    -- head = "Sylvan Gapette",
    -- body = "Sylvan Caban",
    -- hands = "Sylvan Glovelettes",
    -- legs = "Sylvan Bragues",
    feet = "Sylvan Bottillons",
};

local ambu = {
    head="Meghanada Visor +2",
    body="Meg. Cuirie +2",
    hands="Meg. Gloves +2",
    legs="Meg. Chausses +2",
    feet="Meg. Jam. +2",
}

local capes = {
    snapshot={ name="Belenus's Cape", augments={'"Snapshot"+10',}},
    magic_ranged_ws={
        name="Belenus's Cape",
        augments={
            'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10',
            'Weapon skill damage +10%',
        }
    },
    store_tp={
        name="Belenus's Cape",
        augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','"Store TP"+10',}
    },
    ranged_ws={
        name="Belenus's Cape",
        augments={
            'AGI+20','Rng.Acc.+20 Rng.Atk.+20',
            'AGI+10','Weapon skill damage +10%',
        }
    },
}

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua');
end

function job_setup()
    -- Variables

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

    DontWasteBullets = T{
        "Oberon's Bullet",
        "Animikii Bullet",
    };

    -- Fallbacks for unconfigured ammo
    CheapAmmo = "Devastating Bullet";
    HighDamAmmo = "Devastating Bullet";

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

    magic_ws = {
        'Leaden Salute', 'Wildfire', 'Red Lotus Blade', 'Burning Blade',
        'Hot Shot', 'Shining Blade', 'Aeolian Edge', 'Cyclone',
        'Gust Slash', 'Energy Drain', 'Energy Steal', 'Trueflight'
    }

end

function init_gear_sets()

    -- sets
    sets.base = {
        -- main="Kustawi +1",
        -- sub="Nusku Shield",
        -- range="Armageddon",
        -- ammo="Devastating Bullet",

        head=ambu.head,
        body=ambu.body,
        hands=ambu.hands,
        legs=ambu.legs,
        feet=ambu.feet,
        neck="Ocachi Gorget",
        waist="Yemaya Belt",
        left_ear="Neritic Earring",
        right_ear="Volley Earring",
        left_ring="Mephitas's Ring +1",
        right_ring="Meghanada Ring",
        back=capes.store_tp,
    };

    sets.precast.RA = set_combine(
        sets.base,
        {
            -- Flurry is 15, flurry II is 30

            -- Snapshot +5
            head="Aurore Beret +1",
            -- Snapshot +12
            body="Oshosi Vest",
            -- Snapshot +8, rapid shot +11
            hands="Carmine Fin. Ga. +1",
            -- Snapshot +10
            legs="Oshosi Trousers",
            -- Snapshot 10
            feet=ambu.feet,
            -- Snapshot 3
            waist="Impulse Belt",
            -- Snapshot +10
            back=capes.snapshot

            -- Total: 58
            -- Cap with no buffs: 70
            -- Cap with flurry: 55
            -- Cap with flurry II: 40
        }
    );

    sets.idle = set_combine(sets.base, {
        -- +18% runspeed
        legs="Carmine Cuisses +1",
        -- dt -6
        neck="Loricate Torque +1",
        -- dt -7
        left_ring="Vocane Ring",
        -- dt -10
        right_ring="Defending Ring",
    });

    sets.resting = set_combine(sets.base, {});

    sets.engaged = set_combine(sets.base, {
        -- Store TP +6
        body="Mummu Jacket +2",
        -- Store TP +7, DA +3, TA +3
        legs={
            name="Samnuha Tights",
            augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}
        },
        -- Store TP +8
        neck="Iskur Gorget",
        -- Store TP 1-5, DA +3
        waist="Kentarch Belt +1",
        -- Store TP +3, DA +3
        right_ear="Cessance Earring",
        -- Store TP +5
        left_ring="Ilabrat Ring",
        back=capes.store_tp,
    });

    sets.midcast.RA = set_combine(
        sets.base,
        {
            -- racc +48, ratk +44
            head=ambu.head,
            -- racc +46, store TP +6, crit +9
            body="Mummu Jacket +2",
            -- racc +47, ratk +43
            hands=ambu.hands,
            -- racc +54, Store TP +8
            legs="Adhemar Kecks +1",
            -- racc +46, ratk +42
            feet=ambu.feet,
            -- racc +30, ratk 30, store tp +8
            neck="Iskur Gorget",
            -- racc +10, ratk +10, store tp +4
            waist="Yemaya Belt",
            -- ratk +25, AGI+10, matk +10, recycle +10
            left_ring="Dingir Ring",
            -- ratk +20, AGI+10
            right_ring="Regal Ring",
            -- ratk +4, store tp +4, agi +2
            left_ear="Neritic Earring",
            -- racc +7, , ratk 7, store tp +4
            right_ear="Enervating Earring",
            back=capes.store_tp,
        }
    );


    sets.precast.WS = set_combine(sets.base, {
        -- WS boost
        neck="Fotia Gorget",
        -- ratk +25, matk +10, agi +10, recycle +10
        left_ring="Dingir Ring",
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
            feet=herc_matk.feet,
            -- WS boost
            neck="Fotia Gorget",
            -- WS boost
            waist="Fotia Belt",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 8
            right_ear="Hecate's Earring",
            -- ratk +25, matk +10, agi +10, recycle +10
            left_ring="Dingir Ring",
            -- macc 3, matk 3, AGI 5
            right_ring="Arvina Ringlet +1",
            -- wsdam 10%, macc/mdam
            back=capes.magic_ranged_ws,
        }
    )

    sets.precast.WS.Marksmanship = set_combine(sets.midcast.RA, {
        ammo=HighDamAmmo,
        -- WS boost
        neck="Fotia Gorget",

        legs=herc_ratk_gear.legs,
        feet=herc_ratk_gear.feet,

        -- WS boost
        waist="Fotia Belt",
        -- WSD +2
        left_ear="Ishvara Earring",
        -- TP bonus +250
        right_ear="Moonshade Earring",
        -- ratk +20, AGI+10
        right_ring="Regal Ring",
        -- WSD+10, AGI+30
        back=capes.ranged_ws,
    });

    sets.precast.WS["Last Stand"] = set_combine(
        sets.precast.WS.Marksmanship, {
            body=ambu.body,
            -- ratk +20, AGI+10
            right_ring="Regal Ring",
        }
    );

    sets.precast.WS["Wildfire"] = set_combine(
        sets.precast.WS.Magic,
        {
            ammo=CheapAmmo,
            back=capes.magic_ranged_ws,
        }
    );
    sets.precast.WS["Trueflight"] = set_combine(
        sets.precast.WS["Wildfire"],
        {
            -- Matk +42
            hands="Carmine Fin. Ga. +1",
            neck="Sanctity Necklace",
            right_ear={
                name="Moonshade Earring",
                augments={'Rng.Atk.+4','TP Bonus +250',}
            },
            waist="Eschan Stone",
            back=capes.magic_ranged_ws,
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
    end
end

function job_post_precast(spell, eventArgs)
    if '/weaponskill' == spell.prefix then
        equip(get_day_and_weather_gear(spell))
    end
end

function job_post_midcast(spell, eventArgs)
    if '/magic' == spell.prefix  then
        equip(get_day_and_weather_gear(spell))
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

function job_self_command(command, eventArgs)
    if mg_inv.job_self_command(command, eventArgs) then
        return
    end
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

        add_to_chat(128, "Ammo summary:");
        add_to_chat(128, "- High Damage Ammo: " .. HighDamAmmo);
        add_to_chat(128, "- Cheap Ammo:       " .. CheapAmmo);
    end
end

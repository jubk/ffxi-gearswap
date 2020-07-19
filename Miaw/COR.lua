
include("remove_silence");
include("cancel_buffs");
include("elemental_obis");

local herc_matk = require("shared/herc_matk_gear")
local herc_ratk = require("shared/herc_ratk_gear")
local herc_tp = require("shared/herc_tp_gear")

-- MG inventory system
local mg_inv = require("mg-inventory");
-- MG library
local MG = require("mg-lib")

--              AF/Relic/Empyrean gear status
--
--  AF       | Base | B +1 | Rf | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |      |    |       |   X   |       |
--   body    |      |      |    |       |       |   X   |
--   hands   |      |      |    |       |   X   |       |
--   legs    |      |      |    |       |   X   |       |
--   feet    |      |      |    |       |       |   X   |
--
--  Relic    | Base | Base +1 | Base +2 | RF | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |         |         |    |       |       |   X   |
--   body    |      |         |         |    |       |       |   X   |
--   hands   |      |         |         |    |       |       |   X   |
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
    head="Laksa. Tricorne +2", -- Macc quickdraw
    body="Laksa. Frac +3",
    hands="Laksa. Gants +2", -- Macc quickdraw
    legs="Laksa. Trews +2", -- Not used
    feet="Laksa. Boots +3", -- Macc quickdraw
};

local relic = {
    head="Lanun Tricorne +3",
    body="Lanun Frac +3",
    hands="Lanun Gants +3",
    legs="Lanun Trews +1", -- Only used for Snake Eye
    feet="Lanun Bottes +3",
};

local empy = {
    head="Chass. Tricorne +1",
    body="Chasseur's Frac +1",
    hands="Chasseur's Gants +1",
    legs="Chas. Culottes +1",
    feet="Chass. Bottes +1",
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
    ranged_ws={
        name="Camulus's Mantle",
        augments={
            'AGI+20','Rng.Acc.+20 Rng.Atk.+20',
            'AGI+10','Weapon skill damage +10%',
        }
    },
    str_ws={
        name="Camulus's Mantle",
        augments={
            -- TODO: acc+5 => STR+10
            'STR+20','Accuracy+20 Attack+20','Accuracy+5','Weapon skill damage +10%',
        }
    },
    --melee_dual_wield={
    --    name="Camulus's Mantle",
    --    augments={
    --        'DEX+20','Accuracy+20 Attack+20','Accuracy+10',
    --        '"Dual Wield"+10','Phys. dmg. taken-10%',
    --    }
    --},
    melee_double_attack={
        name="Camulus's Mantle",
        augments={
            'DEX+20','Accuracy+20 Attack+20','Accuracy+10',
            '"Dbl.Atk."+10','Phys. dmg. taken-10%',
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
        "Chrono Bullet",
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
        "Chrono Bullet",
    };

    -- QuickDrawAmmo defaults to HighDamAmmo, but uses these if available:
    QuickDrawAmmoList = {
        "Orichalc. Bullet",
        "Eminent Bullet",
        "Animikii Bullet",
        "Living Bullet",
    };

    -- QuickDrawAmmo defaults to HighDamAmmo, but uses these if available:
    AccAmmoList = {
        "Living Bullet",
        "Chrono Bullet",
        "Devastating Bullet",
    };


    DontWasteBullets = T{
        "Oberon's Bullet",
        "Animikii Bullet",
    };

    -- Fallbacks for unconfigured ammo
    AccAmmo = "Devastating Bullet"
    CheapAmmo = "Devastating Bullet";
    HighDamAmmo = "Chrono Bullet";
    QuickDrawAmmo = "Divine Bullet";

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
    MG.hud.initialize({})

    -- sets
    sets.base = {
        head="Malignance Chapeau",
        body="Volte Jupon",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet=relic.feet,
        neck="Loricate Torque +1",
        waist="Eschan Stone",
        left_ear="Etiolation Earring",
        right_ear="Steelflash Earring",
        left_ring="Vocane Ring",
        right_ring="Defending Ring",
        back="Solemnity Cape",
    };

    state.CombatWeapon = M{
        ["description"] = "Weapon Mode",
        "Death Penalty",
        "Armageddon",
        "Fomalhaut",
        "Savage Blade",
        "Single Wield",
    }

    sets.weapons = {}
    sets.weapons.bullet = {
        waist="Liv. Bul. Pouch",
    }
    sets.weapons["Death Penalty"] = {
        main="Naegling",
        sub="Blurred Knife +1",
        range="Death Penalty",
    }
    sets.weapons["Armageddon"] = {
        main="Naegling",
        sub="Blurred Knife +1",
        range="Armageddon",
    }
    sets.weapons["Fomalhaut"] = {
        main="Naegling",
        sub="Blurred Knife +1",
        range="Fomalhaut",
    }
    sets.weapons["Single Wield"] = {
        main="Kustawi +1",
        sub="Nusku Shield",
        range="Armageddon",
    }
    sets.weapons["Savage Blade"] = {
        main="Naegling",
        sub="Blurred Knife +1",
        range={ name="Ataktos", augments={'Delay:+60','TP Bonus +1000',}},
    }

    MG.hud:add_mote_mode(state.CombatWeapon, {
        keybind="Ctrl-F10",
        autoequip_table=sets.weapons,
    })
    state.CombatWeapon:set("Death Penalty")

    sets.precast.RA = set_combine(
        sets.base,
        {
            -- COR gifts: 10 snapshot
            -- Flurry is 15, flurry II is 30
            ammo = AccAmmo,

            -- Snapshot +5
            head="Aurore Beret +1",
            -- Snapshot +12
            body="Oshosi Vest",
            -- snapshot +4, racc +25
            neck="Comm. Charm +2",
            -- Snapshot +8, rapid shot +11
            hands={
                name="Carmine Fin. Ga. +1",
                augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}
            },
            -- Snapshot +10, recycle +15
            legs={
                name="Adhemar Kecks +1",
                augments={'AGI+12','Rng.Acc.+20','Rng.Atk.+20',}
            },
            -- Snapshot +10
            feet="Meg. Jam. +2",
            -- Rapid shot +5
            waist="Yemaya Belt",
        
            -- Snapshot 6.5
            back="Navarch's Mantle",

            -- Total: 70.5
            -- Cap with no buffs: 70
            -- Cap with flurry: 55
            -- Cap with flurry II: 40
        }
    );

    sets.precast.JA.QuickDraw = set_combine(
        sets.base,
        {
            -- macc +25, matk +35
            ammo="Living Bullet",
            head=herc_matk.head,
            -- matk +61
            body=relic.body,
            -- matk +42, store tp +6
            hands={
                name="Carmine Fin. Ga. +1",
                augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}
            },
            legs=herc_matk.legs,
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
            -- matk +10
            left_ring="Dingir Ring",
            -- macc 3, matk 3
            right_ring="Arvina Ringlet +1",
            -- Store TP +10
            capes.storetp
        }
    );
    sets.precast.JA.QuickDrawAcc = set_combine(sets.precast.QuickDraw, {
        -- macc +56
        head=AF.head,
        -- macc +15
        neck="Comm. Charm +2",
        -- macc +53
        hands=AF.hands,
        -- macc +50
        legs="Malignance Tights",
        -- macc +52
        feet=AF.feet,
        -- macc +10
        left_ear="Digni. Earring",
        -- set bonus
        left_ring="Regal Ring",
        -- macc +7
        right_ring="Etana Ring",

        -- AF set bonus + regal ring = 30 macc
    })

    -- +18% runspeed
    sets.idle = set_combine(sets.base, { legs="Carmine Cuisses +1" });

    sets.resting = set_combine(sets.base, {});

    state.OffenseMode:options(
        "No haste",
        "Low haste",
        "Medium haste",
        "Full haste",
        "Single Wield"
    )

    MG.hud:add_mote_mode(state.OffenseMode, T{
        keybind="ctrl-f11",
        callback=function()
            if player.status == "Engaged" then
                MG.force_equip_set(get_melee_set())
            end
        end
    })

    state.HybridMode:options("Normal", "Hybrid")
    MG.hud:add_mote_mode(state.HybridMode, T{
        keybind="ctrl-f12",
        callback=function()
            if player.status == "Engaged" then
                MG.force_equip_set(get_melee_set())
            end
        end
    })

    sets.engaged = set_combine(sets.base, {
        -- TA +4
        head={
            name="Adhemar Bonnet +1",
            augments={'DEX+12','AGI+12','Accuracy+20',}
        },
        -- TA +4, dual wield +6
        body={
            name="Adhemar Jacket +1",
            augments={'DEX+12','AGI+12','Accuracy+20',}
        },
        -- DW+5, TA+2
        hands="Floral Gauntlets",

        -- Store TP +7, DA +3, TA +3
        legs={
            name="Samnuha Tights",
            augments={'STR+10','DEX+10','"Dbl.Atk."+3','"Triple Atk."+3',}
        },
        feet={
            name="Taeon Boots",
            augments={'Accuracy+22','"Dual Wield"+5','DEX+9',}
        },
        -- Store TP +8
        neck="Iskur Gorget",

        -- Dual Wield +5
        left_ear="Suppanomimi",

        -- Dual Wield +4
        right_ear="Eabani Earring",

        left_ring="Petrov Ring",

        -- TA +3, DA +3
        right_ring="Epona's Ring",

        -- DW +5
        waist="Shetal Stone",

        -- double attack +10
        back=capes.melee_double_attack,
    });
    sets.engaged["No haste"] = set_combine(sets.engaged, {
    })
    sets.engaged["Low haste"] = set_combine(sets.engaged, {
    })
    sets.engaged["Medium haste"] = set_combine(sets.engaged, {
        -- TA +4, store TP +7
        hands={
            name="Adhemar Wrist. +1",
            augments={'DEX+12','AGI+12','Accuracy+20',}
        },
    })
    sets.engaged["Full haste"] = set_combine(sets.engaged["Medium haste"], {
        -- TA +6, acc +35
        feet=herc_tp.feet,
        -- DA +5
        right_ear="Brutal Earring",
        waist="Windbuffet Belt +1",
    })
    sets.engaged["Single Wield"] = set_combine(sets.engaged, {
        -- Dual wield +6
        legs={
            name="Carmine Cuisses +1",
            augments={'Accuracy+20','Attack+12','"Dual Wield"+6',}
        },
        -- TA +6, acc +35
        feet=herc_tp.feet,
        -- TA +2, QA +2
        waist="Windbuffet Belt +1",
        -- Store TP +3, acc +6, DA +3
        left_ear="Cessance Earring",
        -- DA +5
        right_ear="Brutal Earring",
    })

    -- Hybrid melee sets
    sets.engaged.Hybrid = set_combine(sets.engaged, {
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        neck="Loricate Torque +1",
        legs="Malignance Tights",
        right_ring="Defending Ring",
    })
    for _, setname in ipairs({
        "No haste", "Low haste", "Medium haste", "Full haste", "Single Wield"
    }) do
        local set = sets.engaged[setname]
        set.Hybrid = set_combine(set, sets.engaged.Hybrid)
    end

    -- Acc swaps
    state.AccSwaps = M{['description'] = 'Acc Swaps'}
    state.AccSwaps:options("None", "MediumAcc", "HighAcc")
    MG.hud:add_mote_mode(state.AccSwaps, T{
        keybind="ctrl-home",
        callback=function()
            if player.status == "Engaged" then
                MG.force_equip_set(get_melee_set())
            end
        end
    })

    sets.acc = {}
    sets.acc.None = {
        -- Baseline acc: 1097
    }
    sets.acc.MediumAcc = {
        -- Baseline acc: 1180
        head="Malignance Chapeau",
        legs="Malignance Tights",
        waist="Olseni Belt",
        left_ear="Digni. Earring",
    }
    sets.acc.HighAcc = {
        -- Baseline acc: 1253
        head="Malignance Chapeau",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        -- TA +6, acc +35
        feet=herc_tp.feet,
        neck="Combatant's Torque",
        waist="Olseni Belt",
        left_ear="Digni. Earring",
        left_ring="Cacoethic Ring +1",
        right_ring="Cacoethic Ring",
    }

    -- Need (haste_factor * dual_wield_factor) <= 0.2

    local gear_haste_cap = 256
    local magic_haste_cap = 448

    function calc_delay()
        local gear_haste = 0
        local magic_haste = 0
        local ja_haste = 0
        local dw_level = 0
        
        if player.sub_job == "NIN" then
            dw_level = dw_level + 256
        elseif player.sub_job == "DNC" then
            dw_level = dw_level + 154
        end

        --  Haste I is 150/1024
        --  Haste II is 307/1024
        --  Idris GEO-haste is 418/1024
        --  Advancing march is 108/1024
        --  Vicotory march is 163/1024
        -- Honor march is 126/1024
        -- Magic haste cap is 448/1024
        -- Gear haste cap is 256/1024

        -- NIN subjob dual wield is 256/1024
        -- DNC subjob dual wield is 154/1024

    end

    sets.midcast.RA = set_combine(
        sets.base,
        {
            ammo = AccAmmo,
            -- racc +48, ratk +44
            head=ambu.head,
            -- racc +46, store TP +6, crit +9
            body="Mummu Jacket +2",
            -- racc +47, ratk +43
            hands=ambu.hands,
            -- racc +50, Store TP +10
            legs="Malignance Tights",
            -- racc +46, ratk +42
            feet=ambu.feet,
            -- racc +30, ratk 30, store tp +8
            neck="Iskur Gorget",
            -- racc +10, ratk +10, store tp +4
            waist="Yemaya Belt",
            -- ratk +25, AGI+10, matk +10, recycle +10
            left_ring="Dingir Ring",
            -- AGI +10, store TP +5
            right_ring="Ilabrat Ring",
            -- ratk +4, store tp +4, agi +2
            left_ear="Neritic Earring",
            -- racc +7, ratk +7, store tp +4
            right_ear="Enervating Earring",
            -- racc +30, ratk 20, AGI +20, store tp +10
            back=capes.storetp,
        }
    );
    sets.midcast.RA.MediumAcc = set_combine(sets.midcast.RA, {
        -- racc +25
        neck="Comm. Charm +2",
        body="Laksa. Frac +3",
        waist="Eschan Stone",
        left_ear="Volley Earring",
        left_ring="Cacoethic Ring +1",
        right_ring="Cacoethic Ring",
    });
    sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.MediumAcc, {});

    sets.midcast.RA.TripleShot = set_combine(
        sets.midcast.RA,
        {
            -- Triple shot +4, Triple Shot Damage +10
            head="Oshosi Mask",
            -- Triple shot +12
            body=empy.body,
            -- Racc 44, ratk 76, might become quad shot
            hands=relic.hands,
            -- Snapshot +10, Triple shot +5
            legs="Oshosi Trousers",
            -- racc +4, store tp +2
            right_ear="Volley Earring",
            -- Triple Shot +5
            back=capes.storetp,
        }
    )
    sets.midcast.RA.TripleShot.MediumAcc = set_combine(
        sets.midcast.RA.TripleShot,
        {
            waist="Eschan Stone",
            -- racc +4, store tp +2
            left_ear="Volley Earring",
            -- racc +7, ratk +7, store tp +4
            right_ear="Enervating Earring",
            left_ring="Cacoethic Ring +1",
            right_ring="Cacoethic Ring",
        }
    )
    sets.midcast.RA.TripleShot.HighAcc = sets.midcast.RA.TripleShot.MediumAcc

    sets.midcast.RA.TripleShotCrit = set_combine(
        sets.midcast.RA.TripleShot,
        {
            head=ambu.head,
            body=ambu.body,
            hands="Mummu Wrists +2",
            legs="Darraigner's Brais",
            feet="Oshosi Leggings",
            left_ring="Mummu Ring",
            right_ring="Begrudging Ring",
            -- TODO: K. Kachina Belt +1
            -- TODO: Critrate cape
        }
    )

    sets.midcast.RA.TripleShotCrit.MediumAcc = set_combine(
        sets.midcast.RA.TripleShotCrit,
        {
            legs="Malignance Tights",
            waist="Eschan Stone",
            -- racc +4, store tp +2
            left_ear="Volley Earring",
            -- racc +7, ratk +7, store tp +4
            right_ear="Enervating Earring",
            left_ring="Cacoethic Ring +1",
            right_ring="Cacoethic Ring",
        }
    )
    sets.midcast.RA.TripleShotCrit.HighAcc = sets.midcast.RA.TripleShotCrit.MediumAcc

    sets.precast.WS = set_combine(sets.base, {
        -- wsd +10%
        body=AF.body,
        -- wsd +10,
        feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- ratk +25, matk +10, agi +10, recycle +10
        left_ring="Dingir Ring",
        -- Atk +20, ratk +20, AGI+10
        right_ring="Regal Ring",
        -- WS boost
        waist="Fotia Belt",
    })

    sets.precast.WS.Magic = set_combine(
        sets.precast.WS,
        {
            -- macc +25, matk +35
            ammo="Living Bullet",
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
            -- ratk +25, matk +10, agi +10, recycle +10
            left_ring="Dingir Ring",
            -- macc 3, matk 3, AGI 5
            right_ring="Arvina Ringlet +1",
            -- macc 20, mdam 20, wsdam 10, AGI 20
            back=capes.matk,
        }
    )

    sets.precast.WS.Marksmanship = set_combine(sets.midcast.RA, {
        ammo=HighDamAmmo,
        -- racc 27, ratk 72
        head=relic.head,
        -- racc 57, ratk 35, wsd +10%
        body=AF.body,
        legs=herc_ratk.legs,
        -- wsd +10,
        feet=relic.feet,
        -- WS boost
        neck="Fotia Gorget",
        -- WS boost
        waist="Fotia Belt",
        -- wsd +2
        right_ear="Ishvara Earring",
        -- Ratk +20, AGI+10
        right_ring="Regal Ring",
        -- racc 20, ratk 20, wsd +10%
        back=capes.ranged_ws,
    });

    sets.precast.WS["Wildfire"] = set_combine(
        sets.precast.WS.Magic,
        {
            -- macc +25, matk +35
            ammo="Living Bullet",
            -- matk +7, mdam +25, AGI +15
            neck="Comm. Charm +2",
            body=relic.body,
        }
    );
    sets.precast.WS["Leaden Salute"] = set_combine(
        sets.precast.WS["Wildfire"],
        {
            -- macc +25, matk +35
            ammo="Living Bullet",
            head="Pixie Hairpin +1",
            -- matk +7, mdam +25, AGI +15
            neck="Comm. Charm +2",
            right_ear={
                name="Moonshade Earring",
                augments={'Rng.Atk.+4','TP Bonus +250',}
            },
            right_ring="Archon Ring",
            -- AGI +10
            waist="Svelt. Gouriz +1",
        }
    );
    sets.precast.WS["Last Stand"] = set_combine(
        sets.precast.WS.Marksmanship,
        {
            left_ear={
                name="Moonshade Earring",
                augments={'Rng.Atk.+4','TP Bonus +250',}
            },
        }
    )

    sets.precast.WS["Savage Blade"] = set_combine(
        sets.precast.WS,
        {
            head="Meghanada Visor +2",
            -- STR+15
            neck="Comm. Charm +2",
            body=AF.body,
            hands="Meg. Gloves +2",
            legs="Meg. Chausses +2",
            feet=relic.feet,
            waist="Prosilio Belt +1",
            left_ear={
                name="Moonshade Earring",
                augments={'Rng.Atk.+4','TP Bonus +250',}
            },
            right_ear="Ishvara Earring",
            left_ring="Regal Ring",
            right_ring="Apate Ring",
            back=capes.str_ws
        }
    )

    sets.precast.FC = set_combine(
        sets.base,
        {
            -- fast cast +12
            head="Carmine Mask",
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
    sets.precast.JA['Fold'] = {}
    sets.precast.JA['Fold'].DoubleBust = set_combine(
        sets.base, { hands=relic.hands }
    )

    sets.midcast["Hyoton: Ichi"] = {
        body="Volte Jupon",
        waist="Chaac Belt",
        feet="Volte Boots",
    }

    set_has_hachirin_no_obi(true);
    -- COR can't equip Twilight Cape
    set_has_twilight_cape(false);

    -- Setup macros and lockstyle
    set_macro_page(1, 6)
    send_command('pause 3; input /lockstyleset 2')

end

function customize_melee_set(set)
    -- Adjust melee sets with acc swaps
    local acc_swaps = sets.acc[state.AccSwaps.value or ""]
    if acc_swaps then
        return set_combine(set, acc_swaps)
    end
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
    if spell.action_type == 'Ranged Attack' then
        classes.CustomRangedGroups:clear()
        if buffactive['Triple Shot'] then
            if buffactive['Aftermath: Lv.3'] then
                classes.CustomRangedGroups:append("TripleShotCrit")
            else
                classes.CustomRangedGroups:append("TripleShot")
            end
        end
        if state.AccSwaps.value then
            classes.CustomRangedGroups:append(state.AccSwaps.value)
        end
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
        for i, ammo in ipairs(AccAmmoList) do
            for i, sack in ipairs(sacks) do
                if sack[ammo] then
                    AccAmmo = ammo;
                    break
                end
            end
        end

        add_to_chat(128, "Ammo summary:");
        add_to_chat(128, "- High Damage Ammo: " .. HighDamAmmo);
        add_to_chat(128, "- Quick Draw Ammo:  " .. QuickDrawAmmo);
        add_to_chat(128, "- Cheap Ammo:       " .. CheapAmmo);
        add_to_chat(128, "- Acc Ammo:         " .. AccAmmo);
    end
end

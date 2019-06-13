--[[

This SCH gearswap file will help with the following apart from the standard
functionality provided by the Mote libraries:

- Try to remove silence with echo drops.
- Downgrade high-tier spells to lower versions when low on MP.
- Automatically equip weather related gear when it is beneficial.
- Automatically idle in sublimation gear while sublimation is charging.
- Provide a simple way to do skillchains with commands like //sc fusion.
- Switch /lockstyleset depending on whether dark or ligth arts are up.
- Automatically switch to skillchain gear when Immanence is up.
- Always cast spells in MagicBurst gear as long as the MB window is up after
  performing a skillchain.
- Use relevant SCH Relic/AF/Empy gear when it is beneficial.

Commands:
 //sc <skillchainname>
  - Creates a skillchain using Immanence
  - Examples: //sc scission, //sc fusion
 //sc <element>
  - Creates a skillchain you can burst <element> on
  - Examples: //sc stone, //sc light
 //sc <name>+
  - Creates a fusion skillchain and enables Ebulience
  - Examples: //sc fusion+, //sc stone+
 //sc <name>++
  - Creates a fusion skillchain and enables Ebulience and Alacrity
  - Examples: //sc fusion++, //sc stone++

Note that the //sc alias can be changed, as it might conflict with a popular
addon. Search for "command_alias" in job_setup below.

TODO:
 - Make sublimation its own mode, so IdleMode can be used for actual
   different idlemodes.
 - Rewrite AutoImmanence to rely less on server feedback, since it sometimes
   breaks due to lag.

Latest version of this file can be downloaded from
  https://github.com/jubk/ffxi-gearswap/blob/master/Miaw/SCH.lua

--]]

-- Import functions that helps with calculating the need for weather gear.
-- If you do not have all the Obis change the elemental_obi_table at the top
-- of the file.
-- Latest version can be downloaded from
-- https://github.com/jubk/ffxi-gearswap/blob/master/common/day_and_weather.lua
include("day_and_weather");

-- Import AutoImmanence script that allows doing automatic skillchains.
-- Latest version can be downloaded from
-- https://github.com/jubk/ffxi-gearswap/blob/master/common/AutoImmanence.lua
local AutoImmanence = require("AutoImmanence");

-- Import mg_spelltools which will help with automatically switching to
-- light/dark arts and their addendi and downgrade spell tiers when low on MP.
-- Latest version can be downloaded from
-- https://github.com/jubk/ffxi-gearswap/blob/master/common/mg_spelltools.lua
local spelltools = require("mg_spelltools");

-- Load in augmented gear shared with outher jobs. If you do not have such
-- a file, remove this line and all references to "aug_gear" in the gearsets.
local aug_gear = require("shared/aug_gear");

-- Just for keeping track of AF/Relic/Empy progress:
--
--              AF/Relic/Empyrean gear status
--
--  AF       | Base | B +1 | Rf | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |      |    |       |       |   X   |
--   body    |      |      |    |       |       |   X   |
--   hands   |      |      |    |       |       |   X   |
--   legs    |      |      |    |       |       |   X   |
--   feet    |      |      |    |       |       |   X   |
--
--  Relic    | Base | Base +1 | Base +2 | RF | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |         |         |    |       |       |   X   |
--   body    |      |         |         |    |       |       |   X   |
--   hands   |      |         |         |    |       |       |   X   |
--   legs    |      |         |         |    |       |       |   X   |
--   feet    |      |         |         |    |       |       |   X   |
--
--  Empyrean | Base | Base +1 | Base +2 | RF | Rf +1 |
--   head    |      |         |         |    |   X   |
--   body    |      |         |         |  X |       |
--   hands   |      |         |         |    |   X   |
--   legs    |      |         |         |    |   X   |
--   feet    |      |         |         |    |   X   |
--

-- Update these tables when AF/relic/empy gear is upgraded
local AF = {
    head="Acad. Mortar. +3",
    body="Acad. Gown +3",
    hands="Acad. Bracers +3",
    legs="Acad. Pants +3",
    feet="Acad. Loafers +3",
}

local relic = {
    head="Peda. M.Board +3",
    body="Peda. Gown +3",
    hands="Peda. Bracers +3",
    legs="Peda. Pants +3",
    feet="Peda. Loafers +3",
}

local empy = {
    head="Arbatel Bonnet +1",
    body="Arbatel Gown +1",
    hands="Arbatel Bracers +1",
    legs="Arbatel Pants +1",
    feet="Arbatel Loafers +1",
}

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua');
end


function job_setup()
    -- Switch to SCH macro book and page
    set_macro_page(1, 10)

    -- Initialise map of spells MP cost
    spelltools.setup_spellcost_map(player);

    -- Setup AutoImmanence.
    auto_sc = AutoImmanence({
        -- The command alias to use, default is 'sc', so you can use
        -- //sc fusion to start a fusion skillchain
        command_alias='sc'
    })
    -- Make it possible to abort skilchains with alt-q and ctrl-q
    send_command('bind ^q gs c sc abort')
    send_command('bind !q gs c sc abort')

    -- Tell day and weather we have the combined obi
    set_has_hachirin_no_obi(true);
    set_has_twilight_cape(true);

    -- And tell it we will be using tier II storm buffs
    set_stormbuff_level(2)

    -- Lockstylesets. Set to nil or 0 to disable auto-changing
    light_arts_lockstyleset = 3
    dark_arts_lockstyleset = 18

    -- Add missing spell mappings
    extra_spell_mappings = {
        ['Pyrohelix II'] = 'Helix', ['Cryohelix II'] = 'Helix',
        ['Anemohelix II'] = 'Helix', ['Geohelix II'] = 'Helix',
        ['Ionohelix II'] = 'Helix', ['Hydrohelix II'] = 'Helix',
        ['Luminohelix II'] = 'Helix', ['Noctohelix II'] = 'Helix',

        ['Firestorm II'] = 'Storm', ['Hailstorm II'] = 'Storm',
        ['Windstorm II'] = 'Storm', ['Sandstorm II'] = 'Storm',
        ['Thunderstorm II'] = 'Storm', ['Rainstorm II']='Storm',
        ['Aurorastorm II'] = 'Storm', ['Voidstorm II']='Storm',
    }
    for k,v in pairs(extra_spell_mappings) do spell_maps[k] = v end

    state.CastingMode:options('Nuking', 'MagicBurst', 'Skillchain')

    state.IdleMode:options('Normal', 'Sublimation')
    if buffactive["Sublimation: Activated"] then
        state.IdleMode:set("Sublimation")
    end

    -- Variable for storing the original casting mode when temporarily
    -- changing it.
    OriginalCastingMode = nil

    -- Switch to default lockstyle
    if buffactive['Dark Arts'] and dark_arts_lockstyleset then
        send_command(
            'pause 3; input /lockstyleset ' .. dark_arts_lockstyleset
        )
    elseif light_arts_lockstyleset then
        send_command(
            'pause 3; input /lockstyleset ' .. light_arts_lockstyleset
        )
    end

end

function init_gear_sets()

    sets.standard = {
        -- pdt -20%
        main="Terra's staff",

        -- dt -5
        sub="Kaja Grip",

        -- dt -2, resistance to status debuffs 10, SIR -10
        ammo="Staunch Tathlum",

        -- Sublimation +4, fastcast +8%, matk +20, macc +52, int 37, mnd 37
        head=AF.head,

        -- macc 40, 22 dark arts skills, refresh +3
        body=AF.body,

        -- Haste +3%, Fast Cast +7%, int 24, mnd 38
        hands=AF.hands,

        -- haste +5%, int 44, mnd 39
        -- Light Arts +24
        legs=AF.legs,

        -- Casting time -12%, haste +3%, Enmity -7, int 27, mnd 24
        feet=AF.feet,

        -- dt -6
        neck="Loricate Torque +1",

        -- macc +4, matk +10
        waist="Refoccilation Stone",

        -- mdt -3, Fast cast +1
        left_ear="Etiolation Earring",

        -- Refresh +1, matk +4
        right_ear={ name="Moonshade Earring", augments={
            '"Mag.Atk.Bns."+4','Latent effect: "Refresh"+1',}
        },

        -- dam.taken -10
        left_ring="Defending Ring",

        -- dam.taken -7
        right_ring="Vocane Ring",

        -- dam.taken -5
        back="Lugh's Cape",
    };

    sets.idle.Field = set_combine(sets.standard, {
        -- Refresh +1
        feet="Volte Gaiters"
    });
    sets.idle.Town = set_combine(sets.standard, {});
    sets.idle.Field.Sublimation = set_combine(
        sets.idle.Field,
        {
            -- Sublimation +1
            main = "Siriti",

            -- defense / shield blocks
            sub = "Genmei Shield",

            -- Sublimation +4
            head=AF.head,

            -- Sublimation +5
            body=relic.body,

            -- Sublimation +1
            left_ear = "Savant's Earring",
        }
    );
    sets.idle.Town.Sublimation = set_combine(sets.idle.Field.Sublimation, {});

    sets.resting = set_combine(
        sets.standard,
        {
            -- rmp +10
            main = "Chatoyant Staff",

            -- rmp +2
            ammo = "Clarus Stone",

            -- rmp +4
            waist = "Austerity Belt",

            -- rmp +3
            back = "Felicitas Cape",
        }
    );

    sets.precast.FC = {
        -- Possible upgrades:
        --  * Hvergelmir i119 III staff, +50, (+47)
        --  * Augmented merlinic hood, 15 fast cast (+1)
        --  * Augmented merlinic feet, 12 fc (+2)
        --  * Grioavolr staff, up to +11 fastcast (+2), Bashmu reisen NM
        --  * Pinga Pants, fc 11 (+7), 8 mill
        --  * Enchntr. Earring +1, fc 2 (+1), 5 mill

        -- Fastcast +9
        main={
            name="Grioavolr",
            augments={
                '"Fast Cast"+5',
                'MP+32',
                'Mag. Acc.+9',
                'Magic Damage +3',
            }
        },

        -- Fastcast +2
        sub="Clerisy Strap",

        -- Fast cast +14
        -- Note: Replaced with Peda. M.Board under grimoire
        head={
            name="Merlinic Hood",
            augments={
                'Mag. Acc.+19 "Mag.Atk.Bns."+19',
                '"Fast Cast"+6',
                'CHR+5',
            }
        },
        -- Fast cast +13
        body="Pinga Tunic",
        -- Fast cast +4
        neck = "Voltsurge Torque",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- Fast Cast +9%
        hands=AF.hands,
        -- Fast cast +2
        ammo = "Incantor Stone",
        -- Fast cast +4
        back = "Swith Cape +1",
        -- Fast cast +4
        legs="Gyve Trousers",
        -- Fast cast +10
        -- Note: Replaced with Acad. Loafers +3 under grimoire
        feet={
            name="Merlinic Crackows",
            augments={
                '"Fast Cast"+5',
                '"Mag.Atk.Bns."+4',
            }
        },
        -- Fast cast +1
        left_ear="Etiolation Earring",
        -- Fast cast +2
        right_ear="Loquac. Earring",
        -- Fast cast +4
        left_ring="Kishar Ring",
        -- Fast cast +2
        right_ring="Prolix Ring",
        -- Elem. magic cast time -3%, auto-included when casting elemental
        -- magic
        -- left_ear="Barkaro. Earring",


        -- Total: 80%
        -- Total under grimoire: (total - 24) = 56%

        -- cap with non-fast-cast sub: 80
        -- cap with RDM sub: 65
    }
    sets.precast.FC['Elemental Magic'] = set_combine(
        sets.precast.FC,
        {
            -- Elemental magic casting time -3
            left_ear = "Barkaro. Earring"
        }
    )
    sets.precast.FC.Cure = set_combine(
        sets.precast.FC,
        {
            -- Cure casting time -15
            legs="Doyen Pants",
            -- Cure spellcasting time -8
            back = "Pahtli Cape"
        }
    )
    sets.precast.FC.Stoneskin = set_combine(
        sets.precast.FC,
        {
            -- Stoneskin casting time -10
            legs="Doyen Pants",
        }
    )

    sets.precast.JA["Enlightenment"] = { body=relic.body }
    sets.precast.JA["Tabula Rasa"] = { legs=relic.legs }


    sets.midcast['Elemental Magic'] = set_combine(
        sets.standard,
        {
            main = "Akademos",
            sub = "Niobid Strap",

            -- matk +47, macc +52 (aug)
            head=aug_gear.nuke.head,

            -- matk 4, macc 8, int 4
            ammo="Pemphredo Tathlum",

            -- macc 50, 24 dark arts skill, set acc bonus, refresh +3
            body=AF.body,

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- matk +8, macc 8
            left_ear="Barkaro. Earring",

            -- matk +7, INT +10
            right_ear="Regal Earring",

            -- int +43, macc 52, matk +53, haste +5%
            legs=aug_gear.nuke.legs,

            -- macc 6, matk 3, mb bonus 2
            left_ring="Jhakri Ring",

            -- macc +2, matk +4
            right_ring="Shiva ring +1",

            -- mb +7, macc 42, matk 39
            feet="Jhakri Pigaches +2",

            -- matk 10, macc 10
            neck="Sanctity Necklace",

            -- macc 20, matk 10, mdam 20, int+26
            back="Lugh's Cape",
        }
    );
    sets.midcast['Elemental Magic'].Nuking = set_combine(
        sets.midcast['Elemental Magic'], {}
    )

    sets.midcast['Elemental Magic'].Skillchain = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- Immanence: +11% damage
            hands=empy.hands,

            -- TODO: skillchain bonus +8
            -- legs="Amalric Slops",

            -- skillchain bonus +5
            right_ring="Mujin Band",

            -- skillchain bonus +10
            back="Lugh's Cape",
        }
    );

    sets.midcast['Elemental Magic'].MagicBurst = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- SCH staff is mbdam 10

            -- MB II+4, macc 37, matk 49, mb acc +15, elem magic skill +19
            head=relic.head,

            -- MB+10, matk 8
            neck="Mizu. Kubikazari",

            -- mb +10, macc 50, 24 dark arts skill, set acc bonus, refresh +3
            body=AF.body,

            -- MB II+5, macc 15, matk 38, elem. magic skill +13
            hands=aug_gear.burst.hands,

            -- int +43, macc 52, matk +53, haste +5%
            legs=aug_gear.nuke.legs,

            -- mb +7, macc 42, matk 39
            feet="Jhakri Pigaches +2",

            -- mb +5, macc 6, matk 3
            left_ring="Locus Ring",

            -- skillchain bonus, mb II 5%
            right_ring="Mujin Band",

            -- Cap is 40 for MB I, unknown for MB II
            -- 42% MB I, 14 MB II
        }
    );

    -- This set is meant to be combined with either nuking or magicburst
    sets.midcast.Helix = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- mdam +10
            ammo="Ghastly Tathlum",
            -- mdam +58
            body="Mallquis Saio",
            -- mdam +5
            left_ring="Mephitas's Ring +1",
        }
    )
    sets.midcast.Helix.Nuking = set_combine(sets.midcast.Helix, {})

    sets.midcast.Helix.MagicBurst = set_combine(
        sets.midcast['Elemental Magic'].MagicBurst,
        {
            -- mdam +10
            ammo="Ghastly Tathlum",
        }
    )


    sets.midcast['Dark Magic'] = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            head="Pixie Hairpin +1",
        }
    );

    sets.midcast['Dark Magic'].Drain = set_combine(
        sets.midcast['Dark Magic'],
        {
            head="Pixie Hairpin +1",
            -- Macc 17, dark magic skill 10, drain/aspir +5
            neck="Erra Pendant",
            -- drain/aspir +10
            right_ring="Evanescence Ring",
            -- drain/aspir +8
            waist = "Fucho-no-Obi",
            -- drain/aspir +15, dark magic skill +19
            legs = relic.legs,
            -- drain/aspir +7
            feet={
                name="Merlinic Crackows",
                augments={
                    '"Fast Cast"+5',
                    '"Mag.Atk.Bns."+4',
                }
            },
            -- matk +10, mdam +10, elem.skill +8, dark.skill +8, int +1, mnd +2,
            -- helix.duration +19
            back="Bookworm's Cape",
        }
    );
    sets.midcast['Dark Magic'].Aspir = sets.midcast['Dark Magic'].Drain;

    sets.midcast['Enfeebling Magic'] = set_combine(
        -- Set bonus from Academic gear: 60 macc from 5 pieces
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- Akademos: macc 25, macc skill 228
            main = "Akademos",
            -- Kaja Grip: macc 25, dt -5, enmity -4
            sub = "Kaja Grip",

            -- macc 8
            ammo="Pemphredo Tathlum",
            -- macc 52, set bonus
            head=AF.head,
            -- macc 50, set bonus
            body=AF.body,
            -- macc 38, set bonus
            hands=AF.hands,
            -- macc 57
            legs=aug_gear.acc.legs,
            -- macc 46, set bonus
            feet = AF.feet;
            -- macc 10
            neck="Sanctity Necklace",
            -- macc 10
            waist="Luminary Sash",
            -- INT 10, MND 10, set bonus
            left_ear="Regal Earring",
            -- macc 10
            right_ear="Digni. Earring",
            -- Fast cast +4, enf. duration +10
            left_ring="Kishar Ring",
            -- macc 7
            right_ring="Etana Ring",
            -- macc 20
            back="Lugh's Cape",
        }
    )

    sets.midcast['Healing Magic'] = set_combine(
        sets.standard,
        {
            main = "Chatoyant Staff",
            sub = "Enki Strap",

            -- Cure pot +5
            neck="Nodens Gorget",

            -- MND +39, healing.skill +19
            body=relic.body,

            -- Healing magic skill +19, cure pot II +3
            hands=relic.hands,

            -- Cure.pot +15
            legs=AF.legs,

            -- Cure potency +10%, healing magic +20
            feet = "Vanya Clogs",

            -- Cure potency +7%
            back="Solemnity Cape",

            -- healing magic skill +5
            waist="Bishop's Sash",

            -- Cure potency +5%
            right_ear="Mendi. Earring",

            -- MND +5
            left_ring="Solemn Ring",

            -- Healing magic +10
            right_ring="Sirona's Ring",
        }
    );

    sets.midcast['Enhancing Magic'] = set_combine(
        sets.standard,
        {
            -- enh. duration +5
            main="Gada",
            -- enh. duration +10
            sub="Ammurapi Shield",

            -- enhancing duration +9
            head={ name="Telchine Cap", augments={'Enh. Mag. eff. dur. +9',}},
            -- enhancing duration +12
            body=relic.body,
            -- enhancing duration +10
            hands={ name="Telchine Gloves",
                   augments={'"Cure" potency +4%','Enh. Mag. eff. dur. +10',}},
            -- enhancing duration +10
            legs={ name="Telchine Braconi",
                  augments={'Enh. Mag. eff. dur. +10',}},
            -- enhancing duration +9
            feet={ name="Telchine Pigaches",
                  augments={'Enh. Mag. eff. dur. +9',}},

            -- MND +10
            waist="Luminary Sash",

            -- MND +8
            back="Pahtli Cape",

            -- Enh.magic +7
            left_ear="Andoaa Earring",

            -- MND +5
            left_ring="Solemn Ring",
        }
    );

    sets.midcast['Enhancing Magic'].Regen = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            -- Regen +10
            main="Bolelabunga",
            -- Defence
            sub="Genmei Shield",
            -- Enh.magic +14, regen +15
            head=empy.head,
            -- matk +10, mdam +10, elem.skill +8, dark.skill +8, int +1, mnd +2,
            -- helix.duration +19
            back="Bookworm's Cape",
        }
    );

    sets.midcast['Enhancing Magic'].Stoneskin = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            -- Stonesking +30
            neck="Nodens Gorget",
        }
    );
end


function job_self_command(command, eventArgs)
    if auto_sc.self_command(command, eventArgs) then
        eventArgs.handled = true;
        return
    end
end

function remove_silence(spell)
    -- Do nothing if "spell" is not magic
    if not table.contains({'/magic','/ninjutsu','/song'}, spell.prefix) then
        return false
    end

    if buffactive['silence'] then
        if "DNC" == player.sub_job or "DNC" == player.main_job then
            send_command('input /ja "Healing Waltz" <me>');
        else
            send_command('input /item "Echo Drops" <me>');
        end
        return true;
    end

    return false;
end


function jobabilities_cancels_grimoire_fastcast()
    if buffactive["Alacrity"] then return true end;
    if buffactive["Manifestation"] then return true end;
    if buffactive["Celerity"] then return true end;
    if buffactive["Accession"] then return true end;
    return false;
end

function grimoire_is_active(spell)
    if spell.type == "BlackMagic" then
        if buffactive["Dark Arts"] or buffactive["Addendum: Black"] then
            return true;
        end
    elseif spell.type == "WhiteMagic" then
        if buffactive["Light Arts"] or buffactive["Addendum: White"] then
            return true;
        end
    end

    return false;
end

function filtered_action(spell)
    -- Check whether we should activate arts/addendum instead of casting
    -- the spell.
    if spelltools.check_addendum(spell) then
        cancel_spell();
        return;
    end
    auto_sc.filtered_action(spell)
end

-- Ensures that idle set is Sublimation whenever sublimation is charging.
function setup_idle_set(spell)
    local wanted_mode = "Normal"
    local spellname = (spell and spell.english) or "none"

    if buffactive["Sublimation: Activated"] then
        wanted_mode = "Sublimation"
    end

    if wanted_mode == state.IdleMode.current then
        -- If we're in the wanted mode, but accessing sublimation, swith to
        -- the other mode except for when Sublimation: Complete is up.
        if ("Sublimation" == spellname
            and not buffactive["Sublimation: Complete"]) then
            state.IdleMode:cycle()
            return true
        end
    else
        -- Switch mode, except when the spell is sublimation which will change
        -- the mode for us
        if "Sublimation" ~= spellname then
            state.IdleMode:cycle()
            return true
        end
    end

    return false
end

-- Overrides castingmode to Skillchain when Immanence is up and to
-- MagicBurst when auto_sc tells us we're in MB window from a skillchain.
function setup_temp_casting_mode(spell)
    OriginalCastingMode = nil
    if '/magic' == spell.prefix then
        if buffactive["Immanence"] then
            OriginalCastingMode = state.CastingMode.value
            state.CastingMode:set("Skillchain")
        elseif auto_sc.in_mb_window(spell) then
            OriginalCastingMode = state.CastingMode.value
            state.CastingMode:set("MagicBurst")
        end
    end
end

function get_weather_castingtime_gear(spell)
    if (buffactive["Celerity"] or buffactive["Alacrity"]) then
        local stormBuff = element_to_storm_buff[spell.element] or "";

        if spell.element == world.weather_element or
           (stormBuff and buffactive[stormBuff]) then
           return { feet=relic.feet }
        end
    end

    return {}
end

function job_pretarget(spell)
    setup_temp_casting_mode(spell)
end

function job_precast(spell, action, spellMap, eventArgs)

    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        eventArgs.cancel = true;
    end

    if spelltools.downgrade_spell(player, spell, eventArgs) then
        eventArgs.cancel = true;
    end

    auto_sc.precast(spell, eventArgs)

    if eventArgs.cancel then
        return;
    end

end

function job_post_precast(spell, action, spellMap, eventArgs)
    if '/magic' == spell.prefix then
        if grimoire_is_active(spell) then
            -- Certain job abilites does not stack with grimoire fastcast gear
            if not jobabilities_cancels_grimoire_fastcast() then
                equip({
                    -- Grimoire cast time -12
                    feet=AF.feet,
                    -- Grimoire cast time -12
                    head=relic.head,
                })
            end
        end

        -- Equip element-based fastcast staff
        equip(get_weather_castingtime_gear(spell))

        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end
end

function job_midcast(spell, action, spellMap, eventArgs)
    auto_sc.midcast(spell)
end


function job_post_midcast(spell, action, spellMap, eventArgs)
    if '/magic' == spell.prefix then
        if "Healing Magic" == spell.skill then
            if buffactive["Rapture"] then
                equip({ head=empy.head })
            end
        elseif "Elemental Magic" == spell.skill then
            -- +20% extra damage from Ebullience
            if buffactive["Ebullience"] then
                equip({ head=empy.head });
            end
            -- Straight 10% damage buff if we have klimaform active during
            -- correct weather.
            if (buffactive["Klimaform"] and
                weather_is_active(spell.element)) then
                equip({ feet=empy.feet })
            end
        elseif "Enfeebling Magic" == spell.skill then
            -- This should give more acc, even on light arts, as it gives
            -- enf +18 and macc +26.
            if grimoire_is_active(spell) then
                equip({ legs=empy.legs })
            end

            if "BlackMagic" == spell.type then
                -- +22 enf. skill from Dark Arts
                if grimoire_is_active(spell) then
                   equip({ body=AF.body });
                end
            else
                -- +24 enf. skill from Light Arts
                if grimoire_is_active(spell) then
                   equip({ legs=AF.legs });
                end
            end
        end

        -- Equip relevant weather gear
        equip(get_day_and_weather_gear(spell))
        -- Equip relevant weather-based recast gear
        equip(get_weather_castingtime_gear(spell))

        if (buffactive["Perpetuance"] or buffactive["Immanence"]) then
            equip({ hands=empy.hands });
        end

        if (buffactive["Penury"] or buffactive["Parsimony"]) then
            equip({ legs=empy.legs });
        end
    end
end


function job_aftercast(spell, action, spellMap, eventArgs)
    auto_sc.aftercast(spell)

    -- Reset CastingMode back to previous value if it was overwritten
    if OriginalCastingMode ~= nil then
        state.CastingMode:set(OriginalCastingMode)
        OriginalCastingMode = nil
    end

    setup_idle_set(spell)
end

function job_buff_change(buff, gain)
    if buff == "Sublimation: Activated" then
        if setup_idle_set(spell) and player.status == 'Idle' then
            handle_equipping_gear(player.status)
        end
    elseif "Light Arts" == buff then
        if gain and light_arts_lockstyleset then
            send_command('input /lockstyleset ' .. light_arts_lockstyleset)
        end
    elseif "Dark Arts" == buff then
        if gain and dark_arts_lockstyleset then
            send_command('input /lockstyleset ' .. dark_arts_lockstyleset)
        end
    end
end
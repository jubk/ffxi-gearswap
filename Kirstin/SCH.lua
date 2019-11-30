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

-- Gear with augments
local aug_gear = require('shared/aug_gear');

local AF = {
    head="Acad. Mortar. +3",
    body="Acad. Gown +3",
    hands="Acad. Bracers +3",
    legs="Acad. Pants +3",
    feet="Acad. Loafers +3",
}

local relic = {
    head="Peda. M.board +3",
    body="Pedagogy Gown +3",
    hands="Peda. Bracers +3",
    legs="Peda. Pants +3",
    feet="Peda. Loafers +3"
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

    -- Setup AutoImmanence.
    auto_sc = AutoImmanence({
        -- The command alias to use, default is 'sc', so you can use
        -- //sc fusion to start a fusion skillchain
        command_alias='sc'
    })
end

function job_setup()
    -- Switch to SCH macro book and page
    set_macro_page(1, 5)

    -- Initialise map of spells MP cost
    spelltools.setup_spellcost_map(player);

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
    dark_arts_lockstyleset = 3

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
        main="Earth staff",

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

        -- TODO: Replace with -dt?
        left_ear="Barkaro. Earring",

        -- Refresh +1, matk +4
        right_ear={ name="Moonshade Earring", augments={
            '"Mag.Atk.Bns."+4','Latent effect: "Refresh"+1',}
        },

        -- dam.taken -10
        left_ring="Defending Ring",

        -- pdt -7
        right_ring="Patricius Ring",

        -- dam.taken -5
        back="Lugh's Cape",
    };

    sets.idle.Field = set_combine(sets.standard, {});
    sets.idle.Town = set_combine(sets.standard, {});
    sets.idle.Field.Sublimation = set_combine(
        sets.idle.Field,
        {
            -- Sublimation +1
            main = "Siriti",

            -- defense / shield blocks
            sub="Ammurapi Shield",

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
            main = "Dark Staff",

            -- TODO: rmp +2
            -- ammo = "Clarus Stone",
        }
    );

    sets.engaged = set_combine(sets.standard, {
        -- Store TP +9
        legs="Jhakri Slops +2",
        -- Acc +10
        neck="Sanctity Necklace",
        -- Acc 20, store TP +3
        waist="Olseni Belt",
        -- Acc 10, Store TP +3
        left_ear="Digni. Earring",
        -- Store TP +4
        right_ear="Neritic Earring",
        -- Acc 10
        left_ring="Cacoethic Ring",
        -- Store TP +3
        right_ring="Apate Ring",
    });

    sets.precast.FC = {
        -- Possible upgrades:
        --  * Hvergelmir i119 III staff, +50, (+47)
        --  * Augmented merlinic hood, 15 fast cast (+2)
        --  * Augmented merlinic feet, 12 fc (+1)

        -- Fastcast +11
        main=aug_gear.fastcast.main,

        -- Fastcast +2
        sub="Clerisy Strap",

        -- Fast cast +13
        -- Note: Replaced with Peda. M.Board under grimoire
        head=aug_gear.fastcast.head,

        -- Fast cast +13
        body="Pinga Tunic",

        -- Fast cast +4
        neck = "Voltsurge Torque",

        -- Fast cast +2
        waist="Channeler's Stone",

        -- Fast Cast +7%
        hands=AF.hands,

        -- Fast cast +2
        ammo = "Incantor Stone",

        -- Fast cast +4
        back = "Swith Cape +1",

        -- Fast cast +11
        legs="Pinga Pants",

        -- Note: Replaced with Acad. Loafers +3 under grimoire
        -- fastcast +11
        feet=aug_gear.fastcast.feet,

        -- Fast cast +2
        left_ear="Enchntr. Earring +1",

        -- Fast cast +2
        right_ear="Loquac. Earring",

        -- Fast cast +4
        left_ring="Kishar Ring",

        -- Fast cast +2
        right_ring="Prolix Ring",


        -- Total: 88%
        -- Total under grimoire: (total - 24) = 64%

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

            -- TODO: Switch to relic body, when it is +3
            -- macc 50, 24 dark arts skill, set acc bonus, refresh +3
            body=AF.body,

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- matk +8, macc 8
            left_ear="Barkaro. Earring",

            -- matk +6, mcrit +3
            right_ear="Hecate's Earring",

            -- int +43, macc 52, matk +53, haste +5%
            legs=aug_gear.nuke.legs,

            -- macc 6, matk 3, mb bonus 2
            left_ring="Jhakri Ring",

            -- INT +10, matk +8
            right_ring="Freke Ring",

            -- mb +7, macc 42, matk 39
            feet="Jhakri Pigaches +2",

            -- matk 10, macc 10
            neck="Sanctity Necklace",

            -- macc 20, matk 10, mdam 20, int+30
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
            -- TODO: back="Lugh's Cape",
        }
    );

    sets.midcast['Elemental Magic'].MagicBurst = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- SCH staff is mbdam 10
            main = "Akademos",
            sub = "Niobid Strap",

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
            -- mdam +279
            main="Tupsimati",
            -- mdam +10
            ammo="Ghastly Tathlum",
            -- mdam +58
            body="Mallquis Saio +2",
            -- mdam +5
            left_ring="Mephitas's Ring +1",
        }
    )
    sets.midcast.Helix.Nuking = set_combine(sets.midcast.Helix, {})

    sets.midcast.Helix.MagicBurst = set_combine(
        sets.midcast['Elemental Magic'].MagicBurst,
        {
            -- mdam +279
            main="Tupsimati",
            -- mdam +10
            ammo="Ghastly Tathlum",
        }
    )


    sets.midcast['Dark Magic'] = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- Dark matk +28
            head="Pixie Hairpin +1",
        }
    );

    sets.midcast['Dark Magic'].Drain = set_combine(
        sets.midcast['Dark Magic'],
        {
            -- TODO:
            -- head="Pixie Hairpin +1",
            -- Macc 17, dark magic skill 10, drain/aspir +5
            neck="Erra Pendant",
            -- drain/aspir +10
            right_ring="Evanescence Ring",
            -- drain/aspir +8
            waist = "Fucho-no-Obi",
            -- drain/aspir +15, dark magic skill +19
            legs = relic.legs,
            -- drain/aspir +7
            -- TODO: feet="Merlinic Crackows",
        }
    );
    sets.midcast['Dark Magic'].Aspir = sets.midcast['Dark Magic'].Drain;

    sets.midcast['Enfeebling Magic'] = set_combine(
        -- Set bonus from Academic gear: 60 macc from 5 pieces
        sets.midcast['Elemental Magic'].Nuking,
        {
            -- Tupsimati: macc 40, macc skill 269
            main = "Tupsimati",

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
            -- macc 7
            waist="Eschan Stone",
            -- macc 7
            left_ear="Hermetic Earring",
            -- macc 10
            right_ear="Digni. Earring",
            -- Fast cast +4, enf. duration +10
            left_ring="Kishar Ring",
            -- macc 6
            right_ring="Jhakri Ring",
            -- macc 20
            -- TODO: back="Lugh's Cape",
        }
    )

    sets.midcast['Healing Magic'] = set_combine(
        sets.standard,
        {
            main = "Serenity",
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

            -- Cure potency +5%
            right_ear="Mendi. Earring",

            -- Cure pot II +5%
            left_ring="Janniston Ring",

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

            -- enhancing duration +10
            head=aug_gear.enh_duration.head,

            -- enhancing duration +12
            body=relic.body,

            -- Enh. duration +9
            hands=aug_gear.enh_duration.hands,

            -- enhancing duration +10
            legs=aug_gear.enh_duration.legs,

            -- Enh. duration +9
            feet=aug_gear.enh_duration.feet,

            -- MND +8
            back="Pahtli Cape",
        }
    );

    sets.midcast['Enhancing Magic'].Regen = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            -- Regen +10
            main="Bolelabunga",
            -- Defence
            sub="Ammurapi Shield",
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

    sets.precast.WS = set_combine(sets.standard, {})
    sets.precast.WS["Omniscience"] = set_combine(
        sets.midcast['Elemental Magic'].Nuking,
        {}
    );


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

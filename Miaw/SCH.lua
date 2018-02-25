include("remove_silence");
include("cancel_buffs");
include("day_and_weather");
include("spelltools");
include("shared/staves");
-- include("dumper");

local AutoImmanence = require("AutoImmanence");
local aug_gear = require("shared/aug_gear");
local modesets = require("modesets");

--              AF/Relic/Empyrean gear status
--
--  AF       | Base | B +1 | Rf | Rf +1 | Rf +2 | Rf +3 |
--   head    |      |      |    |       |   X   |       |
--   body    |      |      |    |       |   X   |       |
--   hands   |      |      |    |       |   X   |       |
--   legs    |      |      |    |       |   X   |       |
--   feet    |      |      |    |       |   X   |       |
--
--  Relic    | Base | Base +1 | Base +2 | RF | Rf +1 |
--   head    |      |         |         |  X |       |
--   body    |      |         |         |  X |       |
--   hands   |   X  |         |         |    |       |
--   legs    |      |         |         |    |       |
--   feet    |      |         |         |  X |       |
--
--  Empyrean | Base | Base +1 | Base +2 | RF | Rf +1 |
--   head    |      |         |         |  X |       |
--   body    |      |         |         |  X |       |
--   hands   |      |         |         |  X |       |
--   legs    |      |         |         |  X |       |
--   feet    |      |         |         |    |   X   |
--

function get_sets()
    setup_spellcost_map(player);

    sets.standard = {
        -- pdt -20%
        main="Terra's staff",

        -- dt -2
        sub="Alber Strap",

        -- mdam +10, INT 2-6
        ammo="Ghastly Tathlum",

        -- Sublimation +3, haste +6%, matk +15, macc +42, int 32, mnd 32
        head="Acad. Mortar. +2",

        -- macc 40, 22 dark arts skills, refresh +3
        body="Acad. Gown +3",

        -- Haste +3%, Fast Cast +7%, int 24, mnd 38
        hands="Acad. Bracers +2",

        -- haste +5%, int 39, mnd 34
        -- Light Arts +22
        legs="Acad. Pants +2",

        -- Casting time -10%, haste +3%, Enmity -7, int 27, mnd 24
        feet="Acad. Loafers +2",

        -- macc 5, matk 11
        neck="Eddy Necklace",

        -- macc +4, matk +10
        waist="Refoccilation Stone",

        -- Refresh +1, matk +4
        left_ear={ name="Moonshade Earring", augments={
            '"Mag.Atk.Bns."+4','Latent effect: "Refresh"+1',}
        },

        -- matk + 10
        right_ear="Friomisi Earring",

        -- dam.taken -10
        left_ring="Defending Ring",

        -- dam.taken -7
        right_ring="Vocane Ring",

        -- matk +10, mdam +10, elem.skill +8, dark.skill +8, int +1, mnd +2,
        -- helix.duration +19
        back="Bookworm's Cape",
    };

    sets.standard_idle = set_combine(sets.standard, {});
    sets.sublimation_idle = set_combine(
        sets.idle,
        {
            -- Sublimation +1
            main = "Siriti",

            -- Sublimation +3
            head="Acad. Mortar. +2",

            -- defense / shield blocks
            sub = "Genmei Shield",

            -- Sublimation +2
            body = "Pedagogy Gown",

            -- Sublimation +1
            left_ear = "Savant's Earring",
        }
    );
    sets.idle = sets.standard_idle

    sets.resting = set_combine(
        sets.standard,
        {
            -- rmp +10
            main = "Chatoyant Staff",

            -- rmp +2
            ammo = "Clarus Stone",

            -- rmp +5
            body = "Errant Hpl.",

            -- rmp +4
            neck = "Eidolon Pendant",

            -- rmp +4
            waist = "Austerity Belt",

            -- rmp +4
            legs = "Nisse Slacks",

            -- rmp +3
            back = "Felicitas Cape",
        }
    );

    sets.nuking = set_combine(
        sets.standard,
        {
            -- matk +47, macc +52 (aug)
            head=aug_gear.nuke.head,

            -- matk 4, macc 8, int 4
            ammo="Pemphredo Tathlum",

            -- macc 50, 24 dark arts skill, set acc bonus, refresh +3
            body="Acad. Gown +3",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- matk +8, macc 8
            left_ear="Barkaro. Earring",

            -- matk + 10
            right_ear="Friomisi Earring",

            -- int +43, macc 52, matk +53, haste +5%
            legs=aug_gear.nuke.legs,

            -- macc 6, matk 3, mb bonus 2
            left_ring="Jhakri Ring",

            -- macc +2, matk +4
            right_ring="Shiva ring +1",

            -- macc 36, matk 36
            feet="Jhakri Pigaches +1",

            -- matk 10, macc 10
            neck="Sanctity Necklace",

            -- macc 20, matk 10, mdam 20, int+20
            back="Lugh's Cape",
        }
    );

    sets.skillchain = set_combine(
        sets.nuking,
        {
            -- Immanence: +10% damage
            hands="Arbatel Bracers",

            -- TODO: skillchain bonus +8
            -- legs="Amalric Slops",

            -- skillchain bonus +5
            right_ring="Mujin Band",

            -- skillchain bonus +10
            back="Lugh's Cape",
        }
    );

    sets.magicburst = set_combine(
        sets.nuking,
        {
            -- TODO: relic head +3

            -- SCH staff is mbdam 10

            -- MB II+2, macc 27, matk 42, mb acc +10
            head={
                name="Peda. M.Board +2",
                augments={'Enh. "Altruism" and "Focalization"',}
            },

            -- matk 8, mb bonus 10%
            neck="Mizu. Kubikazari",

            -- macc 50, 24 dark arts skill, set acc bonus, refresh +3, mb +10
            body="Acad. Gown +3",

            -- MB II+5, macc 15, matk 38, elem. magic skill +13
            hands=aug_gear.burst.hands,

            -- MB+10, macc 43, matk 37, mdam +13
            legs=aug_gear.burst.legs,

            -- skillchain bonus, mb II 5%
            right_ring="Mujin Band",

            -- Cap is 40 for MB I, unknown for MB II
            -- 40% MB I, 12 MB II
        }
    );

    sets.nuking_darkmagic_extra = {
        head="Pixie Hairpin +1",
    }

    -- This set is meant to be combined with either nuking or magicburst
    sets.helix_overrides = {
        -- mdam +10
        ammo="Ghastly Tathlum",
        -- mdam +58
        body="Mallquis Saio",
        -- mdam +5
        left_ring="Mephitas's Ring +1",
    }

    sets.fastcast = {
        -- Possible upgrades:
        --  * Hvergelmir i119 III staff, +50, (+47)
        --  * Augmented merlinic hood, 15 fast cast (+1)
        --  * Augmented merlinic feet, 12 fc (+2)
        --  * Grioavolr staff, up to +11 fastcast (+2), Bashmu reisen NM
        --  * Pinga tunic, fc 13 (+5), 9 mill
        --  * Pinga Pants, fc 11 (+7), 8 mill
        --  * Enchntr. Earring +1, fc 2 (+2), 5 mill

        -- Weapon and sub: 11%

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
        -- Fast cast +8
        body="Shango Robe",
        -- Fast cast +4
        neck = "Voltsurge Torque",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- Fast Cast +7%
        hands="Acad. Bracers +2",
        -- Fast cast +2
        ammo = "Incantor Stone",
        -- Fast cast +4
        back = "Swith Cape +1",
        -- Fast cast +4
        legs="Gyve Trousers",
        -- Fast cast +10
        -- Note: Replaced with Acad. Loafers +2 under grimoire
        feet={
            name="Merlinic Crackows",
            augments={
                '"Fast Cast"+5',
                '"Mag.Atk.Bns."+4',
            }
        },
        -- Fast cast +2
        right_ear="Loquac. Earring",
        -- Fast cast +4
        left_ring="Kishar Ring",
        -- Fast cast +2
        right_ring="Prolix Ring",
        -- Elem. magic cast time -3%, auto-included when casting elemental
        -- magic
        -- left_ear="Barkaro. Earring",


        -- Total: 74%
        -- Total under grimoire: (total - 24) = 50%

        -- cap with non-fast-cast sub: 80
        -- cap with RDM sub: 65
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.drain_and_aspir = set_combine(sets.darkmagic, {
        head="Pixie Hairpin +1",
        -- Macc 17, dark magic skill 10, drain/aspir +5
        neck="Erra Pendant",
        waist = "Fucho-no-Obi"
    })

    sets.enfeebling_magic = set_combine(
        -- Set bonus from Academic gear: 45 macc from 3 pieces
        sets.nuking, {
            -- macc 8
            ammo="Pemphredo Tathlum",
            -- macc 42, set bonus
            head="Acad. Mortar. +2",
            -- macc 50, set bonus
            body="Acad. Gown +3",
            -- macc 38, set bonus
            hands="Acad. Bracers +2",
            -- macc 57
            legs=aug_gear.acc.legs,
            -- macc 36, set bonus
            feet = "Acad. Loafers +2";
            -- macc 10
            neck="Sanctity Necklace",
            -- macc 7
            waist="Eschan Stone",
            -- macc 8
            left_ear="Barkaro. Earring",
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

    sets.enfeeble_dark = set_combine(sets.enfeebling_magic, {});

    sets.enfeeble_light = set_combine(sets.enfeebling_magic, {});

    sets.healing = set_combine(
        sets.standard,
        {
            -- Cure pot +5
            neck="Nodens Gorget",

            -- MND +18, healing.skill +12
            body = "Pedagogy Gown",

            -- cure.pot +14%, MND +33
            hands="Telchine Gloves",

            -- Cure.pot +10
            legs="Gyve Trousers",

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

    sets.enhancing = set_combine(
        sets.standard,
        {
            -- Regen +10
            main="Bolelabunga",
            -- enh. duration +10
            sub="Ammurapi Shield",
            -- enh duration +8

            -- enhancing duration +9
            head={ name="Telchine Cap", augments={'Enh. Mag. eff. dur. +9',}},
            -- enhancing duration +9
            body={ name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +9',}},
            -- enhancing duration +10
            hands={ name="Telchine Gloves",
                   augments={'"Cure" potency +4%','Enh. Mag. eff. dur. +10',}},
            -- enhancing duration +10
            legs={ name="Telchine Braconi",
                  augments={'Enh. Mag. eff. dur. +10',}},
            -- enhancing duration +9
            feet={ name="Telchine Pigaches",
                  augments={'Enh. Mag. eff. dur. +9',}},

            -- MND +5, INT +5
            waist = "Penitent's Rope",

            -- MND +8
            back="Pahtli Cape",

            -- Enh.magic +7
            left_ear="Andoaa Earring",

            -- MND +5
            left_ring="Solemn Ring",
        }
    );

    sets.regen = set_combine(
        sets.enhancing,
        {
            -- Regen +10
            main="Bolelabunga",
            -- Defence
            sub="Genmei Shield",
            -- Enh.magic +12, regen +10
            head="Arbatel Bonnet",
            -- Regen +9
            back="Bookworm's Cape",
        }
    );

    sets.stoneskin = set_combine(
        sets.enhancing,
        {
            -- Stonesking +30
            neck="Nodens Gorget",
        }
    );

    MidcastGear = {};
    AfterCastGear = {};
    Grimoire = nil;

    nuke_mode = modesets.make_set('Nukemode', {'nuking', 'magicburst'});
    send_command('bind ^f9 gs c mode Nukemode cycle')

    auto_sc = AutoImmanence({
        gear_fastcast=54,
        uses_academics_loafers=true,
        uses_pedagogy_mortarboard=true,
    })

    -- Tell day and weather we have the combined obi
    set_has_hachirin_no_obi(true);
    -- And tell it we will be using tier II storm buffs
    set_stormbuff_level(2)
end


function self_command(command)
    if auto_sc.self_command(command) then
        return
    elseif modesets.self_command(command) then
        return
    elseif command == "test" then
        print(DataDumper(windower.ffxi.get_ability_recasts()))
    end
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
    if check_addendum(spell) then
        return;
    end
end

function setup_idle_set()
    if buffactive["Sublimation: Activated"] then
        sets.idle = sets.sublimation_idle;
    else
        sets.idle = sets.standard_idle;
    end
end

function pretarget(spell)
    setup_idle_set()

    MidcastGear = {};
    AfterCastGear = {};
    Grimoire = nil;
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    if downgrade_spell(player, spell) then
        return;
    end

    auto_sc.precast(spell)

    if '/jobability' == spell.prefix then
        -- Change idle set dependant on sublimation status
        if "Sublimation" == spell.english then
            if buffactive["Sublimation: Activated"] or
               buffactive["Sublimation: Complete"] then
               sets.idle = sets.standard_idle;
            else
                sets.idle = sets.sublimation_idle;
            end
        elseif "Enlightenment" == spell.english then
            equip({body = "Pedagogy Gown"});
        elseif "Tabula Rasa" == spell.english then
            -- TODO: Need to get these
            -- equip({body = "Argute Pants +2"});
            -- equip({body = "Pedagody Pants +2"});
        end
    elseif '/magic' == spell.prefix then
        local precast_extra = {}

        if "Healing Magic" == spell.skill then
            local extraGear = get_day_and_weather_gear(spell) or {}

            MidcastGear = set_combine(
                sets.healing,
                miaw_staves.healing,
                extraGear
            );

            -- Use Arbatel Bonnet during rapture
            if buffactive["Rapture"] then
                precast_extra.head = "Arbatel Bonnet";
            end

            -- Use Pahtli cape for cure casting time
            precast_extra.back = "Pahtli Cape"
        elseif "Enhancing Magic" == spell.skill then
            if string.startswith(spell.english, "Regen") then
                MidcastGear = set_combine(sets.regen, {});
            elseif "Stoneskin" == spell.name then
                MidcastGear = set_combine(sets.stoneskin, {});
            else
                MidcastGear = set_combine(sets.enhancing, {});
            end
        elseif "Elemental Magic" == spell.skill then
            local baseGear = sets[nuke_mode.value]
            local extraGear = get_day_and_weather_gear(spell) or {}

            -- Elem. magic casting time -3
            precast_extra.left_ear = "Barkaro. Earring"

            if buffactive["Immanence"] then
                baseGear = sets.skillchain
            elseif auto_sc.in_mb_window(spell) then
                baseGear = sets.magicburst
            end
            -- +20% extra damage from Ebullience
            if buffactive["Ebullience"] then
                extraGear.head = "Arbatel Bonnet";
            end
            -- Straight 10% damage buff if we have klimaform active during
            -- correct weather.
            if (buffactive["Klimaform"] and
                weather_is_active(spell.element)) then
                extraGear.feet = "Arbatel Loafers +1"
            end

            if spell.english:find("helix") then
                extraGear = set_combine(extraGear, sets.helix_overrides)
            end

            if(spell.element == "Dark") then
                extraGear = set_combine(extraGear, sets.nuking_darkmagic_extra)
            end

            MidcastGear = set_combine(
                baseGear,
                extraGear,
                miaw_staves.nuking[spell.element]
            );
        elseif "Enfeebling Magic" == spell.skill then
            local extraGear = get_day_and_weather_gear(spell) or {}

            -- Replace dia 2 with bio 2 when subbing BLM (for pulling)
            if "Dia II" == spell.english and "BLM" == player.sub_job then
                send_command('input /ma "Bio II" <t>');
                cancel_spell();
                return;
            end
            if buffactive["Ebullience"] then
                extraGear.head = "Arbatel Bonnet";
            end

            -- This should give more acc, even on light arts, as it gives
            -- enf +10 and macc +21.
            if grimoire_is_active(spell) then
                extraGear.legs = "Arbatel Pants"
            end

            if "BlackMagic" == spell.type then
                -- +22 enf. skill from Dark Arts
                if grimoire_is_active(spell) then
                   extraGear.body = "Acad. Gown +3";
                end

                MidcastGear = set_combine(
                    sets.enfeeble_dark,
                    extraGear,
                    miaw_staves.accuracy[spell.element]
                );
            else
                -- +22 enf. skill from Light Arts
                if grimoire_is_active(spell) then
                   extraGear.body = "Acad. Pants +2";
                end
                MidcastGear = set_combine(
                    sets.enfeeble_light,
                    extraGear,
                    miaw_staves.accuracy[spell.element]
                );
            end
        elseif "Dark Magic" == spell.skill then
            local equipSet = sets.darkmagic
            local extraGear = {}
            if spell.english == 'Drain' or spell.english == 'Aspir' then
                equipSet = sets.drain_and_aspir
            else
                local obi = get_obi(spell);
                if obi ~= nil then
                    extraGear['waist'] = obi
                end
            end
            MidcastGear = set_combine(
                sets.darkmagic,
                extraGear,
                miaw_staves.nuking[spell.element]
            );
            if "Stun" == spell.english then
                MidcastGear = set_combine(
                    sets.fastcast,
                    miaw_staves.accuracy[spell.element]
                );
            end
        end

        if grimoire_is_active(spell) then
            -- Certain job abilites does not stack with grimoire fastcast gear
            if not jobabilities_cancels_grimoire_fastcast() then
                -- Grimoire cast time -10
                precast_extra.feet = "Acad. Loafers +2";
                -- Grimoire cast time -12
                precast_extra.head = "Peda. M.Board +2"
            end
        end

        if (buffactive["Celerity"] or buffactive["Alacrity"]) then
            local stormBuff = element_to_storm_buff[spell.element] or "";

            if spell.element == world.weather_element or
               (stormBuff and buffactive[stormBuff]) then
                precast_extra.feet = "Peda. Loafers";
                MidcastGear.feet = "Peda. Loafers";
            end
        end

        if (buffactive["Perpetuance"] or buffactive["Immanence"]) then
            MidcastGear.hands = "Arbatel Bracers";
        end

        if (buffactive["Penury"] or buffactive["Parsimony"]) then
            MidcastGear.legs = "Arbatel Pants";
        end

        if (buffactive["Altruism"] or buffactive["Focalization"]) then
            MidcastGear.head = "Peda. M.Board +2";
        end

        equip(set_combine(
            sets.fastcast,
            precast_extra,
            miaw_staves.fastcast[spell.element]
        ));

        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end
end

function midcast(spell)
    cancel_buffs(spell);
    auto_sc.midcast(spell)
    equip(MidcastGear);
    MidcastGear = {};
end

function aftercast(spell)
    auto_sc.aftercast(spell)
    equip(set_combine(sets.idle, AfterCastGear));
    AfterCastGear = {};
end

function status_change(new,old)
    if "Idle" == new then
        setup_idle_set()
        equip(sets.idle);
    elseif "Engaged" == new then
    elseif "Resting" == new then
        equip(sets.resting);
    end
end

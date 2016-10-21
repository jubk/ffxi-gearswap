include("remove_silence");
include("cancel_buffs");
include("day_and_weather");
include("spelltools");
include("shared/staves");
-- include("dumper");

local AutoImmanence = require("AutoImmanence");

function get_sets()
    setup_spellcost_map(player);

    sets.standard = {
        -- pdt -20%
        main="Terra's staff",

        -- dt -1
        sub="Umbra Strap",

        -- mdam +10, INT 2-6
        ammo="Ghastly Tathlum",

        -- Sublimation +2, haste +6%, matk +10, macc +10, int 27, mnd 27
        head="Acad. Mortar. +1",

        -- macc 40, matk 40, refresh +3
        body="Jhakri Robe +1",

        -- Haste +3%, Fast Cast +5%, int 19, mnd 33
        hands="Acad. Bracers +1",

        -- haste +5%, int 34, mnd 29
        -- Light Arts +20
        legs="Acad. Pants +1",

        -- Casting time -8%, haste +3%, Enmity -6, int 22, mnd 19
        feet="Acad. Loafers +1",

        -- macc +2, matk +8, elem.cast.time -3%
        neck="Stoicheion Medal",

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

            -- Sublimation +2
            head="Acad. Mortar. +1",

            -- defense / shield blocks
            sub = "Sors Shield",

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
            head={
                name="Merlinic Hood",
                augments={
                    'Mag. Acc.+22 "Mag.Atk.Bns."+22',
                    'Damage taken-2%',
                    'CHR+1',
                    'Mag. Acc.+15',
                    '"Mag.Atk.Bns."+15',
                }
            },

            -- matk 4, macc 8, int 4
            ammo="Pemphredo Tathlum",

            -- macc 40, matk 40, refresh +3
            body="Jhakri Robe +1",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- matk +6, mcrit +3
            left_ear="Hecate's Earring",

            -- matk + 10
            right_ear="Friomisi Earring",

            -- int +43, macc 52, matk +53, haste +5%
            legs={
                name="Merlinic Shalwar",
                augments={
                    'Mag. Acc.+23 "Mag.Atk.Bns."+23',
                    '"Conserve MP"+3',
                    'Mag. Acc.+14',
                    '"Mag.Atk.Bns."+15',
                }
            },

            -- macc +2, matk +4
            left_ring="Strendu Ring",

            -- macc +3, matk +3
            right_ring="Arvina Ringlet +1",

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
            -- SCH staff is mbdam 10

            -- matk 13, macc 13, mb 13%
            head={
                name="Merlinic Hood",
                augments={
                    'Pet: DEX+8',
                    'Pet: Mag. Acc.+24',
                    'Magic burst mdg.+13%',
                    'Mag. Acc.+13 "Mag.Atk.Bns."+13',
                }
            },

            -- matk 8, mb bonus 10%
            neck="Mizu. Kubikazari",

            -- mb 10%, matk 23, macc 9
            hands="Merlinic Dastanas",

            -- macc 27, mb 8%
            legs={
                name="Merlinic Shalwar",
                augments={
                    'Mag. Acc.+27',
                    'Magic burst mdg.+8%',
                    'VIT+7',
                    '"Mag.Atk.Bns."+2',
                }
            },

            -- skillchain bonus, mb II 5%
            right_ring="Mujin Band",
        }
    );

    sets.fastcast = {
        -- Fast cast +8
        head = "Merlinic Hood",
        -- Fast cast +5
        body = "Helios Jacket",
        -- Fast cast +4
        neck = "Voltsurge Torque",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- Fast cast +7
        hands="Gende. Gages +1",
        -- Fast cast +2
        ammo = "Incantor Stone",
        -- Fast cast +3
        back = "Swith Cape",
        -- Fast cast +5
        legs="Artsieq Hose",
        -- Fast cast +5
        -- Note: Uses Acad. Loafers +1 with grimoire for cast time -8%
        feet = "Peda. Loafers",
        -- Fast cast +2
        right_ear="Loquac. Earring",
        -- Fast cast +2
        left_ring="Prolix Ring",
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.enfeeble_dark = set_combine(
        sets.nuking,
        {
            -- macc +15
            -- Note: Using Acad body +1 for +20 skill during dark arts
            body = "Arbatel Gown",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- int +7, macc +5
            waist = "Porous Robe",

            -- macc +3
            left_ring="Arvina Ringlet +1",

            -- macc +7
            right_ring = "Etana Ring",

            -- macc +7
            feet="Helios Boots"
        }
    );

    sets.enfeeble_light = set_combine(
        sets.nuking,
        {
            -- matk +7, macc +25 (aug)
            head = "Helios Band",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- TODO: Tengu-no-Obi
            -- mnd +7, macc +5
            waist = "Porous Robe",

            -- macc +3
            left_ring="Arvina Ringlet +1",

            -- macc +7
            right_ring = "Etana Ring",
        }
    );

    sets.healing = set_combine(
        sets.standard,
        {
            -- Cure pot +5
            neck="Nodens Gorget",

            -- MND +18, healing.skill +12
            body = "Pedagogy Gown",

            -- cure.pot +10%, MND +33
            hands="Telchine Gloves",

            -- Cure.pot +10
            legs="Gyve Trousers",

            -- Healing magic skill +14, mnd+12
            feet = "Peda. Loafers",

            -- MND +8
            back = "Pahtli Cape",

            -- mnd +7
            waist = "Porous Robe",

            -- MND +5
            left_ring="Solemn Ring",

            -- MND +3
            right_ring={ name="Diamond Ring", augments={'MND+3',}},
        }
    );

    sets.enhancing = set_combine(
        sets.standard,
        {
            -- Enh.magic +12, regen +10
            head="Arbatel Bonnet",

            -- Enh.magic +12, regen dur +12, haste +3
            body = "Telchine Chas.",

            -- MND +33, converserve mp 4%
            hands="Acad. Bracers +1",

            -- MND +5, INT +5
            waist = "Penitent's Rope",

            -- MND +8
            back="Pahtli Cape",

            -- Enh.magic +10
            feet = "Regal Pumps",

            -- MND +5
            left_ring="Solemn Ring",
        }
    );

    sets.regen = set_combine(
        sets.enhancing,
        {
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

    auto_sc = AutoImmanence({
        gear_fastcast=37,
        uses_academics_loafers=true,
        uses_pedagogy_mortarboard=true,
    })

    set_has_hachirin_no_obi(true);
end


function self_command(command)
    if auto_sc.self_command(command) then
        return
    elseif command == "echo" then
        send_command('input /party ' .. "\253\2\2\30K\253")
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
            local baseGear = sets.nuking
            local extraGear = get_day_and_weather_gear(spell) or {}

            if buffactive["Immanence"] then
                baseGear = sets.skillchain
            elseif auto_sc.in_mb_window(spell) then
                baseGear = sets.magicburst
            end
            -- +20% extra damage from Ebullience
            if buffactive["Ebullience"] then
                extraGear.head = "Arbatel Bonnet";
            end
            -- Straight 10% damage buff if we have klimaform active
            if buffactive["Klimaform"] then
                extraGear.feet = "Arbatel Loafers +1"
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
                -- +20 enf. skill from Dark Arts
                if grimoire_is_active(spell) then
                   extraGear.body = "Acad. Gown +1";
                end

                MidcastGear = set_combine(
                    sets.enfeeble_dark,
                    extraGear,
                    miaw_staves.accuracy[spell.element]
                );
            else
                MidcastGear = set_combine(
                    sets.enfeeble_light,
                    extraGear,
                    miaw_staves.accuracy[spell.element]
                );
            end
        elseif "Dark Magic" == spell.skill then
            local extraGear = {}
            local obi = get_obi(spell);
            if obi ~= nil then
                extraGear['waist'] = obi
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
                -- Grimoire cast time -8
                precast_extra.feet = "Acad. Loafers +1";
                -- Grimoire cast time -10
                precast_extra.head = "Peda. M.Board"
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
            MidcastGear.head = "Peda. M.Board";
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

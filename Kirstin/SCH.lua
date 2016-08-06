include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("spelltools");
include("shared/staves");

local AutoImmanence = require("AutoImmanence");

function get_sets()
    setup_spellcost_map(player);

    sets.standard = {
        main="Earth staff",
        ammo="Incantor Stone",
        head={
            name="Helios Band",
            augments={
                '"Mag.Atk.Bns."+1',
                '"Drain" and "Aspir" potency +2',
            }
        },
        body="Vrikodara Jupon",
        hands="Psycloth Manillas",
        legs="Assiduity Pants",
        feet="Manabyss Pigaches",
        neck="Eidolon Pendant",
        waist="Austerity Belt",
        left_ear="Antivenom Earring",
        right_ear="Loquac. Earring",
        left_ring="Tamas Ring",
        right_ring="Janniston Ring",
        back="Bookworm's Cape",
    };

    sets.standard_idle = set_combine(sets.standard, {});
    sets.sublimation_idle = set_combine(
        sets.idle,
        {
        }
    );
    sets.idle = sets.standard_idle

    sets.resting = set_combine(
        sets.standard,
        {
            neck = "Eidolon Pendant",
            waist = "Austerity Belt",
            back = "Felicitas Cape",
        }
    );

    sets.nuking = set_combine(
        sets.standard,
        {
            ammo="Incantor Stone",
            -- matk +50 (aug), macc +40 (aug)
            head={
                name="Merlinic Hood",
                augments={
                    'Mag. Acc.+25 "Mag.Atk.Bns."+25',
                    'Magic Damage +2',
                    'AGI+9',
                    '"Mag.Atk.Bns."+15',
                }
            },
            -- macc 28, matk 28
            body="Jhakri Robe",
            -- macc 48 (aug), matk 50 (aug)
            hands="Chironic Gloves",
            -- macc 40 (aug), matk 13 (aug), mdam 13
            legs="Merlinic Shalwar",
            -- macc 36, matk 36
            feet="Jhakri Pigaches +1",
            -- macc 10, matk 10
            neck="Sanctity Necklace",
            -- macc 4, matk 10
            waist="Refoccilation Stone",
            -- matk 6
            left_ear="Hecate's Earring",
            -- matk 10
            right_ear="Friomisi Earring",
            -- macc 4
            left_ring="Balrahn's Ring",
            -- enmity -3
            right_ring="Tamas Ring",
            -- matk 10, mdam 10, elem skill +8
            back="Bookworm's Cape",
        }
    );

    sets.skillchain = set_combine(
        sets.nuking,
        {
            -- skillchain bonus
            right_ring="Mujin Band",
        }
    );

    sets.magicburst = set_combine(
        sets.nuking,
        {
            -- matk 8, mb bonus 10
            neck="Mizu. Kubikazari",

            head={
                name="Merlinic Hood",
                augments={
                    'Mag. Acc.+18 "Mag.Atk.Bns."+18',
                    'Magic burst mdg.+9%',
                    '"Mag.Atk.Bns."+5',
                }
            },
            hands={
                name="Merlinic Dastanas",
                augments={
                    '"Mag.Atk.Bns."+19',
                    'Magic burst mdg.+10%',
                    'MND+10',
                }
            },
            legs={
                name="Merlinic Shalwar",
                augments={
                    'Mag. Acc.+20',
                    'Magic burst mdg.+10%',
                    '"Mag.Atk.Bns."+13',
                }
            },
            -- skillchain bonus
            right_ring="Mujin Band",
        }
    );

    sets.fastcast = {
        -- Fast cast +8
        head = "Merlinic Hood",
        -- fastcast +2
        ammo="Incantor Stone",
        -- fastcast +5
        body="Vrikodara Jupon",
        -- fastcast 4
        legs="Gyve Trousers",
        -- fastcast 4-6
        feet="Regal Pumps",
        -- fastcast +2
        waist="Channeler's Stone",
        -- fastcast +2
        right_ear="Loquac. Earring",
        -- fastcast +2
        left_ring="Prolix Ring",
        -- fastcast +3
        back="Swith Cape",
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.enfeeble_dark = set_combine(
        sets.standard,
        {
            waist = "Cognition Belt",
        }
    );

    sets.enfeeble_light = set_combine(
        sets.standard,
        {
            hands = "Otomi Gloves",
            waist = "Penitent's Rope",
            left_ring = "Solemn Ring",
        }
    );

    -- TODO: non-WHM healing staff
    sets.healing = set_combine(
        sets.standard,
        {
            hands = "Otomi Gloves",
            waist = "Penitent's Rope",
            back = "Swith Cape",
            left_ring="Solemn Ring",
        }
    );

    sets.enhancing = set_combine(
        sets.standard,
        {
            body="Telchine Chas.",
            waist = "Penitent's Rope",
            back = "Swith Cape",
            feet = "Regal Pumps",
            left_ring="Solemn Ring",
        }
    );

    sets.stoneskin = set_combine(
        sets.enhancing,
        {}
    );

    MidcastGear = {}
    AfterCastGear = {};

    auto_sc = AutoImmanence()
end

function self_command(command)
    auto_sc.self_command(command)
end

function filtered_action(spell)
    -- Check whether we should activate arts/addendum instead of casting
    -- the spell.
    if check_addendum(spell) then
        return;
    end
end

function pretarget(spell)
    if buffactive["Sublimation: Activated"] then
        sets.idle = sets.sublimation_idle;
    else
        sets.idle = sets.standard_idle;
    end

    MidcastGear = {}
    AfterCastGear = {};
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
        end
    elseif '/magic' == spell.prefix then
        local precast_extra = {}

        if "Healing Magic" == spell.skill then
            local extraGear = {}
            local obi = get_obi(spell);
            if obi ~= nil then
                extraGear['waist'] = obi
            end

            MidcastGear = set_combine(
                sets.healing,
                kirstin_staves.nuking[spell.element],
                extraGear
            );

            -- Use Savant's Bonnet +2 during rapture
            if buffactive["Rapture"] then
                precast_extra.head = "Savant's Bonnet +2";
            end
        elseif "Enhancing Magic" == spell.skill then
            if "Stoneskin" == spell.name then
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
                extraGear.head = "Savant's Bonnet +2";
            end
            -- Straight 10% damage buff if we have klimaform active
            if buffactive["Klimaform"] then
                extraGear.feet = "Savant's Loafers +2"
            end

            MidcastGear = set_combine(
                sets.nuking,
                extraGear,
                kirstin_staves.nuking[spell.element]
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
                extraGear.head = "Savant's Bonnet +2";
            end
            if "BlackMagic" == spell.type then
                MidcastGear = set_combine(
                    sets.enfeeble_dark,
                    extraGear,
                    kirstin_staves.accuracy[spell.element]
                );
            else
                MidcastGear = set_combine(
                    sets.enfeeble_light,
                    extraGear,
                    kirstin_staves.accuracy[spell.element]
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
                kirstin_staves.nuking[spell.element]
            );
            if "Stun" == spell.english then
                MidcastGear = set_combine(
                    sets.fastcast,
                    kirstin_staves.accuracy[spell.element]
                );
            end
        end
        if (buffactive["Celerity"] or buffactive["Alacrity"]) and
            spell.element == world.weather_element then
            precast_extra.feet = "Argute Loafers";
        end


        equip(set_combine(
            sets.fastcast,
            precast_extra,
            kirstin_staves.fastcast[spell.element]
        ));

        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end
end

function midcast(spell)
    cancel_buffs(spell);

    auto_sc.midcast(spell)

    equip(MidcastGear);
end

function aftercast(spell)
    auto_sc.aftercast(spell)
    equip(set_combine(sets.idle, AfterCastGear));
end

function status_change(new,old)
    if "Idle" == new then
        equip(sets.idle);
    elseif "Engaged" == new then
    elseif "Resting" == new then
        equip(sets.resting);
    end
end

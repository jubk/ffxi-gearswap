include("remove_silence");
include("cancel_buffs");
include("day_and_weather");
include("spelltools");
-- include("dumper");

function get_sets()
    setup_spellcost_map(player);

    sets.standard = {
        -- macc 15, matk 63, int 15, refresh 1
        main={
            name="Lathi",
            augments={
                'INT+15',
                '"Mag.Atk.Bns."+15',
                'Mag. Acc.+15',
            }
        },

        -- macc 3, matk 5
        sub="Willpower Grip",

        -- macc 6, matk 4, int 4
        ammo="Pemphredo Tathlum",

        -- macc 52, matk 47
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
        -- macc 40, matk 40
        body="Jhakri Robe +1",
        -- macc 9, matk 23, mb 10
        hands={
            name="Merlinic Dastanas",
            augments={
                '"Mag.Atk.Bns."+23',
                'Magic burst mdg.+10%',
                'INT+4',
                'Mag. Acc.+9',
            }
        },
        -- macc 57, matk 53
        legs={
            name="Merlinic Shalwar",
            augments={
                'Mag. Acc.+23 "Mag.Atk.Bns."+23',
                '"Conserve MP"+3',
                'Mag. Acc.+14',
                '"Mag.Atk.Bns."+15',
            }
        },
        -- macc 36, matk 36
        feet="Jhakri Pigaches +1",
        -- macc 2, matk 8
        neck="Stoicheion Medal",
        -- macc 4, matk 10
        waist="Refoccilation Stone",
        -- matk 10
        left_ear="Friomisi Earring",
        -- Refresh +1, matk +4
        right_ear={ name="Moonshade Earring", augments={
            '"Mag.Atk.Bns."+4','Latent effect: "Refresh"+1',}
        },
        -- macc +3, matk 3
        left_ring="Arvina Ringlet +1",
        -- macc 2, matk 4
        right_ring="Strendu Ring",
        -- macc 5, matk 10
        back="Izdubar Mantle",
    };

    sets.standard_idle = set_combine(sets.standard, {});
    sets.sublimation_idle = set_combine(sets.idle, {});
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
            -- macc 6, matk 4, int 4
            ammo="Pemphredo Tathlum",

            -- macc 52, matk 47
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

            -- macc 40, matk 40, refresh +3
            body="Jhakri Robe +1",

            -- macc 9, matk 23, mb 10
            hands={
                name="Merlinic Dastanas",
                augments={
                    '"Mag.Atk.Bns."+23',
                    'Magic burst mdg.+10%',
                    'INT+4',
                    'Mag. Acc.+9',
                }
            },
            -- macc 57, matk 53
            legs={
                name="Merlinic Shalwar",
                augments={
                    'Mag. Acc.+23 "Mag.Atk.Bns."+23',
                    '"Conserve MP"+3',
                    'Mag. Acc.+14',
                    '"Mag.Atk.Bns."+15',
                }
            },
            -- macc 36, matk 36
            feet="Jhakri Pigaches +1",
            -- macc 2, matk 8
            neck="Stoicheion Medal",
            -- macc 4, matk 10
            waist="Refoccilation Stone",
            -- matk 10
            left_ear="Friomisi Earring",
            -- matk 6
            right_ear="Hecate's Earring",
            -- macc +3, matk 3
            left_ring="Arvina Ringlet +1",
            -- macc 2, matk 4
            right_ring="Strendu Ring",
            -- macc 5, matk 10
            back="Izdubar Mantle",
        }
    );

    --sets.nuking = {
    --    ammo="Pemphredo Tathlum",
    --    head={ name="Merlinic Hood", augments={'Mag. Acc.+22 "Mag.Atk.Bns."+22','Damage taken-2%','CHR+1','Mag. Acc.+15','"Mag.Atk.Bns."+15',}},
    --    body="Jhakri Robe +1",
    --    hands="Jhakri Cuffs +1",
    --    legs={ name="Merlinic Shalwar", augments={'Mag. Acc.+23 "Mag.Atk.Bns."+23','"Conserve MP"+3','Mag. Acc.+14','"Mag.Atk.Bns."+15',}},
    --    feet="Jhakri Pigaches +1",
    --    neck="Sanctity Necklace",
    --    waist="Refoccilation Stone",
    --    left_ear="Friomisi Earring",
    --    right_ear="Digni. Earring",
    --    left_ring="Arvina Ringlet +1",
    --    right_ring="Strendu Ring",
    --    back="Izdubar Mantle",
    --}

    sets.skillchain = set_combine(
        sets.nuking,
        {
            -- skillchain bonus +5
            right_ring="Mujin Band",
        }
    );

    sets.magicburst = set_combine(
        sets.nuking,
        {
            -- matk 13, macc 13, mb 13
            head={
                name="Merlinic Hood",
                augments={
                    'Pet: DEX+8',
                    'Pet: Mag. Acc.+24',
                    'Magic burst mdg.+13%',
                    'Mag. Acc.+13 "Mag.Atk.Bns."+13',
                }
            },

            -- matk 8, mb bonus 10
            neck="Mizu. Kubikazari",

            -- mb bonus augment (10%), matk 23, macc 9
            hands="Merlinic Dastanas",

            -- mb 8
            legs={
                name="Merlinic Shalwar",
                augments={
                    'Mag. Acc.+27',
                    'Magic burst mdg.+8%',
                    'VIT+7',
                    '"Mag.Atk.Bns."+2',
                }
            },

            -- mb 6, macc 28, matk 15
            feet={
                name="Merlinic Crackows",
                augments={
                    'Mag. Acc.+28',
                    'Magic burst mdg.+6%',
                    'CHR+2',
                }
            },
            -- mb bonus
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
        -- Fast cast +3
        back = "Swith Cape",
        -- Fast cast +5
        legs="Artsieq Hose",
        -- Fast cast +5
        feet="Merlinic Crackows",
        -- Fast cast +2
        right_ear="Loquac. Earring",
        -- Fast cast +2
        left_ring="Prolix Ring",
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.enfeeble_dark = set_combine(
        sets.standard,
        {
            -- matk +7, macc +25 (aug)
            head = "Helios Band",

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
        sets.standard,
        {
            -- matk +7, macc +25 (aug)
            head = "Helios Band",

            -- macc +15
            body = "Arbatel Gown",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- TODO: Tengu-no-Obi
            -- mnd +7, macc +5
            waist = "Porous Robe",

            -- macc +3
            left_ring="Arvina Ringlet +1",

            -- macc +7
            right_ring = "Etana Ring",

            -- matk +7, macc +7
            feet="Helios Boots"
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
            -- Enh.magic +12, regen dur +12, haste +3
            body = "Telchine Chas.",

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

    sets.regen = set_combine(sets.enhancing, {});

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

    set_has_hachirin_no_obi(true);
end


function self_command(command)
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
            local extraGear = get_day_and_weather_gear(spell) or {}

            MidcastGear = set_combine(
                sets.healing,
                extraGear
            );

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
            baseGear = sets.magicburst
            local extraGear = get_day_and_weather_gear(spell) or {}

            MidcastGear = set_combine(
                baseGear,
                extraGear
            );
        elseif "Enfeebling Magic" == spell.skill then
            local extraGear = get_day_and_weather_gear(spell) or {}


            if "BlackMagic" == spell.type then
                MidcastGear = set_combine(
                    sets.enfeeble_dark,
                    extraGear
                );
            else
                MidcastGear = set_combine(
                    sets.enfeeble_light,
                    extraGear
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
                extraGear
            );
        end

        equip(set_combine(
            sets.fastcast,
            precast_extra
        ));

        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end
end

function midcast(spell)
    cancel_buffs(spell);
    equip(MidcastGear);
    MidcastGear = {};
end

function aftercast(spell)
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

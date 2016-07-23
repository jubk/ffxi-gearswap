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
            head="Merlinic Hood",
            body="Vanya Robe",
            hands="Chironic Gloves",
            legs="Merlinic Shalwar",
            feet="Medium's Sabots",
            neck="Sanctity Necklace",
            waist="Refoccilation Stone",
            left_ear="Hecate's Earring",
            right_ear="Loquac. Earring",
            left_ring="Tamas Ring",
            right_ring="Janniston Ring",
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
            -- skillchain bonus
            right_ring="Mujin Band",
        }
    );

    sets.fastcast = {
        ammo="Incantor Stone",
        head={ name="Selenian Cap", augments={'MND+4','"Cure" potency +3%','MND+2','"Fast Cast"+2',}},
        body="Vrikodara Jupon",
        hands={ name="Psycloth Manillas", augments={'Mag. Acc.+7','Spell interruption rate down +8%','MND+4',}},
        legs="Gyve Trousers",
        feet="Regal Pumps",
        neck="Sanctity Necklace",
        waist="Channeler's Stone",
        left_ear="Antivenom Earring",
        right_ear="Loquac. Earring",
        left_ring="Tamas Ring",
        right_ring="Janniston Ring",
        back={ name="Bookworm's Cape", augments={'INT+1','MND+3','Helix eff. dur. +20','"Regen" potency+8',}},
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
            local extraGear = {}
            local obi = get_obi(spell);
            if obi ~= nil then
                extraGear['waist'] = obi
            end
            if buffactive["Ebullience"] then
                precast_extra.head = "Savant's Bonnet +2";
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
            local extraGear = {}
            local obi = get_obi(spell);
            if obi ~= nil then
                extraGear['waist'] = obi
            end

            -- Replace dia 2 with bio 2 when subbing BLM (for pulling)
            if "Dia II" == spell.english and "BLM" == player.sub_job then
                send_command('input /ma "Bio II" <t>');
                cancel_spell();
                return;
            end
            if buffactive["Ebullience"] then
                precast_extra.head = "Savant's Bonnet +2";
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

include("remove_silence");
include("cancel_buffs");
include("day_and_weather");
include("spelltools");
include("shared/staves");

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

        -- Refresh +2, haste +3%, int 34, mnd 29
        -- Dark arts +20
        body="Acad. Gown +1",

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
            -- matk +28, macc +38 (aug), mdam+6
            head = "Merlinic Hood",

            -- matk + 39, macc +14, mdam +10
            body = "Witching Robe",

            -- macc +44, matk+52
            hands = "Chironic Gloves",

            -- matk +6, mcrit +3
            left_ear="Hecate's Earring",

            -- matk + 10
            right_ear="Friomisi Earring",

            -- int +28, matk +40, haste +3%
            legs="Merlinic Shalwar",

            -- macc +2, matk +4
            left_ring="Strendu Ring",

            -- macc +3, matk +3
            right_ring="Arvina Ringlet +1",

            -- TODO: Amalric nails/Vexed Nails/9mill
            -- matk +7, macc +7, (aug)matk +23
            feet="Helios Boots",

            -- matk 8, mb bonus 10
            neck="Mizu. Kubikazari",
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
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.enfeeble_dark = set_combine(
        sets.standard,
        {
            -- matk +7, macc +25 (aug)
            head = "Helios Band",

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

    immanence_program = nil;

    sc_programs = {
        frag={
            {0, '/party Fragmentation Skillchain start: Thunder and Wind', true},
            {0, '/ja Immanence <me>', false},
            {0, '/ma Blizzard <t>', false},
            {2.5, '/ja Immanence <me>', false},
            {0, '/ma Water <t>', false},
            {2, '/party Fragmentation Skillchain GO: Thunder and Wind', false},
        },
        fusion={
            {0, '/party Fusion Skillchain start: Fire and Light', true},
            {0, '/ja Immanence <me>', false},
            {0, '/ma Fire <t>', false},
            {2.5, '/ja Immanence <me>', false},
            {0, '/ma Thunder <t>', false},
            {2, '/party Fusion Skillchain GO: Fire and Light', false},
        },
        grav={
            {0, '/party Gravitation Skillchain start: Stone and Darkness', true},
            {0, '/ja Immanence <me>', false},
            {0, '/ma Aero <t>', false},
            {2.5, '/ja Immanence <me>', false},
            {0, '/ma Noctohelix <t>', false},
            {3, '/party Gravitation Skillchain GO: Stone and Darkness', false},
        },
        dist={
            {0, '/party Gravitation Skillchain start: Stone and Darkness', true},
            {0, '/ja Immanence <me>', false},
            {0, '/ma Aero <t>', false},
            {2.5, '/ja Immanence <me>', false},
            {0, '/ma Noctohelix <t>', false},
            {3, '/party Gravitation Skillchain GO: Stone and Darkness', false},
        },
    }


    set_has_hachirin_no_obi(true);
end

function sc_tic()
    if immanence_program then
        -- add_to_chat(128, 'SC: performing tic');

        sc_next = table.remove(immanence_program, 1)

        while sc_next do
            wait = ''
            if sc_next[1] > 0 then
                wait = "pause " .. sc_next[1] .. "; "
            end
            cmd = wait .. "input " .. sc_next[2]
            -- add_to_chat(128, 'SC sending command: ' .. cmd);
            send_command(cmd)

            -- Check auto-continue flag
            if sc_next[3] then
                sc_next = table.remove(immanence_program, 1)
            else
                sc_next = nil
            end
        end

        -- Reset program if we're done
        if not immanence_program[1] then
            immanence_program = nil
        end
    end
end

function eprint(s)
  local bytes = {}
  for i=1,#s do
    local byte = string.byte(s, i)
    if byte >= 32 and i <= 126 then
      byte = string.char(byte)
    else
      byte = '\\' .. tostring(byte)
    end
    table.insert(bytes, byte)
  end
  return(table.concat(bytes))
end

function self_command(command)

    add_to_chat(128, 'Command: ' .. command);
    args = {}
    for i in string.gmatch(command, "%S+") do
        table.insert(args, i)
    end
    cmd = table.remove(args, 1)
    if cmd == "sc" then
        prog = sc_programs[args[1]]
        if prog then
            immanence_program = {}
            for _, v in pairs(prog) do
                table.insert(immanence_program, v)
            end
            sc_tic()
        end
    elseif cmd == "echo" then
        -- print('Translation: ' .. eprint(args[1] or ""));
        send_command('input /party \253\2\2\16\20\253')
    end
end

function jobabilities_cancels_acad_feet()
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
    if check_addendum(spell.english) then
        return;
    end

    if "Drain II" == spell.english or
       "Dread Spikes" == spell.english then
        if not (
            buffactive["Manifestation"] or
            buffactive["Enlightenment"]
        ) then
            send_command('input /ja "Manifestation"');
            if buffactive["Dark Arts"] then
                add_to_chat(128, '~~~~ Auto-enabling Manifestation ~~~~');
            end
            if "Dread Spikes" == spell.english then
                send_command('input /macro set 8');
                add_to_chat(128, 'Macro set 8: Debuffs');
            end
        else
            if "Drain II" == spell.english then
                send_command('input /ma "Klimaform" <me>');
            end
        end
        cancel_spell();
        return;
    end

    -- Some shortcut spells that can be spammed to cast the equivalent
    -- spell on the whole party.
    if "Enstone II" == spell.english or
       "Phalanx II" == spell.english or
       "Shellra V" == spell.english or
       "Tactician's Roll" == spell.english
    then
        if not buffactive["Accession"] then
            if buffactive["Light Arts"] then
                add_to_chat(128, '~~~~ Auto-enabling Accession ~~~~');
            end
            send_command('input /ja "Accession"');
            if "Shellra V" == spell.english then
                send_command('input /macro set 10');
                add_to_chat(128, 'Macro set 10: Buffs');
            end
            cancel_spell();
            return;
        else
            if "Enstone II" == spell.english then
                send_command('input /ma "Stoneskin" <me>');
            elseif "Phalanx II" == spell.english then
                send_command('input /ma "Phalanx" <me>');
            elseif "Tactician's Roll" == spell.english then
                send_command('input /ma "Adloquium" <me>');
            end
            cancel_spell();
            return;
        end
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
    if "Drain II" == spell.english or
       "Dread Spikes" == spell.english or
       "Enstone II" == spell.english or
       "Phalanx II" == spell.english or
       "Shellra V" == spell.english or
       "Tactician's Roll" == spell.english then
        cancel_spell();
        return filtered_action(spell)
    end

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
        if "Enlightenment" == spell.english then
            equip({
                body = "Pedagogy Gown"
            });
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
            local extraGear = get_day_and_weather_gear(spell) or {}

            if buffactive["Ebullience"] then
                precast_extra.head = "Arbatel Bonnet";
            end
            -- Straight 10% damage buff if we have klimaform active
            if buffactive["Klimaform"] then
                extraGear.feet = "Arbatel Loafers"
            end
            MidcastGear = set_combine(
                sets.nuking,
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
                precast_extra.head = "Arbatel Bonnet";
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

        -- Use Acad loafers for -8% casting time if grimoire is actiave
        -- and we are not using one of the JAs that cancels it.
        if grimoire_is_active(spell) and
            not jobabilities_cancels_acad_feet() then
            precast_extra.feet = "Acad. Loafers +1";
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
    equip(MidcastGear);
    MidcastGear = {};
end

function aftercast(spell)
    equip(set_combine(sets.idle, AfterCastGear));
    AfterCastGear = {};
    if immanence_program then
        if spell.interrupted then
            add_to_chat(128, 'Skillchain interrupted at: ' .. spell.english);
            immanence_program = nil
        else
            -- add_to_chat(128, 'Ticking: ' .. spell.english);
            sc_tic()
        end
    end
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



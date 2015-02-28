include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("spelltools")

function get_sets()
    setup_spellcost_map(player);

    sets.standard = {
        ammo="Phtm. Tathlum",
        head="Kaabnax Hat",
        body="Savant's Gown +2",
        hands="Otomi Gloves",
        legs="Nisse Slacks",
        feet="Svnt. Loafers +2",
        neck="Jeweled Collar",
        waist="Penitent's Rope",
        left_ear="Hecate's Earring",
        right_ear="Moldavite Earring",
        left_ring="Spiral Ring",
        right_ring={
            name="Diamond Ring", augments={
                'Spell interruption rate down -4%',
                '"Resist Silence"+2',
            }
        },
    };

    sets.standard_idle = set_combine(sets.standard, {});
    sets.sublimation_idle = set_combine(
        sets.idle,
        {
            main = "Siriti",
            sub = "Avalon Shield",
            head = "Scholar's M.board",
            body = "Argute Gown",
            left_ear = "Savant's Earring",
        }
    );
    sets.idle = sets.idle_standard


    -- TODO: rmp staff
    sets.resting = set_combine(
        sets.standard,
        {
            ammo = "Clarus Stone",
            body = "Errant Hpl.",
            neck = "Eidolon Pendant",
            waist = "Austerity Belt",
            legs = "Nisse Slacks",
            back = "Felicitas Cape",
        }
    );

    sets.nuking = set_combine(
        sets.standard,
        {
            left_ear = "Hecate's Earring",
            right_ear = "Moldavite Earring",
            body = "Savant's Gown +2",
            hands = "Svnt. Bracers +2",
            waist = "Cognition Belt",
            legs = "Nisse Slacks",
            feet = "Savant's Loafers +2",
        }
    );

    sets.fastcast = {
        head = "Argute M.board",
        neck = "Jeweled Collar",
        ammo = "Incantor Stone",
        back = "Veela Cape",
        feet = "Scholar's Loafers",
    }

    sets.darkmagic = set_combine(sets.nuking, {});

    sets.enfeeble_dark = set_combine(
        sets.standard,
        {
            waist = "Cognition Belt",
            legs = "Nisse Slacks",
            feet = "Savant's Loafers +2",
        }
    );

    sets.enfeeble_light = set_combine(
        sets.standard,
        {
            head = "Argute M.board",
            body = "Savant's Gown +2",
            hands = "Svnt. Bracers +2",
            waist = "Penitent's Rope",
            left_ring = "Solemn Ring",
        }
    );

    -- TODO:             main = "$LightStaff",
    sets.healing = set_combine(
        sets.standard,
        {
            head = "Argute M.board",
            hands = "Svnt. Bracers +2",
            waist = "Penitent's Rope",
            feet = "Argute Loafers",
        }
    );

    sets.enhancing = set_combine(
        sets.standard,
        {
            head = "Savant's Bonnet +2",
            hands = "Svnt. Bracers +2",
            waist = "Penitent's Rope",
        }
    );

    -- TODO: main = "$WaterStaff",
    sets.stoneskin = set_combine(
        sets.enhancing,
        {
            left_ring = "Solemn Ring",
        }
    );

    MidcastGear = {}
    AfterCastGear = {};
end

function self_command(command)
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
       "Shellra V" == spell.english
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
            end
            cancel_spell();
            return;
        end
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
            MidcastGear = set_combine(sets.healing, {});

            -- Use Savant's Bonnet +2 during rapture
            if buffactive["Rapture"] then
                extraGear.head = "Savant's Bonnet +2";
            end
        elseif "Enhancing Magic" == spell.skill then
            if "Stoneskin" == spell.name then
                MidcastGear = set_combine(sets.stoneskin, {});
            else
                MidcastGear = set_combine(sets.enhancing, {});
            end
        elseif "Elemental Magic" == spell.skill then
            local extraGear = {};
            -- TODO: Staff changes
            -- TODO: Obi changes
            if buffactive["Ebullience"] then
                extraGear.head = "Savant's Bonnet +2";
            end
            MidcastGear = set_combine(sets.nuking, extraGear);
        elseif "Enfeebling Magic" == spell.skill then
            -- Replace dia 2 with bio 2 when subbing BLM (for pulling)
            if "Dia II" == spell.english and "BLM" == player.sub_job then
                send_command('input /ma "Bio II" <t>');
                cancel_spell();
                return;
            end
            local extraGear = {};
            if buffactive["Ebullience"] then
                extraGear.head = "Savant's Bonnet +2";
            end
            -- TODO: Staff stuff
            -- TODO: Obi stuff
            if "BlackMagic" == spell.type then
                MidcastGear = set_combine(sets.enfeeble_dark, extraGear);
            else
                MidcastGear = set_combine(sets.enfeeble_light, extraGear);
            end
        elseif "Dark Magic" == spell.skill then
            local extraGear = {};
            -- TODO: Staff stuff
            -- TODO: Obi stuff
            MidcastGear = set_combine(sets.darkmagic, extraGear);
        end
        if (buffactive["Celerity"] or buffactive["Alacrity"]) and
            spell.element == world.weather_element then
            precast_extra.feet = "Argute Loafers";
        end
        -- TODO: Staff for precast?
        equip(set_combine(sets.fastcast, precast_extra));
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');
    end
end

function midcast(spell)
    cancel_buffs(spell);
    equip(MidcastGear);
end

function aftercast(spell)
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



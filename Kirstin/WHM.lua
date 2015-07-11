include("remove_silence");
include("cancel_buffs");

-- Gear TODO:
-- orison locket [neck]
--

function time_specific_gear()
    if world.time >= 8*60 and world.time < 18*60 then
        return { feet="Serpentes Sabots" };
    else
        return { hands="Serpentes Cuffs" };
    end
end

function get_sets()
    local base = {
        main="Ababinili +1",
        sub="Achaq Grip",
        ammo="Incantor Stone",
        head="Piety Cap +1",
        body="Piety Briault +1", -- "Orison Bliaud +1",
        hands="Theophany Mitts",
        legs="Assiduity pants",
        feet="Regal Pumps",
        neck="Malison Medallion",
        waist="Austerity Belt",
        left_ear="Nourish. Earring",
        right_ear="Orison Earring",
        left_ring="Tamas Ring",
        right_ring="Sirona's Ring",
        back="Mending Cape",
    }

    sets.idle = set_combine(base, {
        right_ear="Moonshade Earring",
    });
    sets.engaged = set_combine(base, {});

    sets.fastcast = set_combine(base, {
        head="Selenian Cap",
        left_ear="Loquac. Earring",
    })
    sets.cure_fastcast = set_combine(sets.fastcast, {
        legs="Orsn. Pantaln. +1",
        left_ear="Nourish. Earring",
    });

    sets.curepotency = set_combine(base, {
        head="Orison Cap +2",
        body="Noble's Tunic",
        hands="Serpentes Cuffs",
        legs="Orsn. Pantaln. +1",
        feet="Serpentes Sabots",
        left_ear="Orison Earring",
        right_ear="Nourish. Earring",
        back="Tempered Cape",
    });

    sets.resting = set_combine(base, {
        main="Dark Staff",
        body="Errant Hpl.",
        neck="Eidolon Pendant",
        hands="Oracle's Gloves",
        legs="Orsn. Pantaln. +1",
        feet="Oracle's Pigaches",
        waist="Shinjutsu-no-Obi",
        left_ear="Antivenom Earring",
    });
end

function precast(spell)
    if spell.prefix == '/magic' then
        -- If we get interupted by removing silence, just return
        if remove_silence(spell) then
            return;
        end

        if 'Healing Magic' == spell.skill then
            equip(set_combine(sets.cure_fastcast, time_specific_gear()));
        else
            equip(set_combine(sets.fastcast, time_specific_gear()));
        end
    end
end

function midcast(spell)
    cancel_buffs(spell);
    if 'Healing Magic' == spell.skill then
        equip(set_combine(sets.curepotency, time_specific_gear()));
        if buffactive['Afflatus Solace'] then
            equip({ body = "Orison Bliaud +1" })
        end
    end
end

function aftercast(spell)
    if "Engaged" == player.status then
        equip(set_combine(sets.engaged, time_specific_gear()))
    else
        equip(set_combine(sets.idle, time_specific_gear()))
    end
end

function status_change(new,old)
    if "Idle" == new then
        equip(set_combine(sets.idle, time_specific_gear()))
    elseif "Resting" == new then
        equip(set_combine(sets.resting, time_specific_gear()))
    elseif "Engaged" == new then
        equip(set_combine(sets.engaged, time_specific_gear()))
    end
end

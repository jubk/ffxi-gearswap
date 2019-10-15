include("remove_silence");
include("cancel_buffs");
include("shared/staves");

-- Gear TODO:
-- orison locket [neck]
--

-- Gear with augments
local aug_gear = require('shared/aug_gear');

AF = {
    head="Theo. Cap +2",
    body="Theo. Briault +2",
    hands="Theophany Mitts +2",
    legs="Th. Pantaloons +3",
    feet="Theo. Duckbills +2",
}

relic = {
    head="Piety Cap +2",
    body="Piety Briault +3",
    hands="Piety Mitts +1",
    legs="Piety Pantaln. +1",
    feet="Piety Duckbills +1",
}

empy = {
    head="Ebers Cap +1",
    body="Ebers Bliaud +1",
    hands="Ebers Mitts +1",
    legs="Ebers Pant. +1",
    feet="Ebers Duckbills +1",
}

capes = {
    cure={ name="Alaunus's Cape", augments={'"Cure" potency +10%',}},
}

function get_sets()
    local base = {
        -- cure pot II +2, cure pot 10, cure spellcasting time -7
        main="Queller Rod",
        -- cure pot +3, cure spellcasting time -3
        sub="Sors Shield",

        ammo="Incantor Stone",
        head=relic.head,
        body=relic.body,
        hands=AF.hands,
        legs="Assiduity pants",
        feet="Regal Pumps",
        neck="Malison Medallion",
        waist="Shinjutsu-no-Obi +1",
        left_ear="Nourish. Earring",
        right_ear="Orison Earring",
        left_ring="Tamas Ring",
        right_ring="Janniston Ring",
        back="Mending Cape",
    };

    sets.idle = set_combine(base, {
        -- dt -2
        ammo="Staunch Tathlum",
        -- refresh +1
        head="Befouled Crown",
        -- refresh +2
        body=relic.body,
        -- refresh +1
        legs="Assiduity Pants",
        -- dt -6%
        neck="Loricate Torque +1",
        -- refresh +1
        right_ear="Moonshade Earring",
        -- pdt -5%
        left_ring="Patricius Ring",
        -- dt -5%
        right_ring="Defending Ring",
    });
    sets.engaged = set_combine(base, {});

    sets.fastcast = set_combine(base, {
        -- Enhances Fast cast
        ammo="Incantor Stone",
        -- Fast cast +2
        head="Selenian Cap",
        -- Fast cast +5%
        body="Vrikodara Jupon",
        -- Haste +3%
        hands=AF.hands,
        -- fastcast 5
        legs="Artsieq Hose",
        -- Fast cast +4-6%
        feet="Regal Pumps",
        -- Enhances fast cast
        left_ear="Loquac. Earring",
        -- Fast cast +4
        right_ring="Kishar Ring",
        -- TODO: back="Swith Cape"
    });
    sets.cure_fastcast = set_combine(
        sets.fastcast,
        {
            -- cure pot II +2, cure pot 10, cure spellcasting time -7
            main="Queller Rod",
            -- cure pot +3, cure spellcasting time -3
            sub="Sors Shield",
            -- Cure magic time -13%
            head=relic.head,
            -- Cure magic time -7%
            body="Vanya Robe",
            -- Healing magic time -8%
            legs=empy.legs,
            -- Cure magic time -3%
            left_ear="Nourish. Earring",
            -- Cure magic time -5%
            right_ear="Mendi. Earring",
            -- Cure magic time -8%
            back="Pahtli Cape",
            -- Cure casting time -15%
            feet="Vanya Clogs",
        }
    );
    sets.healing_fastcast = set_combine(sets.fastcast, {
        -- Healing magic time -8%
        legs=empy.legs,
        -- Healing magic time -5%
        back="Disperser's Cape",
    });
    sets.enhancing_fastcast = set_combine(sets.fastcast, {
        -- enhancing magic time -8%
        waist="Siegel Sash",
    });

    sets.curepotency = set_combine(
        base,
        {
            -- cure pot II +2, cure pot 10, cure spellcasting time -7
            main="Queller Rod",
            -- cure pot +3, cure spellcasting time -3
            sub="Sors Shield",
            -- ConMP +4
            ammo="Pemphredo Tathlum",
            -- cure pot 16
            head=empy.head,
            -- Cure pot +5
            neck="Nodens Gorget",
            -- cureskin+
            body=empy.body,
            -- healing magic +17
            hands=AF.hands,
            -- +x% mp return
            legs=empy.legs,
            -- cure pot 5
            feet="Vanya Clogs",
            -- cure pot 5-6
            left_ear="Nourish. Earring",
            -- cure pot 5
            right_ear="Mendi. Earring",
            -- healing magic skill 10
            left_ring="Sirona's Ring",
            -- cure pot II 5
            right_ring="Janniston Ring",
            -- cure pot 10
            back=capes.cure,

            -- TODO:
            -- Kaykaus +1 set bonus for cure pot II
        }
    );
    sets.curagapotency = set_combine(
        sets.curepotency,
        {
            -- healing magic skill +20
            body="Vanya Robe",
        }
    );

    sets.resting = set_combine(base, {
        main="Dark Staff",
        body="Errant Hpl.",
        neck="Eidolon Pendant",
        hands="Oracle's Gloves",
        legs=empy.legs,
        feet="Oracle's Pigaches",
        waist="Shinjutsu-no-Obi +1",
        left_ear="Antivenom Earring",
    });

    sets.enhancing_magic = set_combine(base, {
        -- enhancing duration +5
        main="Gada",
        -- Enh. duration +10
        sub="Ammurapi Shield",
        -- enhancing duration +10
        head=aug_gear.enh_duration.head,
        -- Enh. duration +8
        body=aug_gear.enh_duration.body,
        -- Enh. duration +9
        hands=aug_gear.enh_duration.hands,
        -- enhancing duration +10
        head=aug_gear.enh_duration.legs,
        -- Enh. duration +9
        feet=aug_gear.enh_duration.feet,
        -- Buffs stoneskin
        waist="Siegel Sash",
        -- enmity -3, MND
        left_ring="Tamas Ring",
        -- enmity -7
        right_ring="Janniston Ring",
        -- Enh. skill 8
        back="Mending Cape",
    });
    sets.stoneskin = set_combine(sets.enhancing_magic, {
        -- Stoneskin +30
        neck="Nodens Gorget",
    });
    sets.regen = set_combine(sets.enhancing_magic, {
        -- regen pot 36
        body=relic.body,
        -- inc regen duration
        hands=empy.hands,
    });
    sets.barspells = set_combine(sets.enhancing_magic, {
        -- resist spells +20
        legs=relic.legs,
    });
    sets.healing_magic = set_combine(base, {
        -- cure pot II +2, cure pot 10, cure spellcasting time -7
        main="Queller Rod",
        -- TODO: cure pot +3, cure spellcasting time -3
        -- sub="Sors Shield",
        -- Healing magic skill +15
        body=empy.body,
        -- Healing magic skill +17
        hands=AF.hands,
        -- Healing magic skill +15
        legs=relic.legs,
        -- Healing magic skill +20
        feet="Vanya Clogs",
        -- Healing magic skill +10
        left_ring="Sirona's Ring",
        -- Healing magic skill +4
        back="Tempered Cape",
    });
    sets.cursna = set_combine(sets.healing_magic, {
        -- cursna +15
        hands="Fanatic Gloves",
        -- cursna +??
        legs=AF.legs,
        -- Cursna +5
        feet="Vanya Clogs",
        -- Cursna +25
        back=capes.cure,
    });
    sets.enfeebling_magic = set_combine(sets.base, {
        -- macc +21
        body="Vanya Robe",
        -- enf. skill +15
        hands=relic.hands,
        -- statvomit
        legs="Gyve Trousers",
        -- enf. skill +15
        feet=AF.feet,
    });
    sets.divine_magic = set_combine(sets.base, {
        -- macc +21, statvomit
        body="Vanya Robe",
        -- mnd +26
        hands=AF.hands,
        -- matk +40, statvomit
        legs="Gyve Trousers",
        -- matk +6
        left_ear="Hecate's Earring",
        -- mnd +3
        left_ring="Sirona's Ring",
        -- mnd +5
        right_ring="Tamas Ring",
        -- buffs banish vs undead
        back="Disperser's Cape",
    });
end

function precast(spell)
    if '/magic' == spell.prefix  then
        -- If we get interupted by removing silence, just return
        if remove_silence(spell) then
            return;
        end

        if string.startswith(spell.english, "Cur") then
            equip(sets.cure_fastcast);
        elseif "Healing Magic" == spell.skill then
            equip(sets.healing_fastcast);
            equip(kirstin_staves.fastcast[spell.element]);
        elseif "Enhancing Magic" == spell.skill then
            equip(sets.enhancing_fastcast);
            equip(kirstin_staves.fastcast[spell.element]);
        else
            equip(sets.fastcast);
            equip(kirstin_staves.fastcast[spell.element]);
        end
    elseif '/jobability' == spell.prefix then
        if "Devotion" == spell.name then
            equip({ head = relic.head });
        elseif "Benediction" == spell.name then
            equip({ body = relic.body });
        end
    end
end

function midcast(spell)
    cancel_buffs(spell);
    if spell.prefix == '/magic' then
        if string.startswith(spell.english, "Curaga") then
            equip(sets.curagapotency);
        elseif (
            string.startswith(spell.english, "Cure") or
            string.startswith(spell.english, "Cura")
        ) then
            equip(sets.curepotency);
        elseif 'Divine Magic' == spell.skill or
               'Elemental Magic' == spell.skill or
               'Dark Magic' == spell.skill or
               'Ninjutsu' == spell.skill then
            equip(sets.divine_magic);
            equip(kirstin_staves.nuking[spell.element]);
        elseif 'Healing Magic' == spell.skill then
            if "Cursna" == spell.english then
                equip(sets.cursna);
            else
                equip(sets.healing_magic);
            end
        elseif 'Enfeebling Magic' == spell.skill then
            equip(sets.enfeebling_magic);
            equip(kirstin_staves.accuracy[spell.element]);
        elseif "Enhancing Magic" == spell.skill then
            if string.startswith(spell.english, "Regen") then
                equip(sets.regen);
            elseif string.startswith(spell.english, "Bar") then
                equip(sets.barspells);
                if buffactive['Afflatus Solace'] then
                    equip({ body=empy.body })
                end
            elseif "Stoneskin" == spell.english then
                equip(sets.stoneskin);
            else
                equip(sets.enhancing_magic);
            end
        end
    end
end

function aftercast(spell)
    if "Engaged" == player.status then
        equip(sets.engaged)
    else
        equip(sets.idle)
    end
end

function status_change(new,old)
    if "Idle" == new then
        equip(sets.idle)
    elseif "Resting" == new then
        equip(sets.resting)
    elseif "Engaged" == new then
        equip(sets.engaged)
    end
end

include("remove_silence");
include("cancel_buffs");
include("shared/staves");

function time_specific_gear()
    if world.time >= 8*60 and world.time < 18*60 then
        return { feet="Serpentes Sabots" };
    else
        return { hands="Serpentes Cuffs" };
    end
end

function get_sets()
    local base = set_combine({
            range="Dunna",
            head="Azimuth Hood +1",
            body="Vrikodara Jupon",
            hands="Merlinic Dastanas",
            legs="Assiduity Pants",
            feet="Geo. Sandals +1",
            neck="Sanctity Necklace",
            waist="Refoccilation Stone",
            left_ear="Mendi. Earring",
            right_ear="Moonshade Earring",
            left_ring="Fortified Ring",
            right_ring="Janniston Ring",
            back="Lifestream Cape",
        }
    )
    sets.base = base

    sets.idle = set_combine(base, {
        right_ear="Moonshade Earring",
    });
    sets.engaged = set_combine(base, {});

    sets.fastcast = set_combine(base, {
        -- Fast cast +2
        head="Selenian Cap",
        -- Fast cast +5%
        body="Vrikodara Jupon",
        -- Fast cast +4%
        legs="Gyve Trousers",
        -- Fast cast +4-6%
        feet="Regal Pumps",
        -- Enhances fast cast
        left_ear="Loquac. Earring",
        -- TODO: back="Swith Cape"
    });
    sets.cure_fastcast = set_combine(
        sets.fastcast,
        {
            -- Cure magic time -7%
            body="Vanya Robe",
            -- Cure magic time -3%
            right_ear="Mendi. Earring",
            -- Cure magic time -8%
            back="Pahtli Cape",
            -- Cure casting time -15%
            feet="Vanya Clogs",
        }
    );
    sets.healing_fastcast = set_combine(sets.fastcast, {
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
            -- Cure pot +5
            neck="Nodens Gorget",
            -- cure pot 13
            body="Vrikodara Jupon",
            -- cure pot 10
            legs="Gyve Trousers",
            -- cure pot 5
            feet="Vanya Clogs",
            -- cure pot 5-6
            right_ear="Mendi. Earring",
            -- healing magic skill 10
            left_ring="Sirona's Ring",
            -- cure pot II 5
            right_ring="Janniston Ring",
            -- cure pot 4
            back="Tempered Cape",
        }
    );

    sets.resting = set_combine(base, {
        body="Errant Hpl.",
        neck="Eidolon Pendant",
        hands="Oracle's Gloves",
        feet="Oracle's Pigaches",
        waist="Shinjutsu-no-Obi +1",
        left_ear="Antivenom Earring",
    });

    sets.enhancing_magic = set_combine(base, {
        -- Conserver MP 3
        head="Selenian Cap",
        -- Enh. skill 12
        body="Telchine Chas.",
        -- Buffs stoneskin
        waist="Siegel Sash",
        -- enmity -3, MND
        left_ring="Tamas Ring",
        -- enmity -7
        right_ring="Janniston Ring",
    });
    sets.stoneskin = set_combine(sets.enhancing_magic, {
        -- Stoneskin +30
        neck="Nodens Gorget",
        -- enhances stoneskin
        waist="Siegel Sash",
    });
    sets.regen = set_combine(sets.enhancing_magic, {
    });
    sets.barspells = set_combine(sets.enhancing_magic, {
    });
    sets.healing_magic = set_combine(base, {
        -- Healing magic skill +17
        feet="Vanya Clogs",
        -- Healing magic skill +10
        left_ring="Sirona's Ring",
        -- Healing magic skill +4
        back="Tempered Cape",
    });
    sets.cursna = set_combine(sets.healing_magic, {
        -- Cursna +5
        feet="Vanya Clogs",
    });
    sets.enfeebling_magic = set_combine(sets.base, {
        -- macc +7
        head="Helios Band",
        -- macc +21
        body="Vanya Robe",
        -- statvomit
        legs="Gyve Trousers",
        -- macc 4, matk 10
        waist="Refoccilation Stone",
    });
    sets.divine_magic = set_combine(sets.base, {
        -- Macc +7, statvomit
        head="Helios Band",
        -- macc +21, statvomit
        body="Vanya Robe",
        -- matk +40, statvomit
        legs="Gyve Trousers",
        -- matk +18
        feet="Manabyss Pigaches",
        -- macc 4, matk 10
        waist="Refoccilation Stone",
        -- matk +6
        left_ear="Hecate's Earring",
        -- mnd +3
        left_ring="Sirona's Ring",
        -- mnd +5
        right_ring="Tamas Ring",
        -- buffs banish vs undead
        back="Disperser's Cape",
    });

    sets.nuking = set_combine(
        sets.base,
        {
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
            -- macc 37, matk 37
            hands="Jhakri Cuffs +1",
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
            -- MB bonus
            right_ring="Mujin Band",
        }
    );

    sets.geomancy = set_combine(
        sets.base,
        {
            -- Geomancy +15
            head="Azimuth Hood +1",
            -- Geomancy +12
            body="Bagua Tunic +1",
            -- Geomancy +15
            hands="Geomancy Mitaines",
            -- Geomancy +10
            neck="Deceiver's Torque",
            -- Geomancy +5
            back={
                name="Lifestream Cape",
                augments={
                        'Geomancy Skill +10',
                        'Indi. eff. dur. +11',
                        'Pet: Damage taken -5%',
                }
            },
        }
    )
    
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
            -- equip(kirstin_staves.fastcast[spell.element]);
        elseif "Enhancing Magic" == spell.skill then
            equip(sets.enhancing_fastcast);
            -- equip(kirstin_staves.fastcast[spell.element]);
        else
            equip(sets.fastcast);
            -- equip(kirstin_staves.fastcast[spell.element]);
        end
    elseif '/jobability' == spell.prefix then
    end
end

function midcast(spell)
    cancel_buffs(spell);
    if spell.prefix == '/magic' then
        if string.startswith(spell.english, "Cur") then
            equip(sets.curepotency);
        elseif 'Divine Magic' == spell.skill then
            equip(sets.divine_magic);
        elseif 'Elemental Magic' == spell.skill or
               'Dark Magic' == spell.skill or
               'Ninjutsu' == spell.skill then
            equip(sets.nuking);
            -- equip(kirstin_staves.nuking[spell.element]);
        elseif 'Healing Magic' == spell.skill then
            if "Cursna" == spell.english then
                equip(sets.cursna);
            else
                equip(sets.healing_magic);
            end
        elseif 'Enfeebling Magic' == spell.skill then
            equip(sets.enfeebling_magic);
            -- equip(kirstin_staves.accuracy[spell.element]);
        elseif "Enhancing Magic" == spell.skill then
            if string.startswith(spell.english, "Regen") then
                equip(sets.regen);
            elseif string.startswith(spell.english, "Bar") then
                equip(sets.barspells);
            elseif "Stoneskin" == spell.english then
                equip(sets.stoneskin);
            else
                equip(sets.enhancing_magic);
            end
        elseif "Geomancy" == spell.skill then
            equip(sets.geomancy);
        end
    end
end

function aftercast(spell)
    if "Engaged" == player.status then
        equip(sets.engaged)
    else
        equip(sets.idle)
        equip(time_specific_gear());
    end
end

function status_change(new,old)
    if "Idle" == new then
        equip(set_combine(sets.idle, time_specific_gear()))
    elseif "Resting" == new then
        equip(set_combine(sets.resting, time_specific_gear()))
    elseif "Engaged" == new then
        equip(sets.engaged)
    end
end

include("remove_silence");
include("cancel_buffs");
include("shared/staves");

local modesets = require("modesets");

-- Gear with augments
local aug_gear = require('shared/aug_gear');

function time_specific_gear()
    if world.time >= 8*60 and world.time < 18*60 then
        return { feet="Serpentes Sabots" };
    else
        return { hands="Serpentes Cuffs" };
    end
end

function get_sets()

    AF = {
        head="Geo. Galero +2",
        body="Geomancy Tunic +2",
        hands="Geo. Mitaines +2",
        legs="Geomancy Pants +2",
        feet="Geo. Sandals +3",
    }
    relic = {
        head = "Bagua Galero",
        body = "Bagua Tunic +1",
        hands = "Bagua Mitaines",
        legs = "Bagua Pants +1",
        feet = "Bagua Sandals +1",
    }
    empy = {
        head = "Azimuth Hood +1",
        body = "Azimuth Coat",
        hands = "Azimuth Gloves",
        legs = "Azimuth Tights",
        feet = "Azimuth Gaiters +1",
    }
    capes = {}
    capes.geomancy_skill = {
        name="Lifestream Cape",
        augments={
            'Geomancy Skill +10',
            'Indi. eff. dur. +11',
            'Pet: Damage taken -5%',
        }
    }
    capes.pet_dt = capes.geomancy_skill
    capes.fastcast = capes.geomancy_skill

    idle_mode = modesets.make_set(
        'Idlemode',
        {'refresh', 'defensive', 'luopan'}
    );
    engaged_mode = modesets.make_set(
        'Engagedmode',
        {'luopan', 'defensive', 'refresh'}
    );
    send_command('bind ^f9 gs c mode Idlemode cycle');
    add_to_chat(128, "Idlemode set to refresh, press ctrl-F9 to change");
    send_command('bind ^f10 gs c mode Engagedmode cycle');
    add_to_chat(128, "Engagedmode set to luopan, press ctrl-F9 to change");


    local base = set_combine({
            range="Dunna",
            head=empy.head,

            -- macc 46, matk 46, refresh +4
            body="Jhakri Robe +2",

            hands="Merlinic Dastanas",
            legs="Assiduity Pants",
            feet=AF.feet,
            neck="Sanctity Necklace",
            waist="Refoccilation Stone",
            left_ear="Mendi. Earring",
            right_ear="Moonshade Earring",
            left_ring="Fortified Ring",
            right_ring="Janniston Ring",
            back=capes.pet_dt,
        }
    )
    sets.base = base

    sets.fastcast = set_combine(base, {
        -- Fast cast +8
        head="Merlinic Hood",
        -- Fast cast +8
        body="Shango Robe",
        -- Fast cast +13
        legs=AF.legs,
        -- Fast cast +4-6
        feet="Regal Pumps",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- Fast cast +2
        left_ear="Loquac. Earring",
        -- Fast cast +2
        left_ring="Prolix Ring",
        -- Fast cast +4
        right_ring="Kishar Ring",
        -- Fast cast +7
        back=capes.fastcast,
    });
    sets.cure_fastcast = set_combine(
        sets.fastcast,
        {
            -- Cure magic time -7%
            body="Vanya Robe",
            -- Cure magic time -3%
            left_ear="Mendi. Earring",
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
    sets.elemental_fastcast = set_combine(sets.fastcast, {
        -- Elem. magic casting time -11%
        hands=relic.hands,
        -- Elem magic casting time -3%
        left_ear="Barkaro. Earring",
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
            left_ear="Mendi. Earring",
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
        -- macc 40
        head=aug_gear.nuke.head,
        -- macc 46
        body="Jhakri Robe +2",
        -- macc 43
        hands="Jhakri Cuffs +2",
        -- macc 45
        legs="Jhakri Slops +2",
        -- macc 46
        feet="Geo. Sandals +3",
        -- macc 10
        neck="Sanctity Necklace",
        -- macc 7
        waist="Eschan Stone",
        -- macc 8
        left_ear="Barkaro. Earring",
        -- macc 10
        right_ear="Digni. Earring",
        -- macc 6
        left_ring="Jhakri Ring",
        -- macc 5
        right_ring="Vertigo Ring",
        -- macc 5
        back="Izdubar Mantle",
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
            -- macc 40, matk 40, refresh +3
            body="Jhakri Robe +2",
            -- macc 43, matk 40
            hands="Jhakri Cuffs +2",
            -- macc 40 (aug), matk 13 (aug), mdam 13
            legs="Merlinic Shalwar",
            -- macc 42, matk 39
            feet="Jhakri Pigaches +2",
            -- macc 10, matk 10
            neck="Sanctity Necklace",
            -- macc 4, matk 10
            waist="Refoccilation Stone",
            -- matk 8, macc 8
            left_ear="Barkaro. Earring",
            -- matk 10
            right_ear="Friomisi Earring",
            -- macc 6, matk 3, mb bonus 2
            left_ring="Jhakri Ring",
            -- MB bonus
            right_ring="Mujin Band",
        }
    );

    sets.geomancy = set_combine(
        sets.base,
        {
            -- Geomancy +15
            head=empy.head,
            -- Set bonus
            body=empy.body,
            -- Set bonus
            hands=empy.hands,
            -- Indi duration +12
            legs=relic.legs,
            -- Indi duration +20, set bonus
            feet=empy.feet,
            -- Geomancy +10
            neck="Deceiver's Torque",
            -- Geomancy +15
            back=capes.geomancy_skill,
        }
    );

    sets.engaged = {}
    sets.engaged['defensive'] = set_combine(
        sets.base,
        {
            -- def 107, mdef 5
            head=AF.head,
            -- pdt -3
            body="Vrikodara Jupon",
            -- pdt -2
            hands=AF.hands,
            -- mdt -2
            legs="Gyve Trousers",
            -- pdt -4
            feet=empy.feet,
            -- dt -6
            neck="Loricate Torque +1",
            -- mdt -2
            left_ear="Merman's Earring",
            -- mdt -2
            right_ear="Odnowa Earring +1",
            -- pdt -5
            left_ring="Patricius Ring",
            -- dt -10
            right_ring="Defending Ring",
            -- dt -4
            back="Solemnity Cape",
        }
    );
    sets.engaged['luopan'] = set_combine(
        sets.engaged['defensive'],
        {
            -- Luopan regen +3
            head=empy.head,
            -- Luopan dt -12%
            hands=AF.hands,
            -- Luopan regen +3
            feet=relic.feet,
            -- pet dt -3, pet regen +1, pet eva +10
            waist="Isa Belt",
            -- Luopan dt -5%
            back=capes.pet_dt,
        }
    );
    sets.engaged['refresh'] = set_combine(
        sets.engaged['luopan'],
        {
            -- refresh +1
            head="Befouled Crown",
            -- refresh +4
            body="Jhakri Robe +2",
            -- refresh +1
            hands=relic.hands,
            -- refresh +1
            legs="Assiduity Pants",
        }
    );

    sets.idle = {}
    sets.idle['base'] = {
        -- Runspeed +12
        feet=AF.feet,
    }
    sets.idle['refresh'] = set_combine(
        sets.engaged['refresh'],
        sets.idle['base'],
        {
            -- refresh +1
            right_ear="Moonshade Earring",
        }
    );
    sets.idle['defensive'] = set_combine(
        sets.engaged['defensive'],
        sets.idle['base'],
        {}
    );
    sets.idle['luopan'] = set_combine(
        sets.engaged['luopan'],
        sets.idle['base'],
        {}
    );

    sets.JA = {};
    sets.JA["Bolster"] = { body=relic.body }
    sets.JA["Mending Halation"] = { legs=relic.legs }
    sets.JA["Radial Arcana"] = { feet=relic.feet }
    sets.JA["Full Circle"] = {
        head=empy.head,
        body=AF.body
    }

    
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
        elseif "Enhancing Magic" == spell.skill then
            equip(sets.enhancing_fastcast);
        elseif "Elemental Magic" == spell.skill then
            equip(sets.elemental_fastcast);
        else
            equip(sets.fastcast);
        end
    elseif '/jobability' == spell.prefix then
        local gear = sets.JA[spell.english]
        if(gear ~= nil) then
            equip(gear)
        end
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
        equip(sets.engaged[engaged_mode.value]);
    else
        equip(sets.idle[idle_mode.value]);
    end
end

function status_change(new,old)
    if "Idle" == new then
        equip(sets.idle[idle_mode.value]);
    elseif "Resting" == new then
        equip(sets.resting)
    elseif "Engaged" == new then
        equip(sets.engaged[engaged_mode.value]);
    end
end

function self_command(command)
    if modesets.self_command(command) then
        return
    end
end

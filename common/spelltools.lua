roman_numerics = {
    ['I'] = 1,
    ['II'] = 2,
    ['III'] = 3,
    ['IV'] = 4,
    ['V'] = 5,
    ['VI'] = 6
};

tier_postfix = {
    "",
    " II",
    " III",
    " IV",
    " V",
    " VI"
};

spell_mp_costs = {
    WHM = {
        {1,"Cure",8},
        {3,"Dia",7},
        {4,"Paralyze",6},
        {5,"Banish",15},
        {5,"Barstonra",12},
        {6,"Poisona",8},
        {7,"Barsleepra",14},
        {7,"Protect",9},
        {7,"Protectra",9},
        {9,"Paralyna",12},
        {10,"Aquaveil",12},
        {10,"Barpoisonra",18},
        {11,"Cure II",24},
        {12,"Barparalyzra",22},
        {13,"Baraera",12},
        {13,"Slow",15},
        {14,"Blindna",16},
        {15,"Banishga",41},
        {15,"Deodorize",10},
        {15,"Silence",16},
        {16,"Curaga",60},
        {17,"Barfira",12},
        {17,"Shell",18},
        {17,"Shellra",18},
        {18,"Barblindra",26},
        {18,"Diaga",12},
        {19,"Blink",20},
        {19,"Silena",24},
        {20,"Sneak",20},
        {21,"Barblizzara",12},
        {21,"Cure III",46},
        {21,"Regen",15},
        {23,"Barsilencera",30},
        {25,"Barthundra",12},
        {25,"Invisible",15},
        {25,"Raise",150},
        {25,"Reraise",150},
        {27,"Protect II",28},
        {27,"Protectra II",28},
        {28,"Stoneskin",29},
        {29,"Cursna",30},
        {30,"Banish II",57},
        {31,"Curaga II",120},
        {32,"Erase",18},
        {34,"Viruna",48},
        {36,"Dia II",30},
        {36,"Teleport-Dem",75},
        {36,"Teleport-Holla",75},
        {36,"Teleport-Mea",75},
        {37,"Shell II",37},
        {37,"Shellra II",37},
        {38,"Teleport-Altep",100},
        {38,"Teleport-Yhoat",100},
        {39,"Barvira",37},
        {39,"Stona",40},
        {40,"Banishga II",120},
        {40,"Cura",30},
        {40,"Haste",40},
        {41,"Cure IV",88},
        {42,"Teleport-Vahzl",100},
        {43,"Barpetra",40},
        {44,"Regen II",36},
        {45,"Flash",25},
        {47,"Protect III",46},
        {47,"Protectra III",46},
        {48,"Repose",26},
        {50,"Holy",100},
        {51,"Curaga III",180},
        {53,"Recall-Jugner",125},
        {53,"Recall-Meriph",125},
        {53,"Recall-Pashh",125},
        {55,"Auspice",48},
        {56,"Raise II",150},
        {56,"Reraise II",150},
        {57,"Shell III",56},
        {57,"Shellra III",56},
        {61,"Cure V",135},
        {61,"Esuna",24},
        {63,"Protect IV",65},
        {63,"Protectra IV",65},
        {65,"Banish III",96},
        {65,"Sacrifice",18},
        {66,"Regen III",64},
        {68,"Shell IV",75},
        {68,"Shellra IV",75},
        {70,"Raise III",150},
        {70,"Reraise III",150},
        {71,"Curaga IV",260},
        {75,"Protectra V",84},
        {75,"Shellra V",93},
        {76,"Protect V",84},
        {76,"Shell V",93},
        {78,"Baramnesra",60},
        {80,"Cure VI",227},
    },
    BLM = {
        {1,"Stone",9},
        {3,"Poison",5},
        {4,"Blind",5},
        {5,"Water",13},
        {7,"Bind",8},
        {9,"Aero",18},
        {10,"Bio",15},
        {10,"Blaze Spikes",8},
        {12,"Drain",21},
        {13,"Fire",24},
        {15,"Stonega",37},
        {16,"Shock",25},
        {17,"Blizzard",30},
        {17,"Warp",100},
        {18,"Rasp",25},
        {19,"Waterga",47},
        {20,"Choke",25},
        {20,"Ice Spikes",16},
        {20,"Sleep",19},
        {21,"Thunder",37},
        {22,"Frost",25},
        {23,"Aeroga",57},
        {24,"Burn",25},
        {24,"Poisonga",44},
        {25,"Aspir",10},
        {25,"Tractor",26},
        {26,"Stone II",43},
        {27,"Drown",25},
        {28,"Firaga",71},
        {29,"Escape",125},
        {30,"Shock Spikes",24},
        {30,"Water II",51},
        {31,"Sleepga",38},
        {32,"Blizzaga",82},
        {34,"Aero II",59},
        {35,"Bio II",36},
        {36,"Thundaga",95},
        {38,"Fire II",68},
        {40,"Stonega II",109},
        {40,"Warp II",150},
        {41,"Sleep II",29},
        {42,"Blizzard II",77},
        {43,"Poison II",38},
        {44,"Waterga II",123},
        {45,"Stun",25},
        {46,"Thunder II",86},
        {48,"Aeroga II",138},
        {50,"Freeze",307},
        {51,"Stone III",92},
        {52,"Tornado",322},
        {53,"Firaga II",158},
        {54,"Quake",337},
        {55,"Retrace",150},
        {55,"Water III",98},
        {56,"Burst",352},
        {56,"Sleepga II",58},
        {57,"Blizzaga II",175},
        {58,"Flood",368},
        {59,"Aero III",106},
        {60,"Flare",383},
        {61,"Thundaga II",193},
        {62,"Fire III",113},
        {63,"Stonega III",211},
        {64,"Blizzard III",120},
        {65,"Waterga III",231},
        {66,"Thunder III",128},
        {67,"Aeroga III",252},
        {68,"Stone IV",138},
        {69,"Firaga III",277},
        {70,"Water IV",144},
        {71,"Blizzaga III",299},
        {72,"Aero IV",150},
        {73,"Fire IV",157},
        {73,"Thundaga III",322},
        {74,"Blizzard IV",164},
        {75,"Burst II*",287},
        {75,"Flare II*",287},
        {75,"Flood II*",287},
        {75,"Freeze II*",287},
        {75,"Quake II*",287},
        {75,"Thunder IV",171},
        {75,"Tornado II*",287},
        {77,"Stone V",222},
        {80,"Water V",239},
        {81,"Stoneja",299},
        {83,"Aero V",255},
        {83,"Aspir II",5},
    },
    RDM = {
        {1,"Dia",7},
        {3,"Cure",8},
        {4,"Stone",9},
        {5,"Barstone",6},
        {5,"Poison",5},
        {6,"Paralyze",6},
        {7,"Barsleep",7},
        {7,"Protect",9},
        {8,"Blind",5},
        {9,"Barwater",6},
        {9,"Water",13},
        {10,"Barpoison",9},
        {10,"Bio",15},
        {11,"Bind",8},
        {12,"Aquaveil",12},
        {12,"Barparalyze",11},
        {13,"Baraero",6},
        {13,"Slow",15},
        {14,"Aero",18},
        {14,"Cure II",24},
        {15,"Deodorize",10},
        {15,"Diaga",12},
        {16,"Enthunder",12},
        {17,"Barfire",6},
        {17,"Shell",18},
        {18,"Barblind",13},
        {18,"Enstone",12},
        {18,"Silence",16},
        {19,"Fire",24},
        {20,"Blaze Spikes",8},
        {20,"Enaero",12},
        {20,"Sneak",12},
        {21,"Barblizzard",6},
        {21,"Gravity",24},
        {21,"Regen",15},
        {22,"Enblizzard",12},
        {23,"Barsilence",15},
        {23,"Blink",20},
        {24,"Blizzard",30},
        {24,"Enfire",12},
        {25,"Barthunder",6},
        {25,"Invisible",15},
        {25,"Sleep",19},
        {26,"Cure III",46},
        {27,"Enwater",12},
        {27,"Protect II",28},
        {29,"Thunder",37},
        {31,"Dia II",30},
        {32,"Dispel",25},
        {33,"Phalanx",21},
        {34,"Stoneskin",29},
        {35,"Stone II",43},
        {36,"Bio II",36},
        {37,"Shell II",37},
        {38,"Raise",150},
        {39,"Barvirus",25},
        {40,"Ice Spikes",16},
        {40,"Water II",51},
        {41,"Refresh",40},
        {43,"Barpetrify",20},
        {45,"Aero II",59},
        {46,"Poison II",38},
        {46,"Sleep II",29},
        {47,"Protect III",46},
        {48,"Cure IV",88},
        {48,"Haste",40},
        {50,"Enthunder II",24},
        {50,"Fire II",68},
        {52,"Enstone II",24},
        {54,"Enaero II",24},
        {55,"Blizzard II",77},
        {56,"Enblizzard II",24},
        {57,"Shell III",56},
        {58,"Enfire II",24},
        {60,"Enwater II",24},
        {60,"Shock Spikes",24},
        {60,"Thunder II",86},
        {63,"Protect IV",65},
        {65,"Stone III",92},
        {67,"Water III",98},
        {68,"Shell IV",75},
        {69,"Aero III",106},
        {71,"Fire III",113},
        {73,"Blizzard III",120},
        {75,"Bio III",54},
        {75,"Blind II",31},
        {75,"Dia III",45},
        {75,"Paralyze II",36},
        {75,"Phalanx II",42},
        {75,"Slow II",45},
        {75,"Thunder III",128},
        {76,"Regen II",36},
        {77,"Protect V",84},
        {77,"Stone IV",138},
        {78,"Baramnesia",30},
        {80,"Water IV",144},
        {81,"Gain-VIT",36},
        {82,"Refresh II",60},
        {83,"Addle",36},
        {83,"Aero IV",150},
        {85,"Gain-MND",36},
        {86,"Fire IV",157},
        {87,"Break",39},
        {87,"Gain-CHR",36},
        {87,"Shell V",93},
        {89,"Blizzard IV",164},
        {90,"Gain-AGI",36},
    },
    SCH = {
        {4,"Stone",9},
        {5,"Cure",8},
        {8,"Water",13},
        {10,"Poisona",8,"Addendum: White"},
        {10,"Protect",9},
        {12,"Aero",18},
        {12,"Paralyna",12,"Addendum: White"},
        {14,"Blindna",16,"Addendum: White"},
        {15,"Deodorize",10},
        {16,"Fire",24},
        {17,"Cure II",24},
        {18,"Geohelix",26},
        {18,"Regen",15},
        {20,"Blizzard",30},
        {20,"Hydrohelix",26},
        {20,"Shell",18},
        {20,"Sneak",12},
        {21,"Drain",21},
        {22,"Anemohelix",26},
        {22,"Silena",24,"Addendum: White"},
        {24,"Pyrohelix",26},
        {24,"Thunder",37},
        {25,"Invisible",15},
        {26,"Cryohelix",26},
        {28,"Ionohelix",26},
        {30,"Cure III",46},
        {30,"Noctohelix",26},
        {30,"Protect II",28},
        {30,"Sleep",19,"Addendum: Black"},
        {30,"Stone II",43},
        {32,"Cursna",30,"Addendum: White"},
        {32,"Dispel",25,"Addendum: Black"},
        {32,"Luminohelix",26},
        {34,"Water II",51},
        {35,"Raise",150},
        {35,"Reraise",150,"Addendum: White"},
        {36,"Aspir",10},
        {37,"Regen II",36},
        {38,"Aero II",59},
        {39,"Erase",18,"Addendum: White"},
        {40,"Shell II",37},
        {41,"Sandstorm",30},
        {42,"Fire II",68},
        {43,"Rainstorm",30},
        {45,"Windstorm",30},
        {46,"Blizzard II",77},
        {46,"Klimaform",30},
        {47,"Firestorm",30},
        {49,"Hailstorm",30},
        {50,"Protect III",46},
        {50,"Stona",40,"Addendum: White"},
        {51,"Thunder II",86},
        {51,"Thunderstorm",30},
        {53,"Voidstorm",30},
        {54,"Stone III",92},
        {55,"Aurorastorm",30},
        {55,"Cure IV",88},
        {57,"Water III",98},
        {59,"Regen III",64},
        {60,"Aero III",106},
        {60,"Shell III",56},
        {63,"Fire III",113},
        {65,"Sleep II",29,"Addendum: Black"},
        {66,"Blizzard III",120},
        {66,"Protect IV",65},
        {69,"Thunder III",128},
        {70,"Raise II",150,"Addendum: White"},
        {70,"Reraise II",150,"Addendum: White"},
        {70,"Stone IV",138,"Addendum: Black"},
        {71,"Shell IV",75},
        {71,"Water IV",144,"Addendum: Black"},
        {72,"Aero IV",150,"Addendum: Black"},
        {73,"Fire IV",157,"Addendum: Black"},
        {74,"Blizzard IV",164,"Addendum: Black"},
        {75,"Thunder IV",171,"Addendum: Black"},
        {79,"Regen IV",82},
        {79,"Stone V",156,"Addendum: Black"},
        {80,"Protect V",84},
        {83,"Water V",182,"Addendum: Black"},
        {85,"Animus Augeo",21},
        {85,"Animus Minuo",21},
        {87,"Aero V",210,"Addendum: Black"},
        {88,"Adloquium",50},
        {90,"Shell V",93},
        {90,"Break",39,"Addendum: Black"},
        {91,"Raise III",150,"Addendum: White"},
        {91,"Reraise III",150,"Addendum: White"},
        {91,"Fire V",240,"Addendum: Black"},
        {95,"Blizzard V",272,"Addendum: Black"},
        {97,"Aspir II",5},
        {99,"Regen V",100},
        {99,"Thunder V",306,"Addendum: Black"},
    }
}

spellcost_map = {};
addendum_map = {
    ["Penury"] = "Addendum: White",
    ["Celerity"] = "Addendum: White",
    ["Rapture"] = "Addendum: White",
    ["Accession"] = "Addendum: White",
    ["Perpetuance"] = "Addendum: White",
    ["Addendum: White"] = "Addendum: White",

    ["Parsimony"] = "Addendum: Black",
    ["Alacrity"] = "Addendum: Black",
    ["Ebullience"] = "Addendum: Black",
    ["Manifestation"] = "Addendum: Black",
    ["Immanence"] = "Addendum: Black",
    ["Addendum: Black"] = "Addendum: Black"
};
downgrade_map = nil;

function split_spell_basename_and_tier(spellname)
    local idx = 0;
    local lastpos = idx;
    local basename = spellname;

    -- find last space in spellname
    while idx ~= nil do
        lastpos = idx
        idx = string.find(spellname, " ", idx+1)
    end

    -- If we find a space, check if last part of name is a roman numerical.
    -- If it is, remove it from the basename and set the index accordingly.
    if lastpos then
        idx = roman_numerics[string.sub(spellname, lastpos+1)]
        if idx ~= nil then
            basename = string.sub(spellname, 1, lastpos - 1);
        end
    end

    if not idx then
        idx = 1
    end

    return {
        ['basename'] = basename,
        ['tier'] = idx
    }
end

function setup_spellcost_map(player, spells_to_downgrade)
    mainjob = player.main_job;
    subjob = player.sub_job;
    mlevel = player.main_job_level;
    slevel = player.sub_job_level;

    local function add_spell(spellname, mpcost)
        local sp = split_spell_basename_and_tier(spellname);
        local basename = sp['basename'];
        local tier = sp['tier'];

        local list = spellcost_map[basename];
        if list == nil then
            spellcost_map[basename] = {};
            list = spellcost_map[basename];
        end
        local existing = list[tier];
        if existing and existing < mpcost then
            return
        end
        list[tier] = mpcost
    end

    local _addendum_map = {};
    for job, level in pairs({[mainjob]=mlevel, [subjob]=slevel}) do
        local list = spell_mp_costs[job];
        if list ~= nil then
            for _,spell in ipairs(list) do
                if spell[1] > level then
                    break
                end
                add_spell(spell[2], spell[3]);
                if _addendum_map[spell[2]] ~= false then
                    _addendum_map[spell[2]] = spell[4] or false
                end
            end
        end
    end
    for sname,v in pairs(_addendum_map) do
        if v ~= false then
            addendum_map[sname] = v
        end
    end

    -- Configure which spells to downgrade
    if spells_to_downgrade ~= nil then
        downgrade_map = {}
        for i,sname in ipairs(spells_to_downgrade) do
            s = split_spell_basename_and_tier(sname);
            downgrade_map[s['basename']] = true;
        end
    else
        -- Copy full spellcost map
        downgrade_map = {}
        for k,v in pairs(spellcost_map) do
            downgrade_map[k] = true;
        end
        -- But never downgrade Warp II
        downgrade_map["Warp II"] = false;
    end
end

function check_addendum(spell)
    local spellname = spell.english
    local buffneeded = addendum_map[spellname];

    if buffneeded == nil or buffactive[buffneeded] then
        return false;
    end

    -- Always have access to everything with Enlightenment buff
    if buffactive["Enlightenment"] then
        return false;
    end

    local allRecasts = windower.ffxi.get_ability_recasts()

    if "Addendum: White" == buffneeded then
        if buffactive["Light Arts"] then
            add_to_chat(128, "~~~~ Auto-enabling " .. buffneeded .. ' ~~~~');
            send_command('input /ja "' .. buffneeded .. '" <me>')
            cancel_spell();
            return true;
        else
            cancel_spell();
            -- check if ready
            if (allRecasts[228] or 0) > 0 then
                add_to_chat(128, '~~~~ Aborting Light Arts: Not ready ~~~~');
                return true
            end
            add_to_chat(128, '~~~~ Auto-enabling Light Arts ~~~~');
            cmd = (
                'input /ja "Light Arts" <me>;' ..
                'pause 2;' ..
                'input /ma "' .. spell.english .. '" ' .. spell.target.raw
            )
            send_command(cmd)
            return true;
        end
    elseif "Addendum: Black" == buffneeded then
        if buffactive["Dark Arts"] then
            add_to_chat(128, "~~~~ Auto-enabling " .. buffneeded .. ' ~~~~');
            send_command('input /ja "' .. buffneeded .. '" <me>')
            cancel_spell();
            return true;
        else
            -- check if ready
            if (allRecasts[232] or 0) > 0 then
                add_to_chat(128, '~~~~ Aborting Dark Arts: Not ready ~~~~');
                return true
            end
            add_to_chat(128, '~~~~ Auto-enabling Dark Arts ~~~~');
            cmd = (
                'input /ja "Dark Arts" <me>;' ..
                'pause 2;' ..
                'input /ma "' .. spell.english .. '" ' .. spell.target.raw
            )
            send_command(cmd)
            cancel_spell();
            return true;
        end
    end

    return false;
end

function activate_light_arts()
    if not (
        buffactive["Light Arts"] or
        buffactive["Addendum: White"] or
        buffactive["Enlightenment"]
    ) then
        send_command('input /ja "Light Arts" <me>');
        add_to_chat(128, '~~~~ Auto-enabling Light Arts ~~~~');
        cancel_spell();
        return true;
    end
    return false
end

function activate_dark_arts()
    if not (
        buffactive["Dark Arts"] or
        buffactive["Addendum: Black"] or
        buffactive["Enlightenment"]
    ) then
        send_command('input /ja "Dark Arts" <me>');
        add_to_chat(128, '~~~~ Auto-enabling Dark Arts ~~~~');
        cancel_spell();
        return true;
    end
    return false
end

function get_mp_cost_factor(spell)
    if spell.type=="WhiteMagic" then
        if buffactive["Penury"] then
            return 0.5
        elseif buffactive["Light Arts"] or buffactive["Addendum: White"] then
            return 0.9
        elseif buffactive["Dark Arts"] or buffactive["Addendum: Black"] then
            return 1.1
        end
    elseif spell.type=="BlackMagic" then
        if buffactive["Parsimony"] then
            return 0.5
        elseif buffactive["Dark Arts"] or buffactive["Addendum: Black"] then
            return 0.9
        elseif buffactive["Light Arts"] or buffactive["Addendum: White"] then
            return 1.1
        end
    end
    return 1
end

function downgrade_spell(player, spell)
    -- If no spells configured, do nothing
    if not downgrade_map then
        return false;
    end

    local s = split_spell_basename_and_tier(spell.english);
    if not downgrade_map[s['basename']] then
        return false;
    end

    if not spell.mp_cost then
        return false;
    end;

    local cost_factor = get_mp_cost_factor(spell);
    local tier_table = spellcost_map[s['basename']];
    if not tier_table then
        return false
    end
    local tier = s['tier'];
    local cost = tier_table[tier];
    if cost == nil then
        return false
    else
        cost = cost * cost_factor
    end
    while tier > 0 and cost > player.mp do
        cost = tier_table[tier] * cost_factor;
        tier = tier - 1;
    end
    if tier > 0 and tier < s['tier'] then
        local newSpellName = s['basename'] .. tier_postfix[tier];
        add_to_chat(
            128,
            "Downgraded " .. spell.english .. " to " .. newSpellName
        );
        send_command(
            'input /ma "' .. newSpellName .. '" ' .. spell.target.raw
        );
        cancel_spell();
        return true;
    end

    return false
end
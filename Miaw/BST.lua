include("remove_silence");
include("cancel_buffs");

-- Load MG inventory system
local mg_inv = require("mg-inventory");

local ambu = {
    head="Tali'ah Turban +2",
    body="Tali'ah Manteel +2",
    hands="Tali'ah Gages +1",
    legs="Tali'ah Sera. +2",
    feet="Tali'ah Crackows +2",
}

magic_ready_moves = S{
    'Dust Cloud', 'Sheep Song', 'Scream', 'Dream Flower', 'Roar',
    'Gloeosuccus', 'Palsy Pollen', 'Soporific', 'Cursed Sphere', 'Venom',
    'Geist Wall', 'Toxic Spit', 'Numbing Noise', 'Spoil', 'Hi-Freq Field',
    'Sandpit', 'Sandblast', 'Venom Spray', 'Bubble Shower', 'Filamented Hold',
    'Queasyshroom', 'Silence Gas', 'Numbshroom', 'Spore', 'Dark Spore',
    'Shakeshroom', 'Fireball', 'Plague Breath', 'Infrasonics','Chaotic Eye',
    'Blaster', 'Intimidate', 'Snow Cloud', 'Noisome Powder', 'TP Drainkiss',
    'Jettatura', 'Charged Whisker', 'Purulent Ooze', 'Corrosive Ooze',
    'Aqua Breath', 'Molting Plumage', 'Stink Bomb', 'Nectarous Deluge',
    'Nepenthic Plunge', 'Pestilent Plume', 'Foul Waters', 'Spider Web'
}


function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Pet Food Theta",
        head="Tali'ah Turban +2",
        body="Tali'ah Manteel +2",
        hands="Tali'ah Gages +1",
        legs="Valor. Hose",
        feet="Tali'ah Crackows +2",
        neck="Shulmanu Collar",
        waist="Olseni Belt",
        left_ear="Digni. Earring",
        right_ear="Steelflash Earring",
        left_ring={name="Varar Ring", bag="wardrobe"},
        right_ring={name="Varar Ring", bag="wardrobe4"},
        back="Sacro Mantle",
    }

    sets.call_beast = set_combine(
        sets.base,
        {
            ammo = nil,
            hands="Ankusa Gloves +1",
        }
    )
    -- Do not remove pet jug from ammo slot
    sets.call_beast.ammo = nil

    sets.ready_precast = set_combine(
        sets.base,
        {
            head=ambu.head,
            body=ambu.body,
            hands=ambu.hands,
            legs="Desultor Tassets",
            feet="Despair Greaves",
        }
    )

    sets.ready_atk = set_combine(
        sets.base,
        {
            head=ambu.head,
            body=ambu.body,
            hands=ambu.hands,
            legs=ambu.legs,
            feet=ambu.feet,
            -- pet.atk +12
            back="Argocham. Mantle",
        }
    )

    sets.ready_matk = set_combine(
        sets.base,
        {
            head=ambu.head,
            body=ambu.body,
            hands=ambu.hands,
            legs=ambu.legs,
            feet=ambu.feet,
            -- pet.matk +12
            back="Argocham. Mantle",
        }
    )

    sets.pet_pdt = set_combine(
        sets.base,
        {
            -- pet dt -3
            feet={
                name="Despair Greaves",
                augments={'Accuracy+10','Pet: VIT+7','Pet: Damage taken -3%',}
            },
            -- Master stats
            back="Sacro Mantle",
        }
    )

    sets.reward = set_combine(
        sets.base,
        {
            -- Reward +35
            feet="Loyalist Sabatons",
        }
    )

    sets.fastcast = set_combine(sets.base, {})
    sets.magic_accuracy = set_combine(sets.base, {})

    MidCastGear = nil
    AfterCastGear = {}

end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end

    AfterCastGear = sets.base
    MidCastGear = nil

    if "/pet" == spell.prefix then
        if spell.english == "Fight" then
            -- Nothing
        elseif spell.english == "Heel" then
            -- Nothing
        elseif spell.english == "Leave" then
            -- Nothing
        elseif spell.english == "Stay" then
            -- Nothing
        elseif spell.english == "Snarl" then
            -- Nothing
        elseif spell.english == "Spur" then
            -- Nothing
        elseif spell.english == "Run Wild" then
            -- Nothing
        else -- If none of the above, must be ready or sic
            equip(sets.ready_precast)
        end
    elseif spell.english == "Bestial Loyalty" or
           spell.english == "Call Beast" then
        equip(sets.call_beast)
    elseif spell.english == "Reward" then
        equip(sets.reward)
    elseif '/magic' == spell.prefix then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');

        equip(sets.fastcast)
        MidCastGear = sets.magic_accuracy
    else
        equip(sets.base)
    end

end

function pet_midcast(spell)
    if magic_ready_moves:contains(spell.english) then
        equip(sets.ready_matk)
    else
        equip(sets.ready_atk)
    end
end

function pet_aftercast(spell)
    equip(sets.pet_pdt)
end

function midcast(spell)
    cancel_buffs(spell);
    if MidCastGear ~= nil then
        equip(MidCastgear)
    end
end

function aftercast(spell)
    equip(AfterCastGear)
end

function self_command(command)
    if mg_inv.self_command(command) then
        return
    end
end

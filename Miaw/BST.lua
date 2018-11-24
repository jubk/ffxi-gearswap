include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
    sets.base = {
        ammo="Pet Food Theta",
        head="Tali'ah Turban +2",
        body="Tali'ah Manteel +2",
        hands="Tali'ah Gages +1",
        legs="Valor. Hose",
        feet="Tali'ah Crackows +2",
        neck="Empath Necklace",
        waist="Olseni Belt",
        left_ear="Digni. Earring",
        right_ear="Steelflash Earring",
        left_ring={name="Varar Ring", bag="wardrobe2"},
        right_ring={name="Varar Ring", bag="wardrobe3"},
        back="Kayapa Cape",
    }

    sets.call_beast = set_combine(
        sets.base,
        {
            ammo = nil,
            hands="Ankusa Gloves +2",
        }
    )
    -- Do not remove pet jug from ammo slot
    sets.call_beast.ammo = nil

    sets.ready = set_combine(
        sets.base,
        {
            head="Tali'ah Turban +1",
            body="Tali'ah Manteel +2",
            hands="Tali'ah Gages +1",
            legs="Desultor Tassets",
            feet="Despair Greaves",
        }
    )

    -- TODO: Loyalist sabatons for reward set
    -- TODO: Argochampsa mantle for pet matk abilities

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
            equip(sets.ready)
        end
    elseif spell.english == "Bestial Loyalty" or
           spell.english == "Call Beast" then
        equip(sets.call_beast)
    elseif '/magic' == spell.prefix then
        -- Show recast for any spell
        send_command('input /recast "' .. spell.name .. '"');

        equip(sets.fastcast)
        MidCastGear = sets.magic_accuracy
    else
        equip(sets.base)
    end

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

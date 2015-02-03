include("remove_silence");
include("cancel_buffs");
include("elemental_obis");
include("spelltools")

function get_sets()
    setup_spellcost_map(player);
end

function self_command(command)
    asdf = check_addendum("Silena", player);
    if asdf == nil then
        asdf = "nil"
    end
    add_to_chat(128, asdf);
end


function filtered_action(spell)
    -- Check whether we should activate arts/addendum instead of casting
    -- the spell.
    if check_addendum(spell.english) then
        return;
    end
end

function precast(spell)
    -- If we get interupted by removing silence, just return
    if remove_silence(spell) then
        return;
    end
end

function midcast(spell)
    cancel_buffs(spell);
end

function status_change(new,old)
    if "Idle" == new then
    elseif "Engaged" == new then
    elseif "Resting" == new then
    end
end

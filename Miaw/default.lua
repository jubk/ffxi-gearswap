include("remove_silence");
include("cancel_buffs");

function get_sets()
    -- set_has_hachirin_no_obi(true);
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

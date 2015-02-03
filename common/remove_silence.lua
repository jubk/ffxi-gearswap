function remove_silence(spell)
    -- Do nothing if "spell" is not magic
    if not table.contains({'/magic','/ninjutsu','/song'}, spell.prefix) then
        return false
    end

    if buffactive['silence'] then
        if "DNC" == player.sub_job or "DNC" == player.main_job then
            send_command('input /ja "Healing Waltz" <me>');
        else
            send_command('input /item "Echo Drops" <me>');
        end
        cancel_spell();
        return true;
    end

    return false;
end

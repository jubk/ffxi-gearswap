cs_data = {};

function get_cyclable_data(setname)
    local set = cs_data[setname];
    
    if not set then
        add_to_chat(
            128,
            "No cyclable data specifed for name '" .. setname .. "'"
        );
    end

    return set;
end

function setup_cyclable_set(set_root, setname, initial_name)
    local max = 1;
    local cycle_names = {}

    for sname,_ in pairs(set_root) do
        cycle_names[max] = sname;
        max = max + 1;
    end
    max = max - 1
   
    cs_data[setname] = {
        ['name'] = setname,
        ['elements'] = set_root,
        ['names'] = cycle_names,
        ['index'] = 1,
        ['count'] = max,
        ['current'] = ''
    };

    if initial_name then
        return set_cyclable_by_name(setname, initial_name)
    else
        return set_cyclable_by_index(setname, 1)
    end
end

function set_cyclable_by_index(setname, index, do_equip)
    local data = get_cyclable_data(setname)
    if not data then
        return
    end

    local new_name = data['names'][index];
    if new_name then
        data['index'] = index;
        data['current'] = new_name;
        add_to_chat(
            128,
            setname .. ' set is now ' .. new_name
        );
        local set = data['elements'][new_name];
        if do_equip and set then
            equip(set)
        end
        return set;
    end
end

function set_cyclable_by_name(setname, set_to, do_equip)
    local data = get_cyclable_data(setname);
    if not set then
        return
    end
    
    for index,tname in pairs(data['names']) do
        if tname == set_to then
            return set_cyclable_by_index(setname, index, do_equip)
        end
    end
end

function cycle_set(setname, do_equip)
    local data = get_cyclable_data(setname);
    if not set then
        return
    end

    local new_idx = data['index'] + 1;
    if new_idx > data['count'] then
        new_idx = 1
    end
    return set_cyclable_by_index(setname, new_idx, do_equip)
end

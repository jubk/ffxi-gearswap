--[[

This library adds some inventory management features for gearswap.
For now it can only export the placement for the gear in your sets but later
it will be able to help optimize placement of gear in wardrobes and
automatically make gear available when changing jobs.

To use it in a gearswap script place it in your gearswap common folder and
add the following at the top of the gearswap file you want to use it in:

-- Load MG inventory system
local mg_inv = require("mg-inventory");

And add a call to mg_inv.self_command (or mg_inv.job_self_command
if using Mote-libs) to your self command.

Example self_command:

function self_command(command)
    if mg_inv.self_command(command) then
        return
    end
    -- Rest of self command method goes here
end

Example job_self_command method:

function job_self_command(command, eventArgs)
    if mg_inv.job_self_command(command, eventArgs) then
        return
    end
    -- Rest of self command method goes here
end

It supports the following commands:
  `//gs c mginv export`
    Exports the gear used in your current sets and where they are stored to the
    <gearswap>/data/inventory-export directory.

--]]


return (function ()
    local MGInventory = {}

    local res = require('resources')

    local bags = {
        {name="Inventory",      id=0},
        {name="Mog Safe",       id=1},
        {name="Mog Safe 2",     id=9},
        {name="Storage",        id=2},
        {name="Mog Locker",     id=4},
        {name="Mog Satchel",    id=5},
        {name="Mog Sack",       id=6},
        {name="Mog Case",       id=7},
        {name="Mog Wardrobe",   id=8},
        {name="Mog Wardrobe 2", id=10},
        {name="Mog Wardrobe 3", id=11},
        {name="Mog Wardrobe 4", id=12},
    }

    function normalize_item(item)
        local result = {}

        if type(item) == "string" then
            result.name = item
        elseif type(item) == "table" then
            if item.id and res.items[item.id] then
                result.name = gearswap.get_short_name_by_item_id(item.id)
            elseif item.name then
                result.name = item.name
            end
            result.augments = gearswap.get_augment_string(item)
        end
        if not result.name or result.name == "empty" then
            return nil
        else
            return result
        end
    end

    function normalized_item_to_string(item)
        if not item or not item.name then return "" end
        if item.augments then
            return (item.name .. "{" .. item.augments .. "}"):lower()
        else
            return item.name:lower()
        end
    end

    function normalized_item_string(item)
        return normalized_item_to_string(normalize_item(item))
    end

    function get_current_inventory()
        local collection = {}
        local simple_names = {}

        for _, bag in ipairs(bags) do
            for _, item in ipairs(windower.ffxi.get_items(bag.id)) do
                local norm_item = normalize_item(item)
                if norm_item ~= nil then
                    collection[normalized_item_to_string(norm_item)] = bag.name
                    local simple_name = norm_item.name:lower()
                    if not simple_names[simple_name] and not collection[simple_name] then
                        simple_names[simple_name] = bag.name
                    end
                end
            end
        end

        for k, v in pairs(simple_names) do
            if not collection[k] then
                collection[k] = v
            end
        end

        return collection
    end

    -- Search the gear sets tree
    function process_items_in_gearsets(gear_table, callback, stack)
        if stack and stack:contains(gear_table) then return end
        if type(gear_table) ~= 'table' then return end

        for i,v in pairs(gear_table) do
            if type(i) == 'string' and gearswap.slot_map[i] ~= nil then
                callback(v)
            elseif type(v) == 'table' and v ~= empty  then
                if not stack then stack = S{} end
                stack:add(gear_table)
                process_items_in_gearsets(v, callback, stack)
                stack:remove(gear_table)
            end
        end
    end


    function MGInventory.export(sets)
        if not windower.dir_exists(windower.addon_path..'data/inventory-export') then
            windower.create_dir(windower.addon_path..'data/inventory-export')
        end

        local path = windower.addon_path ..
                     'data/inventory-export/' ..
                     player.name ..
                     "_" .. player.main_job ..
                     "_" .. os.clock() ..
                     ".lua"
        local inv = get_current_inventory()
        local gear_data = {seen={}}

        process_items_in_gearsets(sets, function(item)
            if type(item) == "string" then
                item = {name=item}
            end
            if not item.name or item.name == "empty" then
                return
            end

            local prefix = "    "
            local item_str = normalized_item_string(item)
            if gear_data.seen[item_str] then
                return
            else
                gear_data.seen[item_str] = true
            end
            local bag = inv[item_str] or "Not found"
            
            
            if not gear_data[bag] then
                gear_data[bag] = T{}
            end
            
            gear_data[bag]:append(item_str)
        end)

        local total = 0

        local f = io.open(path,'w+')
        f:write('job_gear["' .. player.main_job .. '"]={\n')
        for _, bag in ipairs(bags) do
            local items = gear_data[bag.name]
            if items then
                local count = 0
                f:write("    -- " .. bag.name .. ":\n")
                for _, item_str in ipairs(items) do
                    item_str = string.gsub(item_str, '"', '\\"')
                    f:write('    ["' .. item_str .. '"]="' .. bag.name .. '",\n')
                    count = count + 1
                end
                f:write("    -- Count: " .. count .. "\n")
                f:write("\n")
                total = total + count
            end
        end
        if gear_data["Not found"] then
            f:write("    -- Items not found:\n")
            local count = 0
            for _, item_str in ipairs(gear_data["Not found"]) do
                item_str = string.gsub(item_str, '"', '\\"')
                f:write('      -- ["' .. item_str .. '"]="Not found",\n')
                count = count + 1
            end
            f:write("    -- Count: " .. count .. "\n")
            total = total + count
        end

        f:write("\n")
        f:write("    -- Total: " .. total .. "\n")
        f:write("\n")
            
        f:write('}')
        f:close()

    end


    local command_handlers = {
        export=function(args) MGInventory.export(sets) end,
    }

    function MGInventory.job_self_command(commands, eventArgs)
        if commands[1] == "mginv" then
            -- Remove mginv
            table.remove(commands, 1)
            -- Get the next arg, which is our internal command name
            local cmdname = table.remove(commands, 1) or ""
            if command_handlers[cmdname] then
                command_handlers[cmdname](commands)
                eventArgs.handled = true
                return true
            end
        end

        return false
    end

    -- Compatibility for non-mote self commands
    function MGInventory.self_command(commandArgs)
        local commandArgs = commandArgs
        if type(commandArgs) == 'string' then
            commandArgs = T(commandArgs:split(' '))
        end

        local eventArgs = {handled=false}
        return MGInventory.job_self_command(commandArgs, eventArgs)
    end

    return MGInventory
end)();
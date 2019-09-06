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

  `//gs c mginv export_reverse`
    Exports the gear _not_ used in your current sets and where they are stored
    to the <gearswap>/data/inventory-export directory.
    The export_reverse command can be good if you want to remove everything
    but gear for a certain job from one of your bag.

  `//gs c mginv summary`
    Makes a summary file with all the items you have specified job preferences
    for. The file will contain the name of the items as well as how many and
    which jobs wants it placed where.

--]]

--[[
TODO:
<player.name>/mginv/settings.lua:
sub set_gear_positions(fixed_positions, floating_positions)
    fixed_positions[<itemname>]="Mog Wardrobe"
    floating_positions[<itemname>]="Mog Wardrobe"
    fixed_positions["Varar Ring]={"Mog Wardrobe", "Mog Wardrobe 4"},
end

<player.name>/mginv/data.lua:
sub set_job_gear(job_gear)
    job_gear[job][<itemname>]=true
end
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

    local config_dir = windower.addon_path..'data/' .. player.name
    local config_file = config_dir .. "/" .. player.name .. "-mginv.lua"
    local export_dir = windower.addon_path..'data/inventory-export'
    local default_config_file = [=[-- Config file for mg-invenotry.

    --[[ Job gear configuration.
    ============================

    Add you job specific gear and where you want it here, for example

        job_gear["SCH"]= {
            ["voltsurge torque"]="Mog Wardrobe 2",
            ["barkaro. earring"]="Mog Wardrobe",
        }

    You can use the export command to export gear from your current jobs.

    --]]
    function mginv_job_gear(job_gear)

        -- job_gear["SCH"]= { ["voltsurge torque"]="Mog Wardrobe 2", }

    end

    ]=]
    default_config_file = default_config_file:gsub("\n    ", "\n")

    MGInventory.config = {}

    function MGInventory.init()
        if not windower.dir_exists(config_dir) then
            windower.create_dir(config_dir)
        end
        if not windower.file_exists(config_file) then
            local f = io.open(config_file,'w+')
            f:write(default_config_file)
            f:close()
            print("Config file " ..
                  config_file:sub(windower.addon_path:length() + 1) ..
                  " created. Edit it to set up where you want your gear.")
        end

        MGInventory.load_config()

        local job_table = config.job_gear[player.main_job] or {}

        print("MGinv initialized with " .. table.length(job_table) .. " " ..
              "items registered for " .. player.main_job .. ".")

        return MGInventory
    end

    function MGInventory.load_config()
        -- Create new empty config
        config = {job_gear={}}

        -- Set up the environement in which the config file will be executed
        local conf_env = { mginv = _G, }
        conf_env['_G'] = conf_env

        -- Load the config file
        local funct, err = gearswap.loadfile(config_file)
        -- Set it to run in the environment above
        gearswap.setfenv(funct, conf_env)
        -- Execute the config file
        funct()
        -- Config methods from the file can now be found in conf_env
        conf_env.mginv_job_gear(config.job_gear)
    end
    
    
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

    function get_current_inventory(add_simple_names)
        local collection = {}
        local simple_names = {}

        for _, bag in ipairs(bags) do
            for _, item in ipairs(windower.ffxi.get_items(bag.id)) do
                local norm_item = normalize_item(item)
                if norm_item ~= nil then
                    collection[normalized_item_to_string(norm_item)] = bag.name
                    if add_simple_names then
                        local simple_name = norm_item.name:lower()
                        if not simple_names[simple_name] and not collection[simple_name] then
                            simple_names[simple_name] = bag.name
                        end
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

    function get_short_name(name)
        local idx = name:find("{")
        if idx ~= nil then
            return name:sub(1, idx - 1)
        else
            return name
        end
    end

    function quotemeta(str)
        return string.gsub(str, '"', '\\"')
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

    function setup_export_dir()
        if not windower.dir_exists(export_dir) then
            windower.create_dir(export_dir)
        end
    end

    function MGInventory.export(sets)
        local path = windower.addon_path ..
                     'data/inventory-export/' ..
                     player.name ..
                     "_" .. player.main_job ..
                     "_" .. os.clock() ..
                     ".lua"
        local inv = get_current_inventory(true)
        local gear_data = {seen={}}

        setup_export_dir()

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

        print("Current gear placement dumped to file " ..
              path:sub(windower.addon_path:length() + 1))
    end

    function MGInventory.export_reverse(sets)
        local path = windower.addon_path ..
                     'data/inventory-export/' ..
                     player.name ..
                     "_" .. player.main_job ..
                     "_reverse_" .. os.clock() ..
                     ".lua"

        local sets_gear = {}

        setup_export_dir()

        process_items_in_gearsets(sets, function(item)
            if type(item) == "string" then
                item = {name=item}
            end
            if not item.name or item.name == "empty" then
                return
            end
            sets_gear[normalized_item_string(item)] = true
        end)

        local gear_data = {}
        for itemname, bagname in pairs(get_current_inventory(false)) do
            local shortname = get_short_name(itemname)
            if not sets_gear[itemname] and not sets_gear[shortname] then
                if not gear_data[bagname] then
                    gear_data[bagname] = T{}
                end
                gear_data[bagname]:append(itemname)
            end
        end
        
        
        local total = 0

        local f = io.open(path,'w+')
        f:write('job_gear_reverse["' .. player.main_job .. '"]={\n')
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
        f:write("\n")
        f:write("    -- Total: " .. total .. "\n")
        f:write("\n")

        f:write('}')
        f:close()

    end

    function MGInventory.export_summary(sets)
        local path = windower.addon_path ..
                     'data/inventory-export/' ..
                     player.name ..
                     "_summary_" .. os.clock() ..
                     ".lua"
        local inv = get_current_inventory(true)
        local result = {}
        local seen_gear = {}

        local function add_item(itemname, used_or_unused, job, wanted_location)
            local current_bag = inv[itemname] or "Not found"
            if not result[current_bag] then
                result[current_bag] = { used=T{}, unused=T{} }
            end

            if not result[current_bag][used_or_unused][itemname] then
                result[current_bag][used_or_unused][itemname] = T{
                    count=0,
                    jobs=T{}
                }
            end
            
            local itemdata = result[current_bag][used_or_unused][itemname]

            if job then
                itemdata.count = itemdata.count + 1
                itemdata.jobs:append(job .. " => " .. wanted_location)
            end
        end

        local function format_line(itemname, data)
            local result = '["' .. quotemeta(itemname) .. '"]=' ..
                   "{" ..
                   "count=" .. data.count
            if table.length(data.jobs) > 0 then
                result = result  .. ", " ..
                         'jobs={"' .. data.jobs:concat('", "') .. '"}'
            end
            result = result .. "}"
            return result
        end

        setup_export_dir()

        for job, items in pairs(config.job_gear) do
            for itemname, wanted_location in pairs(items) do
                add_item(itemname, "used", job, wanted_location)
                seen_gear[itemname] = true
            end
        end
        for itemname, bagname in pairs(get_current_inventory(false)) do
            if bagname:find("Wardrobe") or bagname == "Inventory" then
                local shortname = get_short_name(itemname)
                if not seen_gear[itemname] and not seen_gear[shortname]then
                    add_item(itemname, "unused")
                end
            end
        end

        local total = 0

        local f = io.open(path,'w+')
        f:write(player.name ..'_summary={\n')
        for _, bag in ipairs(bags) do
            local items = result[bag.name]
            if items then
                local count = 0
                if table.length(items.used) > 0 then
                    f:write("    -- " .. bag.name .. " (used):\n")
                    for itemname, data in pairs(items.used) do
                        f:write('    ' .. format_line(itemname, data) .. ",\n")
                        count = count + 1
                    end
                end
                if table.length(items.unused) > 0 then
                    f:write("    -- " .. bag.name .. " (unused):\n")
                    for itemname, data in pairs(items.unused) do
                        f:write('    ' .. format_line(itemname, data) .. ",\n")
                        count = count + 1
                    end
                end
                f:write("    -- Count: " .. count .. "\n")
                f:write("\n")
                total = total + count
            end
        end
        if result["Not found"] then
            f:write("    -- Items not found:\n")
            local count = 0
            local items = result["Not found"]
            for itemname, data in pairs(items) do
                f:write('    ' .. format_line(itemname, data) .. ",\n")
                count = count + 1
            end
            count = count + 1
            f:write("    -- Count: " .. count .. "\n")
            total = total + count
        end

        f:write("\n")
        f:write("    -- Total: " .. total .. "\n")
        f:write("\n")

        f:write('}')
        f:close()

        print("Gear summary dumped to file " ..
              path:sub(windower.addon_path:length() + 1))
    end

    local job_bit_values = {}
    local bit_value = 2
    for _, job in ipairs({
        "WAR", "MNK", "WHM", "BLM", "RDM", "THF", "PLD", "DRK", "BST", "BRD",
        "RNG", "SAM", "NIN", "DRG", "SMN", "BLU", "COR", "PUP", "DNC","SCH",
        "GEO", "RUN",
    }) do
        job_bit_values[bit_value] = job
        bit_value = bit_value * 2
    end

    function jobmask_to_jobs(jobmask)
        local result = {}
        -- Start with the bit value for RUN (1 << 22)
        local bit_value = 4194304
        while bit_value >= 2 do
            if jobmask >= bit_value then
                result[job_bit_values[bit_value]] = true
                jobmask = jobmask - bit_value
            end
            bit_value = bit_value / 2
        end

        return result
    end

    function match_jobmask(jobmask, job)
        -- Start with the bit value for RUN (1 << 22)
        local bit_value = 4194304
        while bit_value >= 2 do
            if jobmask >= bit_value then
                if job_bit_values[bit_value] == job then
                    return true
                end
                jobmask = jobmask - bit_value
            end
            bit_value = bit_value / 2
        end

        return false
    end

    function MGInventory.search(args)
        local str = args:concat(" ")
        if str:sub(1, 1) == '"' and str:sub(-1, -1) == '"' then
            str = str:sub(2, -2)
        end
        if str:sub(1, 1) == "'" and str:sub(-1, -1) == "'" then
            str = str:sub(2, -2)
        end
        str = str:lower()

        add_to_chat(207,
            "Searching for string |" .. str .. "| in " ..
            player.main_job .. " items:"
        )

        local results = T{}

        local done = false
        for _, bag in ipairs(bags) do
            for _, item in ipairs(windower.ffxi.get_items(bag.id)) do
                local itemdata = res.items[item.id]
                if itemdata and itemdata.jobs and
                   itemdata.jobs[player.main_job_id] then
                    local result = {
                        bag = bag.name,
                        short_name = itemdata.en,
                        long_name = itemdata.enl,
                        augments = gearswap.get_augment_string(item) or "",
                        desc = "",
                        matched = false,
                        in_augments = false,
                        in_desc = false
                    }
                    if res.item_descriptions[item.id] then
                        result.desc = res.item_descriptions[item.id].en or ""
                    end
                    if result.short_name:lower():find(str) or
                       result.long_name:lower():find(str) then
                        result.matched = true
                    end
                    local in_augments = result.augments:lower():find(str)
                    if in_augments then
                        result.matched = true
                        result.in_augments = in_augments
                    end
                    local in_desc = result.desc:lower():find(str)
                    if in_desc then
                        result.matched = true
                        result.in_desc = in_desc
                    end
                    if result.matched then
                        results:append(result)
                    end
                end
            end
        end
        local last_bag = ""
        for _, result in ipairs(results) do
            if last_bag ~= result.bag then
                add_to_chat(207, "  " .. result.bag)
                last_bag = result.bag
            end
            local output_str = "    " .. result.short_name
            if result.long_name:lower() ~= result.short_name:lower() then
                output_str = output_str .. string.format(
                    " [%s]", result.long_name
                )
            end
            if result.in_augments then
                output_str = output_str .. string.format(
                    ', aug: "%s..."',
                    result.augments:sub(
                        result.in_augments,
                        result.in_augments + str:length() + 10
                    )
                )
            end
            if result.in_desc then
                output_str = output_str .. string.format(
                    ', desc: "%s..."',
                    result.desc:sub(
                        result.in_desc,
                        result.in_desc + str:length() + 10
                    )
                )
            end
            output_str = output_str:gsub("\n", " ")
            add_to_chat(207, output_str)
        end
        add_to_chat(207, results:length() .. " items found")
    end


    local command_handlers = {
        export=function(args) MGInventory.export(sets) end,
        export_reverse=function(args) MGInventory.export_reverse(sets) end,
        summary=function(args) MGInventory.export_summary(sets) end,
        searchinv=function(args) MGInventory.search(args) end
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

    return MGInventory.init()
end)();
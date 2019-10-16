--[[

Description
===========

This library adds some inventory management features for gearswap.
Features:
 - Configure where your gear is supposed to be stored.
 - Items can be both fixed (should never move) and floating (might be moved
   temporarily out of the way).
 - Gear up command makes sure the gear from you gearswap sets are always in
   either wardrobes or main inventory.
 - TODO: Clean up command moves stuff bag to where it is supposed to be.

Installation
============

-- To use the library in a gearswap script place it in your gearswap common
-- folder and add the following at the top of the gearswap file you want to
-- use it in:

local mg_inv = require("mg-inventory");

-- Also add a call to mg_inv.self_command (or mg_inv.job_self_command
-- if using Mote-libs) to your self_command (or job_self_command) method:

-- Example self_command:

function self_command(command)
    if mg_inv.self_command(command) then
        return
    end
    -- Rest of self command method goes here
end

-- Example job_self_command method:

function job_self_command(command, eventArgs)
    if mg_inv.job_self_command(command, eventArgs) then
        return
    end
    -- Rest of self command method goes here
end

-- End of neccessary code changes

Configuration
=============

When the library is loaded it creates a file in
addons/GearSwap/data/<playername/mginv/settings.lua. You edit this file to
specify fixed or floating positions for your gear. The file will contain an
example to work from, or you can copy and paste data from the export commands.

Commands
========

It supports the following commands:

  `//mginv export`
    Exports the gear used in your current sets and where they are stored to the
    <gearswap>/data/<charactername>/mginv/export directory.

  `//mginv export_unused`
    Exports the gear _not_ used in your current sets and where they are stored
    to the <gearswap>/data/<charactername>/mginv/export directory.
    The export_unused command can be good if you want to remove everything
    but gear for a certain job from one of your bag.

  `//mginv summary`
    Makes a summary file with all the items in your inventory and whether they
    are used or not. The resulting file is placed in the
    <gearswap>/data/<charactername>/mginv/export directory.

  `//mginv gearup`
    Make gear for your current job available by putting it in mog wardrobes or
    in the inventory

  `//mginv cleanup`
    Try to move all gear to its configured location.

  `//mginv search <search string>`
    Find items that your current job can equip and where the search string
    matches name, augments or item description. Useful for finding specific
    types of existing gear when building new sets.

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
    local field_bags = {
        ["Inventory"] = true,
        ["Mog Wardrobe"] = true,
        ["Mog Wardrobe 2"] = true,
        ["Mog Wardrobe 3"] = true,
        ["Mog Wardrobe 4"] = true,
    }
    local reverse_field_bags = {
        "Mog Wardrobe 4",
        "Mog Wardrobe 3",
        "Mog Wardrobe 2",
        "Mog Wardrobe",
        "Inventory",
    }

    local default_config_file = [=[-- Config file for mg-invenotry.

    function setup(fixed_position, floating_position)
        --[[

        If you want certain gear to have a fixed position specify that
        position here like this:

            fixed_position["Warp Ring"] = "Mog Wardrobe"

        If you instead want the gear to be floating, eg. placed in a specific
        location by default but allowed to move around, specify it as follows:

            floating_position["Warp Ring"] = "Mog Wardrobe 3"

        If you need to have two of the same item in different wardrobes,
        specify a list of locations instead:

            fixed_position["Varar Ring"] = {"Mog Wardrobe", "Mog Wardrobe 4"}

        --]]

    end

    ]=]
    default_config_file = default_config_file:gsub("\n    ", "\n")

    MGInventory.config = {fixed_position={}, floating_position={}}
    MGInventory.database = {job_usages={}}

    function MGInventory.init()
        local config_file = config_file()
        if not windower.file_exists(config_file) then
            local f = io.open(config_file,'w+')
            f:write(default_config_file)
            f:close()
            print("Config file " ..
                  config_file:sub(windower.addon_path:length() + 1) ..
                  " created. Edit it to set up where you want your gear.")
        end

        -- Create a gitignore file for the database
        local gitignore_file = mginv_dir() .. "/.gitignore"
        if not windower.file_exists(gitignore_file) then
            local f = io.open(gitignore_file,'w+')
            f:write("/database*.lua\n")
            f:write("/export\n")
            f:close()
        end

        MGInventory.load_config()
        coroutine.schedule(update_database, 0.1)

        send_command("alias mginv gs c mginv")

        return MGInventory
    end

    function MGInventory.load_config()
        -- Create new empty config
        config = {fixed_position={}, floating_position={}}

        -- Set up the environement in which the config file will be executed
        local conf_env = { mginv = _G, }
        conf_env['_G'] = conf_env

        -- Load the config file
        local funct, err = gearswap.loadfile(config_file())
        -- Set it to run in the environment above
        gearswap.setfenv(funct, conf_env)
        -- Execute the config file
        funct()
        -- Config methods from the file can now be found in conf_env
        conf_env.setup(config.fixed_position, config.floating_position)
    end
    
    function update_database()
        if not sets then return end
        local database_file = database_file()
        local db
        if windower.file_exists(database_file) then
            db = dofile(database_file)
        else
            db = {job_usages={}}
        end

        for itemname, usages in pairs(db.job_usages) do
            -- Remove existing registration of current job
            if usages and usages[player.main_job] then
                usages[player.main_job] = nil
                -- If this empties the list of using jobs, remove the item
                -- entry as well.
                if table.length(usages) == 0 then
                    db.job_usages[itemname] = nil
                end
            end
        end

        process_items_in_gearsets(sets, function(gs_item)
            local item = item_from_gearswap_data(gs_item)
            if item then
                if not db.job_usages[item.full_desc] then
                    db.job_usages[item.full_desc] = {}
                end
                db.job_usages[item.full_desc][player.main_job] = true
            end
        end)

        local f = io.open(database_file, "w+")
        f:write("return " .. _dump_table(db))
        f:write("\n")
        f:close()

        MGInventory.database = db

        print(string.format(
            "MG-inv database updated, %s items registered",
            table.length(db.job_usages)
        ))
    end
        
    function player_dir()
        local dir =  windower.addon_path .. "data/" .. player.name

        if not windower.dir_exists(dir) then
            windower.create_dir(dir)
        end

        return dir
    end

    function mginv_dir()
        local dir =  player_dir() .. "/mginv"

        if not windower.dir_exists(dir) then
            windower.create_dir(dir)
        end

        return dir
    end

    function export_dir()
        local dir =  mginv_dir() .. "/export"

        if not windower.dir_exists(dir) then
            windower.create_dir(dir)
        end

        return dir
    end

    function config_file()
        return mginv_dir() .. "/settings.lua"
    end

    function database_file()
        return mginv_dir() .. "/database.lua"
    end

    local res_item_name_cache = nil
    function get_res_item_by_name(name)
        if res_item_name_cache == nil then
            res_item_name_cache = {}
            for id, item in pairs(res.items) do
                res_item_name_cache[item.en:lower()] = item
                res_item_name_cache[item.enl:lower()] = item
            end
        end

        return res_item_name_cache[name:lower()]
    end

    function item_from_gearswap_data(gs_item)
        local name = ""
        local augments = nil
        local bag = nil


        if type(gs_item) == "string" then
            name = gs_item
        elseif type(gs_item) == "table" and gs_item.name then
            name = gs_item.name
            augments = gearswap.get_augment_string(gs_item)
            bag = gs_item.bag
        end

        return item_from_name(name, augments, bag)
    end

    function item_from_inventory_data(inv_item, bag)
        local item = make_item(
            inv_item.id, gearswap.get_augment_string(inv_item), bag
        )
        if item then
            item.status = inv_item.status
        end
        return item
    end

    function item_from_name(name, augments, bag)
        local res_item = get_res_item_by_name(name)
        if not res_item then return nil end
        return make_item(res_item.id, augments, bag)
    end

    function make_item(item_id, augment_string, bag)
        local res_item = res.items[item_id]
        if not res_item then
            return nil
        end

        local full_desc = res_item.en
        if augment_string then
            full_desc = full_desc .. "{" ..  augment_string .. "}"
        end

        return T{
            id=item_id,
            res_item=res_item,
            name=res_item.en,
            augments=augment_string,
            bag=bag,
            full_desc=full_desc
        }
    end

    function kv_map(t, callback)
        local out = T{}
        for k, v in pairs(t) do
            out:append(callback(k, v))
        end
        return out
    end

    function _dump_table(t, indent)
        local i1 = indent or ""
        local i2 = i1 .. "  "
        local inner = kv_map(t, function(k, v)
            k = i2 .. '["' .. quotemeta(k) .. '"]'
            if type(v) == "table" then
                return k .. " = " .. _dump_table(v, i2)
            end
            return k .. " = " .. '"' .. quotemeta(tostring(v)) .. '"'
        end):concat(",\n")

        if inner then
            return "{\n" .. inner .. "\n" .. i1 .. "}"
        else
            return "{}"
        end
    end

    function dump_table(t, indent)
        local f = io.open(export_dir() .. "/dump.lua", "w+")
        f:write(_dump_table(t))
        f:close()
        print("Dumped to " .. export_dir() .. "/dump.lua")
    end

    function get_current_inventory()
        --[[
            returns data like:
            {
                items={
                    item1={item=<item>, bags="Inventory"=<item>},
                    item2{item_augments}={
                        item=<item>,
                        bags={
                            "Mog Wardrobe"=true,
                            "Mog Wardrobe 3"=true,
                        }
                    }
                },

            }
        ]]
        local inv = T{
            items=T{},
            by_short_name=T{},
        }

        for _, bag in ipairs(bags) do
            for _, inv_item in ipairs(windower.ffxi.get_items(bag.id)) do
                local item = item_from_inventory_data(inv_item)
                if item ~= nil then
                    if not inv.items[item.full_desc] then
                        inv.items[item.full_desc] = {
                            item=item,
                            bags={}
                        }
                    end
                    inv.items[item.full_desc].bags[bag.name] = true
                    if not inv.by_short_name[item.name] then
                        local existing = inv.items[item.full_desc]
                        inv.by_short_name[item.name] = existing
                    end
                end
            end
        end

        return inv
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

    function MGInventory.export(sets)
        local path = export_dir() ..
                     "/" .. player.name ..
                     "_" .. player.main_job ..
                     "_" .. os.date('%Y-%m-%d_%H%m%S') ..
                     ".lua"
        local inv = get_current_inventory()
        local gear_data = {seen={}}

        process_items_in_gearsets(sets, function(inv_item)
            local item = item_from_gearswap_data(inv_item)
            if not item then
                return
            end
            -- Check if Item has already been processed
            if not gear_data.seen[item.full_desc] then
                gear_data.seen[item.full_desc] = true
            else
                return
            end

            -- Find the bags the item is stored in or set it to be in the
            -- "Not found" bag.
            local bags = (
                inv.items[item.full_desc] or
                inv.by_short_name[item.name] or
                { bags={["Not found"]=true} }
            ).bags
            
            -- Add the item to the right bags in the output
            for bag, _ in pairs(bags) do
                gear_data[bag] = gear_data[bag] or T{}
                gear_data[bag]:append(item.full_desc)
            end
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

    function MGInventory.export_unused(sets)
        local path = export_dir() ..
                     "/" .. player.name ..
                     "_" .. player.main_job ..
                     "_unused_" .. os.date('%Y-%m-%d_%H%m%S') ..
                     ".lua"

        local inv = get_current_inventory()
        process_items_in_gearsets(sets, function(inv_item)
            local item = item_from_gearswap_data(inv_item)
            if not item then
                return
            end
            if item.augments then
                inv.items[item.full_desc] = nil
            else
                local inv_entry = inv.by_short_name[item.name]
                if inv_entry then
                    inv.items[inv_entry.item.full_desc] = nil
                end
            end
        end)

        local gear_data = {}

        for itemname, inv_entry in pairs(inv.items) do
            if inv_entry and inv_entry.bags then
                for bag, _ in pairs(inv_entry.bags) do
                    gear_data[bag] = gear_data[bag] or T{}
                    gear_data[bag]:append(itemname)
                end
            end
        end
        
        local total = 0

        local f = io.open(path,'w+')
        f:write('job_gear_unused["' .. player.main_job .. '"]={\n')
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

        print("Gear currently not used dumped to file " ..
              path:sub(windower.addon_path:length() + 1))
    end

    function MGInventory.export_summary(sets)
        local path = export_dir() ..
                     "/" .. player.name ..
                     "_summary_" .. os.date('%Y-%m-%d_%H%m%S') ..
                     ".lua"
        local result = {}
        local db = MGInventory.database

        local function format_key(item)
            return '["' .. quotemeta(item.full_desc) .. '"]'
        end

        function format_used_by(item)
            local all_usages = {}
            for k in pairs(db.job_usages[item.full_desc] or {}) do
                all_usages[k] = true
            end
            for k in pairs(db.job_usages[item.name] or {}) do
                all_usages[k] = true
            end
            local sorted_jobs = T{}
            for k in pairs(all_usages) do
                table.insert(sorted_jobs, k)
            end
            table.sort(sorted_jobs)
            return string.format(
                "Used by %s jobs: %s",
                sorted_jobs:length(),
                sorted_jobs:concat(", ")
            )
        end

        function format_position(item, default)
            local pos = nil
            if config.fixed_position[item.full_desc] or
               config.fixed_position[item.name] then
                pos = "fixed"
            elseif config.floating_position[item.full_desc] or
               config.floating_position[item.name] then
                pos = "floating"
            else
                pos = default
            end

            return pos .. "_position"
        end
        
        for itemname, inv_entry in pairs(get_current_inventory().items) do
            local item = inv_entry.item
            for bagname in pairs(inv_entry.bags) do
                if bagname:find("Wardrobe") or bagname == "Inventory" then
                    if not result[bagname] then
                        result[bagname] = {used=T{}, unused=T{}}
                    end
                    if db.job_usages[item.full_desc] or
                       db.job_usages[item.name] then
                        result[bagname]["used"]:append(item)
                    else
                        result[bagname]["unused"]:append(item)
                    end
                end
            end
        end

        local total = 0

        local f = io.open(path,'w+')
        f:write('function summary(fixed_position, floating_position)\n')
        for _, bag in ipairs(bags) do
            local items = result[bag.name]
            if items then
                local count = 0
                if table.length(items.used) > 0 then
                    table.sort(items.used, function(a, b)
                        return a.full_desc < b.full_desc
                    end)
                    f:write("    -- " .. bag.name .. " (used):\n")
                    for _, item in ipairs(items.used) do
                        f:write(string.format(
                            '    %s%s = "%s" -- %s\n',
                            format_position(item, "fixed"),
                            format_key(item),
                            bag.name,
                            format_used_by(item)
                        ))
                        count = count + 1
                    end
                end
                if table.length(items.unused) > 0 then
                    table.sort(items.unused, function(a, b)
                        return a.full_desc < b.full_desc
                    end)
                    f:write("    -- " .. bag.name .. " (unused):\n")
                    for _, item in ipairs(items.unused) do
                        f:write(string.format(
                            '    %s%s = "%s" -- Not used\n',
                            format_position(item, "floating"),
                            format_key(item),
                            bag.name
                        ))
                        count = count + 1
                    end
                end
                f:write("    -- Count: " .. count .. "\n")
                f:write("\n")
                total = total + count
            end
        end

        f:write("\n")
        f:write("    -- Total: " .. total .. "\n")
        f:write("\n")

        f:write('end\n')
        f:close()

        print("Gear summary dumped to file " ..
              path:sub(windower.addon_path:length() + 1))
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


    function say(message)
        return add_to_chat(207, message)
    end

    function get_item_move_type(item, bag_name, locked_map)
        -- Locked items should not be moved
        if item_is_locked(item, bag_name, locked_map) then return nil end

        -- Item with statuses cannot be moved
        if item.status and item.status > 0 then return nil end

        -- Furniture cannot be move since we are not sure if it is locked
        if item.res_item.type and item.res_item.type == 10 then return nil end

        -- Floating position items are floating
        if config.floating_position[item.full_desc] or
            config.floating_position[item.name] then
            return "floating"
        end
        -- The rest of items can be moved if they are not fixed
        if not config.fixed_position[item.name] and
            not config.fixed_position[item.full_desc] then
            return "moving"
        end

        return nil
    end

    function build_bag_data(bag_id, bag_name, locked_map)
        local bag_info = windower.ffxi.get_items(bag_id)
        if not bag_info.enabled then return nil end

        -- bag_info.count is broken, so we count ourselves
        local count = 0
        for i, v in ipairs(bag_info) do
            if v and v.id and v.id > 0 then
                count = count + 1
            end
        end
        local bag_data = {
            id=bag_id,
            name=bag_name,
            free_slots=bag_info.max - count,
            moving_items = T{},
            floating_items = T{},
            pending_adds=0,
            pending_removes=0,
            freeable_slots=0,
        }
        for _, bag_item in ipairs(bag_info) do
            if bag_item then
                local item = item_from_inventory_data(bag_item)
                if item then
                    local move_type = get_item_move_type(
                        item, bag_name, locked_map
                    )
                    if move_type then
                        if item.res_item.slots then
                            item.is_gear = true
                        end
                        item.res_item = nil
                        bag_data[move_type .. "_items"]:append(item)
                    end
                end
            end
        end

        -- Never move unknown stuff from inventory. It might have gotten
        -- there without the players knowledge and they might lose track of
        -- it if we move it around.
        if bag_data.name == "Inventory" then
            bag_data.moving_items = T{}
        end

        bag_data.freeable_slots = bag_data.moving_items:length() +
                                  bag_data.floating_items:length()

        return bag_data
    end

    function build_move(item, from_bag, to_bag)
        if not item then
            say(string.format(
                'Item "%s" not defined when building move from %s to %s',
                tostring(item),
                from_bag,
                to_bag
            ))
            return nil
        end
        local move = {item=item, from=from_bag, to=to_bag}
        if from_bag == "Inventory" or to_bag == "Inventory" then
            move.operations = 1
        else
            move.operations = 2
        end
        return move
    end

    function find_destination_bag(bag_status, item)
        -- Loop over default bag order so we put stuff in storage before using
        -- field bags.
        for i, bag in ipairs(bags) do
            local bag_data = bag_status[bag.name]
            if (
                -- Only look in bags that are enabled
                bag_data and
                -- We are not moving stuff to the inventory by default
                bag.name ~= "Inventory" and
                -- Non-field bags can contain anything, but we have to check
                -- if the item is a gear item before trying to move it to
                -- a field bag.
                (
                    not field_bags[bag.name] or
                    item.is_gear
                ) and
                -- Check if there is room
                bag_data.free_slots > 0
            ) then
                return bag.name
            end
        end
        return nil
    end

    function find_field_bag(bag_status, item)
        -- Loop over default bag order so we put stuff in storage before using
        -- field bags.
        for _, bagname in ipairs(reverse_field_bags) do
            local bag_data = bag_status[bagname]
            if (
                -- Only look in bags that are enabled
                bag_data and
                item.is_gear and
                -- Check if there is room
                (
                    bag_data.free_slots > 0 or
                    bag_data.freeable_slots > 0
                )
            ) then
                return bagname
            end
        end
        return nil
    end

    function resolve_moves(unresolved_moves, locked_map)
        -- List of current bags, their free slots and lists of floating
        -- and moving items
        local bag_status = T{}

        -- The unresolved moves we want to perform
        unresolved_moves = unresolved_moves or T{}
        -- Gear that is already in place and should not be moved
        locked_map = locked_map or T{}

        -- Bags that can be used to store away items
        local store_bags = T{}
        -- Bags that can be used to access items in the field
        local equip_bags = T{}

        -- Temporary moves that are performed to start the process, which
        -- needs to be backtraced in the end
        local temp_moves = T{}

        -- The plan for what we are going to do
        local plan = T{}

        -- Build the starting status for bags
        for _, bag in ipairs(bags) do
            local bag_data = build_bag_data(bag.id, bag.name, locked_map)
            if bag_data then
                bag_status[bag.name] = bag_data
                if field_bags[bag.name] then
                    equip_bags:append(bag_data)
                else
                    store_bags:append(bag_data)
                end
            end
        end

        if not bag_status["Inventory"] or
            not (bag_status["Inventory"].free_slots > 0) then
            say("Cannot move any items, no space left in inventory")
            return
        end

        -- Look at the pending moves and figure out how much we will add or
        -- free in each bag. Also checks if the bags we need are actually
        -- available.
        for _, move in ipairs(unresolved_moves) do
            local from_bag = bag_status[move.from]
            local to_bag = bag_status[move.to]
            if not from_bag then
                say("Cannot move item " .. move.item.full_desc ..
                    " from bag " .. move.from ..
                    " because that bag is not available.")
                return
            end
            if not to_bag then
                say("Cannot move item " .. move.item.full_desc ..
                    " to bag " .. move.to ..
                    " because that bag is not available.")
                return
            end
            from_bag.pending_removes = from_bag.pending_removes + 1
            to_bag.pending_adds = to_bag.pending_adds + 1
        end

        -- Calculate free space and freable slots in all bags. Bail out if
        -- we find out we cannot make enough room in a certain bag.
        for bagname, bag_data in pairs(bag_status) do
            bag_data.free_slots = (
                bag_data.free_slots - bag_data.pending_adds +
                bag_data.pending_removes
            )
            bag_data.freeable_slots = (
                bag_data.moving_items:length() +
                bag_data.floating_items:length()
            )
            if (bag_data.free_slots + bag_data.freeable_slots) < 0 then
                say("Cannot perform the wanted moves, not able to make room" ..
                    " in bag " .. bagname .. ".")
                return
            end
        end
        
        -- Plan moves needed to free up spaces in bags
        for bagname, bag_data in pairs(bag_status) do
            local missing_slots = 0 - bag_data.free_slots
            while missing_slots > 0 do
                local item = table.remove(bag_data.floating_items) or
                             table.remove(bag_data.moving_items)
                -- This should not happen due to the check above, but making
                -- sure anyways.
                if not item then
                    say("Ran out of movable items while making room in " ..
                        bagname)
                    return
                end
                local dest_bag = find_destination_bag(bag_status, item)
                if not dest_bag then
                    say("Failed to move items: No possible destinations " ..
                        "when trying to free up space in " .. bagname .. ".")
                    return
                end

                local move = build_move(item, bagname, dest_bag)
                say("Moving " .. item.full_desc .. " from " ..
                    bagname .. " to " .. dest_bag .. " to make room")
                table.insert(unresolved_moves, move)
                missing_slots = missing_slots - 1
            end
        end
        
        -- Sum up the number of operations we need to
        local sum_operations = 0
        for _, move in ipairs(unresolved_moves) do
            sum_operations = sum_operations + move.operations
        end
        local time_in_seconds = math.ceil(sum_operations * 0.85)
        local minutes = math.floor(time_in_seconds / 60)
        local seconds = time_in_seconds - (60 * minutes)
        say(string.format(
            "Resolved moves: %s items to move using %s move operations.",
            table.length(unresolved_moves),
            sum_operations
        ))
        say(string.format(
            "Estimated ETA: %s minute(s) and %s second(s).",
            minutes,
            seconds
        ))

        unresolved_moves = table.reverse(unresolved_moves)

        return moves_to_operations(
            unresolved_moves, bag_status["Inventory"].free_slots
        )
    end

    function moves_to_operations(unresolved_moves, free_inventory_slots)
        local operations = T{}
        local moves_last_round = 1
        free_inventory_slots = free_inventory_slots or 0

        if free_inventory_slots == 0 then
            say("Cannot convert moves to operations: No free inventory slots.")
            return
        end

        while(moves_last_round > 0 and unresolved_moves:length() > 0) do
            moves_last_round = 0
            -- Look for first part of multistep moves where we have to move
            -- stuff to inventory
            for i, move in ipairs(unresolved_moves) do
                if move.operations == 2 and free_inventory_slots > 0 then
                    operations:append({
                        item=move.item,
                        from=move.from,
                        to="Inventory"
                    })
                    move.operations = move.operations - 1
                    move.from = "Inventory"
                    moves_last_round = moves_last_round + 1
                    free_inventory_slots = free_inventory_slots - 1
                end
            end
            -- Look for stuff we can move from inventory
            for i, move in ipairs(unresolved_moves) do
                if (move.operations > 0 and move.from == "Inventory") then
                    operations:append({
                        item=move.item,
                        from=move.from,
                        to=move.to
                    })
                    move.operations = move.operations - 1
                    free_inventory_slots = free_inventory_slots + 1
                    moves_last_round = moves_last_round + 1
                end
            end
            -- Filter out moves that have finised all operations
            local next_unresolved = T{}
            for i, move in ipairs(unresolved_moves) do
                if move.operations > 0 then
                    next_unresolved:append(move)
                end
            end
            unresolved_moves = next_unresolved
        end

        -- Clean up any remaining moves. This should only be moves into the
        -- inventory
        if unresolved_moves:length() > 0 then
            for i, move in ipairs(unresolved_moves) do
                if move.operations > 1 then
                    say("Move with too many operations in last resolve " ..
                        "stage")
                    return
                end
                operations:append({
                    item=move.item,
                    from=move.from,
                    to=move.to,
                })
                if move.to == "Inventory" then
                    free_inventory_slots = free_inventory_slots - 1
                    if free_inventory_slots < 0 then
                        say("Ran out of inventory while building " ..
                            "operations")
                        return
                    end
                end
            end
        end
                
        --for _, move in ipairs(operations) do
        --    say("Pending operation: " .. move.item.full_desc .. " from " ..
        --        move.from .. " to " .. move.to)
        --end
    
        return operations
    end

    function perform_operations(operations)
        local last_operation = nil
        -- It is faster to pop instead of shifting the operations
        local operations = table.reverse(operations)
        
        local bag_to_id = T{}
        for _, bag in ipairs(bags) do
            bag_to_id[bag.name] = bag.id
        end

        function find_item_in_bag(bagname, item)
            local bag_data = windower.ffxi.get_items(bag_to_id[bagname])
            
            for _, v in ipairs(bag_data) do
                if v and v.id == item.id then
                    local inv_item = item_from_inventory_data(v)
                    if inv_item and inv_item.full_desc == item.full_desc then
                        return v
                    end
                end
            end
        end

        function verify_last()
            if last_operation == nil then return true end

            local inv_data = find_item_in_bag(
                last_operation.to, last_operation.item
            )

            if inv_data then
                last_operation = nil
                return true
            else
                say(string.format(
                    "Item %s was not found in %s.",
                    last_operation.item.full_desc, last_operation.to
                ))
                --last_operation = nil
                return false
            end
        end

        function execute_operation(op)
            if last_operation then
                say("Trying to execute an operations while another is active")
                return false
            end

            local from_id = bag_to_id[op.from]
            local to_id = bag_to_id[op.to]
            
            -- Find source info
            local inv_data = find_item_in_bag(op.from, op.item)
            if not inv_data then
                say(string.format(
                    "Could not find item %s to move from %s.",
                    op.item.full_desc, op.from
                ))
                return false
            end

            if inv_data.status and inv_data.status > 0 then
                say(string.format(
                    "Trying to move item with status: %s in %s",
                    op.item.full_desc, op.from
                ))
                return false
            end

            if op.to == "Inventory" then
                --say(string.format("%s Inv move: %s from %s to %s", os.clock(), op.item.full_desc, from_id, op.to))
                windower.ffxi.get_item(
                    from_id, inv_data.slot, inv_data.count
                )
            else
                --say(string.format("%s Bag move: %s from %s to %s", os.clock(), op.item.full_desc, op.from, op.to))
                windower.ffxi.put_item(
                    to_id, inv_data.slot, inv_data.count
                )
            end
            last_operation = op

            return true
        end

        function process()
            if not verify_last() then return end
            local next_op = table.remove(operations)
            if next_op then
                say(string.format(
                    'Moving %s from %s to %s',
                    next_op.item.full_desc,
                    next_op.from,
                    next_op.to
                ))
                if execute_operation(next_op) then
                    coroutine.schedule(process, 0.8)
                end
            else
                say("Done: No more operations to process")
            end
        end

        process()
    end
    
    function make_sources_available(needed_sources, locked_map)
        local bag_status = T{}
        for _, bag in ipairs(bags) do
            if field_bags[bag.name] then
                local bag_data = build_bag_data(bag.id, bag.name, locked_map)
                bag_status[bag.name] = bag_data
            end
        end

        local needed_moves = T{}

        for _, src in ipairs(needed_sources) do
            local dest_bag_name = find_field_bag(
                bag_status, src.item, locked_map
            )
            if dest_bag_name then
                local dest_bag = bag_status[dest_bag_name]
                needed_moves:append(
                    build_move(src.item, src.from, dest_bag_name)
                )
                if dest_bag.free_slots > 0 then
                    dest_bag.free_slots = dest_bag.free_slots - 1
                elseif dest_bag.freeable_slots > 0 then
                    dest_bag.freeable_slots = dest_bag.freeable_slots - 1
                end
            else
                say(string.format(
                    "Cannot find a field bag to put %s in.",
                    src.item.full_desc
                ))
                return
            end
        end

        local operations = resolve_moves(needed_moves, locked_map)
        if operations then
            perform_operations(operations)
        end
    end

    function gear_up()
        local inv = get_current_inventory()
        local needed_sources = T{}
        local locked_map = T{}
        local seen_items = T{}

        process_items_in_gearsets(sets, function(gs_item)
            local item = item_from_gearswap_data(gs_item)
            if not item then return end
            if seen_items[item.full_desc] then
                return
            else
                seen_items[item.full_desc] = true
            end
            local inv_data = inv.items[item.full_desc] or
                             inv.by_short_name[item.full_desc]
            if not inv_data then return end

            if item.res_item.slots then
                item.is_gear = true
            end

            local available_in_field = false
            local source_bag
            for v in pairs(inv_data.bags) do
                if item.bag then
                    if item.bag == v then
                        available_in_field = true
                        add_item_to_locked_map(item, v, locked_map)
                    else
                        source_bag = v
                    end
                else
                    if field_bags[v] then
                        available_in_field = true
                        add_item_to_locked_map(item, v, locked_map)
                    else
                        source_bag = v
                    end
                end
            end
            if not available_in_field then
                needed_sources:append(T{item=item, from=source_bag})
            end
        end)

        make_sources_available(needed_sources, locked_map)
    end


    function add_item_to_locked_map(item, bag_name, locked_map)
        local key = item.full_desc .. ":" .. bag_name
        locked_map[key] = bag_name
    end

    function item_is_locked(item, bag_name, locked_map)
        local key = item.full_desc .. ":" .. bag_name
        return locked_map[key]
    end

    function get_position_info(iteminfo)
        local result = {}
        result.needed_moves = T{}
        result.correct_position = T{}

        -- Bail out if item is nowhere
        if not iteminfo.bags then
            return result
        end

        local item = iteminfo.item
        -- Find the wanted position
        local position = config.fixed_position[item.full_desc] or
                         config.fixed_position[item.name] or
                         config.floating_position[item.full_desc] or
                         config.floating_position[item.name]

        -- If there is not wanted position, bail out
        if not position then
            return result
        end

        -- Build a list of where this/these item(s) are supposed to be
        local needed_positions = {}
        if type(position) == "string" then
            needed_positions[position] = true
        else
            for i, pos in ipairs(position) do
                needed_positions[pos] = true
            end
        end

        -- Find out which items are wrongly placed
        local wrongly_placed = T{}
        for pos, _ in pairs(iteminfo.bags) do
            if needed_positions[pos] then
                needed_positions[pos] = false
                add_item_to_locked_map(item, pos, result.correct_position)
                -- print(item.full_desc .. " is correctly placed in " .. pos)
            else
                wrongly_placed:append(pos)
                -- print(item.full_desc .. " is wrongly placed in " .. pos)
            end
        end

        for dest, needed in pairs(needed_positions) do
            if needed then
                local src = wrongly_placed:remove()
                if src then
                    result.needed_moves:append(build_move(item, src, dest))
                end
            end
        end

        return result
    end

    function cleanup()
        local inv = get_current_inventory()
        local moves = T{}
        local locked_map = T{}

        for name, iteminfo in pairs(inv.items) do
            local pos_info = get_position_info(iteminfo)
            moves:extend(pos_info.needed_moves)
            for k, v in pairs(pos_info.correct_position) do
                locked_map[k] = v
            end
        end

        local operations = resolve_moves(moves, locked_map)
        if operations then
            perform_operations(operations)
        end
    end


    function test()
        local ops = resolve_moves(
            T{
                build_move(item_from_name("Brewer's Shield"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Alchemist's Belt"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Alchemist's Smock"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Alchemst. Torque"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Craftkeeper's Ring"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Craftmaster's Ring"),
                           "Mog Wardrobe 4", "Mog Safe"),
                build_move(item_from_name("Caduceus"),
                           "Mog Wardrobe 4", "Mog Safe"),

                --build_move(item_from_name("Brewer's Shield"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Alchemist's Belt"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Alchemist's Smock"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Alchemst. Torque"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Craftkeeper's Ring"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Craftmaster's Ring"),
                --           "Mog Safe", "Mog Wardrobe 4"),
                --build_move(item_from_name("Caduceus"),
                --           "Mog Safe", "Mog Wardrobe 4"),

                --build_move(item_from_name("B. Bamboo Grass"),
                --           "Mog Safe 2", "Mog Safe"),
            },
            T{["Windurstian Flag"]=true}
        )
        if ops then perform_operations(ops) end
        --print(_dump_table(windower.ffxi.get_items().safe[73]))
    end

    local command_handlers = {
        export=function(args) MGInventory.export(sets) end,
        export_unused=function(args) MGInventory.export_unused(sets) end,
        summary=function(args) MGInventory.export_summary(sets) end,
        searchinv=function(args) MGInventory.search(args) end,
        gearup=function(args) gear_up() end,
        cleanup=function(args) cleanup() end,
        test=function(args) test() end,
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
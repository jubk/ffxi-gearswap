local sets = {}

return {
    make_set = function(name, modes)
        local current_index = 1

        local data = {value=modes[current_index]}

        data.cycle = function()
            current_index = current_index + 1;
            if current_index > #modes then
                current_index = 1
            end
            data.value = modes[current_index]
            add_to_chat(128, name .. " cycled to " .. data.value)
        end

        data.switch_to = function(new_mode)
            for i, v in ipairs(modes) do
                if v == new_mode then
                    current_index = i
                    data.value = v
                    add_to_chat(128, name .. " set to " .. data.value)
                    return
                end
            end
            add_to_chat(
                128,
                "Mode " .. new_mode .. " not found for " .. name .. "!"
            )
        end

        sets[name:lower()] = data

        return data
    end,

    self_command = function(command)
        if string.sub(command, 1, 5) == "mode " then
            command = string.sub(command, 6)
        else
            return false
        end

        local name, value = command:match('(.+)%s+(.*)')
        local set = sets[name:lower()]

        if set == nil then
            add_to_chat(128, "Modeset with name " .. name .. " not found!")
            return true
        end

        if value == nil or value == "" or value == "cycle" then
            set.cycle()
        else
            set.switch_to(value)
        end

        return true
    end,

    get_mode = function(name)
        local set = sets[name:lower()]

        if set == nil then
            add_to_chat(128, "Modeset with name " .. name .. " not found!")
            return nil
        end

        return set.value
    end
}

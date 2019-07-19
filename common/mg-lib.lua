local MG = {}

MG.hub = (function()
    local hub = {}

    local default_settings = {
        -- position
        pos_x = 1510,
        pos_y = 250,
        -- padding
        padding = 10,
    }

    local current_settings = {}
    local output = nil

    function rebuild_settings(settings)
        local settings = settings or {}
        current_settings = {}
        for k, v in pairs(default_settings) do
            value = v
            if value == nil then
                value = default_settings[k]
            end
            current_settings[k] = value
        end
    end

    function rebuild_output()
        local s = current_settings
        local settings = {
            pos={x=s.pos_x, y=s.pos_y},
            padding=s.padding,
        }

        if not (output == nil) then
            texts.destroy(output)
        end
        output = texts.new('', settings)
        output:append(build_template())
        output:show()
    end

    function build_template()
        return "Hello World!\\cr"
    end

    function hub:initialize(settings)
        rebuild_settings(settings)
        rebuild_output()
    end

    return hub
end)()

return MG
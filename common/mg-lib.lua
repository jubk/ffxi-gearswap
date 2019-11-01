local MG = {}

MG.hud = (function()
    local hud = {}

    local default_settings = {
        -- position
        pos_x = 1510,
        pos_y = 250,

        -- padding
        padding = 10,

        -- Color as {red, green, blue, alpha}, numbers from 0 to 255
        bg_color = {60, 60, 60, 200},

        -- font
        font = 'Impact',
        font_size = 10,
        font_color = {255, 255, 255, 255},
        text_stroke = 0,
        text_stroke_color = {0, 0, 0, 255},

        keybind_color = {128, 128, 128},
        value_color = {125,125,255},

        visible = true,
        draggable = true,
    }

    local elements = T{}
    local output = nil

    hud.settings = {}
    hud.hud_settings = {}

    function color(rgb)
        if type(rgb) == "table" and table.length(rgb) == 3 then
            return string.format(' \\cs(%d, %d, %d)', unpack(rgb))
        end
        return nil
    end

    function rebuild_settings(settings)
        local settings = settings or {}
        local new = {}
        for k, default_value in pairs(default_settings) do
            local value = settings[k]
            if value == nil then
                value = default_value
            end
            new[k] = value
        end

        new.default_color_text = color(
            {new.font_color[1], new.font_color[2], new.font_color[3]}
        )
        new.keybind_color_text = color(new.keybind_color) or ""
        new.value_color_text = color(new.value_color) or ""

        hud.settings = new

        settings_to_hud_settings()
    end

    function settings_to_hud_settings()
        local s = hud.settings

        local hud_settings = {}
        hud_settings.pos = {}
        hud_settings.pos.x = s.pos_x
        hud_settings.pos.y = s.pos_y
        hud_settings.bg = {}
        hud_settings.bg.alpha = s.bg_color[4]
        hud_settings.bg.red = s.bg_color[1]
        hud_settings.bg.green = s.bg_color[2]
        hud_settings.bg.blue = s.bg_color[3]
        hud_settings.bg.visible = s.visible
        hud_settings.flags = {}
        hud_settings.flags.right = false
        hud_settings.flags.bottom = false
        hud_settings.flags.bold = false
        hud_settings.flags.draggable = s.draggable
        hud_settings.flags.italic = false
        hud_settings.padding = s.padding
        hud_settings.text = {}
        hud_settings.text.size = s.font_size
        hud_settings.text.font = s.font
        hud_settings.text.fonts = {}
        hud_settings.text.alpha = s.font_color[4]
        hud_settings.text.red = s.font_color[1]
        hud_settings.text.green = s.font_color[2]
        hud_settings.text.blue = s.font_color[3]
        hud_settings.text.stroke = {}
        hud_settings.text.stroke.width = 0
        hud_settings.text.stroke.alpha = 255
        hud_settings.text.stroke.red = 0
        hud_settings.text.stroke.green = 0
        hud_settings.text.stroke.blue = 0

        hud.hud_settings = hud_settings
    end

    function rebuild_output()
        if not (output == nil) then
            texts.destroy(output)
        end
        local template = build_template()
        if template and template ~= '' then
            output = texts.new(template, hud.hud_settings)
            output:show()
        end
    end

    function build_template()
        local template = ''
        for i, elem in pairs(elements) do
            template = template .. elem:get_template() .. '\\cr\n'
        end
        return template
    end

    function hud:update_context()
        if output == nil then
            return
        end
        local context = {}
        for i, elem in pairs(elements) do
            local elem_context = elem:get_context()
            for k, v in pairs(elem_context) do
                context[k] = v
            end
        end
        output:update(context)
    end

    function hud:initialize(settings)
        rebuild_settings(settings)
        rebuild_output()
    end

    function hud:add_mote_mode(mote_mode, options)
        elements:append(MG.MoteWrapper(hud, mote_mode, options))
        rebuild_output()
        hud:update_context()
    end

    function tick()
        hud:update_context()
    end

    -- Tick every time the ingame time changes
    windower.register_event('time change', tick)
    
    return hud
end)()

MG.MoteWrapper = (function()
    local _meta = {}
    local _prototype = {}
    local idx = 1

    _meta.__class = 'motewrapper'
    _meta.__index = _prototype

    local function MoteWrapper(hud, mote_mode, options)
        local self = {}
        options = options or {}
        self.hud = hud
        self.mode = mote_mode
        self.wrapper_index = idx
        self.keybind_text = options.keybind_text

        idx = idx + 1

        -- Wrap methods to trigger hud update
        local mote_metatable = getmetatable(mote_mode)
        for i, methodname in ipairs({
            'describe', 'options', 'cycle', 'cycleback', 'toggle', 'set',
            'unset', 'reset'
        }) do
            mote_mode[methodname] = function(m, ...)
                mote_metatable.__methods[methodname](m, unpack(arg))
                hud:update_context()
                if options.callback then
                    options.callback()
                end
                local equip_table = options.autoequip_table
                if equip_table and equip_table[m.current] then
                    MG.force_equip_set(equip_table[m.current])
                end
            end
        end

        if options.keybind then
            local binding = MG.InputHandler.bind(
                options.keybind,
                function(mods)
                    if mods.shift then
                        self.mode:cycleback()
                    else
                        self.mode:cycle()
                    end
                end
            )
            if not self.keybind_text and binding then
                self.keybind_text = "[" .. binding.description .. "] "
            end
        end

        return setmetatable(self, _meta)
    end

    _meta.__tostring = function(self)
        return "MoteWrapper for " .. tostring(self.mode)
    end
    
    _prototype.get_template = function(self)
        local template = T{}
        if self.keybind_text and self.keybind_text ~= "" then
            template:append(self.hud.settings.keybind_color_text)
            template:append(self.keybind_text)
            template:append(self.hud.settings.default_color_text)
        end

        template:append(self.mode.description)
        template:append(": ")

        template:append(self.hud.settings.value_color_text)
        template:append(string.format(
            '${mote_wrapper_%d_value|}',
            self.wrapper_index
        ))
        template:append(self.hud.settings.default_color_text)

        return template:concat("")
    end

    _prototype.get_context = function(self, context)
        local context = {}

        local key = string.format('mote_wrapper_%d_value', self.wrapper_index)
        context[key] = self.mode.current

        return context
    end

    return MoteWrapper
end)()

MG.InputHandler = (function()
    local text_to_dik = {
        ["`"] =	"DIK_GRAVE",
        ["escape"] = "DIK_ESCAPE",
        ["1"] = "DIK_1",
        ["2"] = "DIK_2",
        ["3"] = "DIK_3",
        ["4"] = "DIK_4",
        ["5"] = "DIK_5",
        ["6"] = "DIK_6",
        ["7"] = "DIK_7",
        ["8"] = "DIK_8",
        ["9"] = "DIK_9",
        ["0"] = "DIK_0",
        ["-"] = "DIK_MINUS",
        ["="] = "DIK_EQUALS",
        ["backspace"] = "DIK_BACK",
        ["tab"] = "DIK_TAB",
        ["q"] = "DIK_Q",
        ["w"] = "DIK_W",
        ["e"] = "DIK_E",
        ["r"] = "DIK_R",
        ["t"] = "DIK_T",
        ["y"] = "DIK_Y",
        ["u"] = "DIK_U",
        ["i"] = "DIK_I",
        ["o"] = "DIK_O",
        ["p"] = "DIK_P",
        ["["] = "DIK_LBRACKET",
        ["]"] = "DIK_RBRACKET",
        ["enter"] = "DIK_RETURN",
        ["return"] = "DIK_RETURN",
        ["ctrl"] = "DIK_LCONTROL",
        ["lctrl"] = "DIK_LCONTROL",
        ["a"] = "DIK_A",
        ["s"] = "DIK_S",
        ["d"] = "DIK_D",
        ["f"] = "DIK_F",
        ["g"] = "DIK_G",
        ["h"] = "DIK_H",
        ["j"] = "DIK_J",
        ["k"] = "DIK_K",
        ["l"] = "DIK_L",
        [";"] = "DIK_SEMICOLON",
        ["’"] = "DIK_APOSTROPHE",
        ["shift"] = "DIK_LSHIFT",
        ["lshift"] = "DIK_LSHIFT",
        ["\\"] = "DIK_BACKSLASH",
        ["z"] = "DIK_Z",
        ["x"] = "DIK_X",
        ["c"] = "DIK_C",
        ["v"] = "DIK_V",
        ["b"] = "DIK_B",
        ["n"] = "DIK_N",
        ["m"] = "DIK_M",
        [","] = "DIK_COMMA",
        ["."] = "DIK_PERIOD",
        ["/"] = "DIK_SLASH",
        ["rshift"] = "DIK_RSHIFT",
        ["numpad*"] = "DIK_MULTIPLY",
        ["alt"] = "DIK_LMENU",
        ["lalt"] = "DIK_LMENU",
        ["space"] = "DIK_SPACE",
        ["capslock"] = "DIK_CAPITAL",
        ["f1"] = "DIK_F1",
        ["f2"] = "DIK_F2",
        ["f3"] = "DIK_F3",
        ["f4"] = "DIK_F4",
        ["f5"] = "DIK_F5",
        ["f6"] = "DIK_F6",
        ["f7"] = "DIK_F7",
        ["f8"] = "DIK_F8",
        ["f9"] = "DIK_F9",
        ["f10"] = "DIK_F10",
        ["numlock"] = "DIK_NUMLOCK",
        ["scrolllock"] = "DIK_SCROLL",
        ["numpad7"] = "DIK_NUMPAD7",
        ["numpad8"] = "DIK_NUMPAD8",
        ["numpad9"] = "DIK_NUMPAD9",
        ["numpad-"] = "DIK_SUBTRACT",
        ["numpad4"] = "DIK_NUMPAD4",
        ["numpad5"] = "DIK_NUMPAD5",
        ["numpad6"] = "DIK_NUMPAD6",
        ["numpad+"] = "DIK_ADD",
        ["numpad1"] = "DIK_NUMPAD1",
        ["numpad2"] = "DIK_NUMPAD2",
        ["numpad3"] = "DIK_NUMPAD3",
        ["numpad0"] = "DIK_NUMPAD0",
        ["numpad."] = "DIK_DECIMAL",
        ["f11"] = "DIK_F11",
        ["f12"] = "DIK_F12",
        ["kana"] = "DIK_KANA",
        ["convert"] = "DIK_CONVERT",
        ["noconvert"] = "DIK_NOCONVERT",
        ["yen"] = "DIK_YEN",
        ["kanji"] = "DIK_KANJI",
        ["numpadenter"] = "DIK_NUMPADENTER",
        ["rctrl"] = "DIK_RCONTROL",
        ["sysrq"] = "DIK_SYSRQ",
        ["ralt"] = "DIK_RMENU",
        ["pause"] = "DIK_PAUSE",
        ["home"] = "DIK_HOME",
        ["up"] = "DIK_UP",
        ["pageup"] = "DIK_PRIOR",
        ["left"] = "DIK_LEFT",
        ["right"] = "DIK_RIGHT",
        ["end"] = "DIK_END",
        ["down"] = "DIK_DOWN",
        ["pagedown"] = "DIK_NEXT",
        ["insert"] = "DIK_INSERT",
        ["delete"] = "DIK_DELETE",
        ["windows"] = "DIK_LWIN",
        ["lwindows"] = "DIK_LWIN",
        ["rwindows"] = "DIK_RWIN",
        ["apps"] = "DIK_APPS",
        ["mail"] = "DIK_MAIL",
        ["mmselect"] = "DIK_MEDIASELECT",
        ["mmstop"] = "DIK_MEDIASTOP",
        ["mute"] = "DIK_MUTE",
        ["mycomputer"] = "DIK_MYCOMPUTER",
        ["mmnext"] = "DIK_NEXT",
        ["mmnexttrack"] = "DIK_NEXTTRACK",
        ["mmplaypause"] = "DIK_PLAYPAUSE",
        ["power"] = "DIK_POWER",
        ["mmprevtrack"] = "DIK_PREVTRACK",
        ["mmstop"] = "DIK_STOP",
        ["mmvolup"] = "DIK_VOLUMEDOWN",
        ["mmvoldown"] = "DIK_VOLUMEUP",
        ["webback"] = "DIK_WEBBACK",
        ["webfav"] = "DIK_WEBFAVORITES",
        ["webforward"] = "DIK_WEBFORWARD",
        ["webhome"] = "DIK_WEBHOME",
        ["webrefresh"] = "DIK_WEBREFRESH",
        ["websearch"] = "DIK_WEBSEARCH",
        ["webstop"] = "DIK_WEBSTOP",
    }
    local dik_to_keycodes = {
        ["DIK_ESCAPE"]          = 0x01,
        ["DIK_1"]               = 0x02,
        ["DIK_2"]               = 0x03,
        ["DIK_3"]               = 0x04,
        ["DIK_4"]               = 0x05,
        ["DIK_5"]               = 0x06,
        ["DIK_6"]               = 0x07,
        ["DIK_7"]               = 0x08,
        ["DIK_8"]               = 0x09,
        ["DIK_9"]               = 0x0A,
        ["DIK_0"]               = 0x0B,
        ["DIK_MINUS"]           = 0x0C,    --/* - on main keyboard */
        ["DIK_EQUALS"]          = 0x0D,
        ["DIK_BACK"]            = 0x0E,    --/* backspace */
        ["DIK_TAB"]             = 0x0F,
        ["DIK_Q"]               = 0x10,
        ["DIK_W"]               = 0x11,
        ["DIK_E"]               = 0x12,
        ["DIK_R"]               = 0x13,
        ["DIK_T"]               = 0x14,
        ["DIK_Y"]               = 0x15,
        ["DIK_U"]               = 0x16,
        ["DIK_I"]               = 0x17,
        ["DIK_O"]               = 0x18,
        ["DIK_P"]               = 0x19,
        ["DIK_LBRACKET"]        = 0x1A,
        ["DIK_RBRACKET"]        = 0x1B,
        ["DIK_RETURN"]          = 0x1C,    --/* Enter on main keyboard */
        ["DIK_LCONTROL"]        = 0x1D,
        ["DIK_A"]               = 0x1E,
        ["DIK_S"]               = 0x1F,
        ["DIK_D"]               = 0x20,
        ["DIK_F"]               = 0x21,
        ["DIK_G"]               = 0x22,
        ["DIK_H"]               = 0x23,
        ["DIK_J"]               = 0x24,
        ["DIK_K"]               = 0x25,
        ["DIK_L"]               = 0x26,
        ["DIK_SEMICOLON"]       = 0x27,
        ["DIK_APOSTROPHE"]      = 0x28,
        ["DIK_GRAVE"]           = 0x29,    --/* accent grave */
        ["DIK_LSHIFT"]          = 0x2A,
        ["DIK_BACKSLASH"]       = 0x2B,
        ["DIK_Z"]               = 0x2C,
        ["DIK_X"]               = 0x2D,
        ["DIK_C"]               = 0x2E,
        ["DIK_V"]               = 0x2F,
        ["DIK_B"]               = 0x30,
        ["DIK_N"]               = 0x31,
        ["DIK_M"]               = 0x32,
        ["DIK_COMMA"]           = 0x33,
        ["DIK_PERIOD"]          = 0x34,    --/* . on main keyboard */
        ["DIK_SLASH"]           = 0x35,    --/* / on main keyboard */
        ["DIK_RSHIFT"]          = 0x36,
        ["DIK_MULTIPLY"]        = 0x37,    --/* * on numeric keypad */
        ["DIK_LMENU"]           = 0x38,    --/* left Alt */
        ["DIK_SPACE"]           = 0x39,
        ["DIK_CAPITAL"]         = 0x3A,
        ["DIK_F1"]              = 0x3B,
        ["DIK_F2"]              = 0x3C,
        ["DIK_F3"]              = 0x3D,
        ["DIK_F4"]              = 0x3E,
        ["DIK_F5"]              = 0x3F,
        ["DIK_F6"]              = 0x40,
        ["DIK_F7"]              = 0x41,
        ["DIK_F8"]              = 0x42,
        ["DIK_F9"]              = 0x43,
        ["DIK_F10"]             = 0x44,
        ["DIK_NUMLOCK"]         = 0x45,
        ["DIK_SCROLL"]          = 0x46,    --/* Scroll Lock */
        ["DIK_NUMPAD7"]         = 0x47,
        ["DIK_NUMPAD8"]         = 0x48,
        ["DIK_NUMPAD9"]         = 0x49,
        ["DIK_SUBTRACT"]        = 0x4A,    --/* - on numeric keypad */
        ["DIK_NUMPAD4"]         = 0x4B,
        ["DIK_NUMPAD5"]         = 0x4C,
        ["DIK_NUMPAD6"]         = 0x4D,
        ["DIK_ADD"]             = 0x4E,    --/* + on numeric keypad */
        ["DIK_NUMPAD1"]         = 0x4F,
        ["DIK_NUMPAD2"]         = 0x50,
        ["DIK_NUMPAD3"]         = 0x51,
        ["DIK_NUMPAD0"]         = 0x52,
        ["DIK_DECIMAL"]         = 0x53,    --/* . on numeric keypad */
        ["DIK_OEM_102"]         = 0x56,    --/* < > | on UK/Germany keyboards */
        ["DIK_F11"]             = 0x57,
        ["DIK_F12"]             = 0x58,
        ["DIK_F13"]             = 0x64,    --/*                     (NEC PC98) */
        ["DIK_F14"]             = 0x65,    --/*                     (NEC PC98) */
        ["DIK_F15"]             = 0x66,    --/*                     (NEC PC98) */
        ["DIK_KANA"]            = 0x70,    --/* (Japanese keyboard)            */
        ["DIK_ABNT_C1"]         = 0x73,    --/* / ? on Portugese (Brazilian) keyboards */
        ["DIK_CONVERT"]         = 0x79,    --/* (Japanese keyboard)            */
        ["DIK_NOCONVERT"]       = 0x7B,    --/* (Japanese keyboard)            */
        ["DIK_YEN"]             = 0x7D,    --/* (Japanese keyboard)            */
        ["DIK_ABNT_C2"]         = 0x7E,    --/* Numpad . on Portugese (Brazilian) keyboards */
        ["DIK_NUMPADEQUALS"]    = 0x8D,    --/* = on numeric keypad (NEC PC98) */
        ["DIK_PREVTRACK"]       = 0x90,    --/* Previous Track (DIK_CIRCUMFLEX on Japanese keyboard) */
        ["DIK_AT"]              = 0x91,    --/*                     (NEC PC98) */
        ["DIK_COLON"]           = 0x92,    --/*                     (NEC PC98) */
        ["DIK_UNDERLINE"]       = 0x93,    --/*                     (NEC PC98) */
        ["DIK_KANJI"]           = 0x94,    --/* (Japanese keyboard)            */
        ["DIK_STOP"]            = 0x95,    --/*                     (NEC PC98) */
        ["DIK_AX"]              = 0x96,    --/*                     (Japan AX) */
        ["DIK_UNLABELED"]       = 0x97,    --/*                        (J3100) */
        ["DIK_NEXTTRACK"]       = 0x99,    --/* Next Track */
        ["DIK_NUMPADENTER"]     = 0x9C,    --/* Enter on numeric keypad */
        ["DIK_RCONTROL"]        = 0x9D,
        ["DIK_MUTE"]            = 0xA0,    --/* Mute */
        ["DIK_CALCULATOR"]      = 0xA1,    --/* Calculator */
        ["DIK_PLAYPAUSE"]       = 0xA2,    --/* Play / Pause */
        ["DIK_MEDIASTOP"]       = 0xA4,    --/* Media Stop */
        ["DIK_VOLUMEDOWN"]      = 0xAE,    --/* Volume - */
        ["DIK_VOLUMEUP"]        = 0xB0,    --/* Volume + */
        ["DIK_WEBHOME"]         = 0xB2,    --/* Web home */
        ["DIK_NUMPADCOMMA"]     = 0xB3,    --/* , on numeric keypad (NEC PC98) */
        ["DIK_DIVIDE"]          = 0xB5,    --/* / on numeric keypad */
        ["DIK_SYSRQ"]           = 0xB7,
        ["DIK_RMENU"]           = 0xB8,    --/* right Alt */
        ["DIK_PAUSE"]           = 0xC5,    --/* Pause */
        ["DIK_HOME"]            = 0xC7,    --/* Home on arrow keypad */
        ["DIK_UP"]              = 0xC8,    --/* UpArrow on arrow keypad */
        ["DIK_PRIOR"]           = 0xC9,    --/* PgUp on arrow keypad */
        ["DIK_LEFT"]            = 0xCB,    --/* LeftArrow on arrow keypad */
        ["DIK_RIGHT"]           = 0xCD,    --/* RightArrow on arrow keypad */
        ["DIK_END"]             = 0xCF,    --/* End on arrow keypad */
        ["DIK_DOWN"]            = 0xD0,    --/* DownArrow on arrow keypad */
        ["DIK_NEXT"]            = 0xD1,    --/* PgDn on arrow keypad */
        ["DIK_INSERT"]          = 0xD2,    --/* Insert on arrow keypad */
        ["DIK_DELETE"]          = 0xD3,    --/* Delete on arrow keypad */
        ["DIK_LWIN"]            = 0xDB,    --/* Left Windows key */
        ["DIK_RWIN"]            = 0xDC,    --/* Right Windows key */
        ["DIK_APPS"]            = 0xDD,    --/* AppMenu key */
        ["DIK_POWER"]           = 0xDE,    --/* System Power */
        ["DIK_SLEEP"]           = 0xDF,    --/* System Sleep */
        ["DIK_WAKE"]            = 0xE3,    --/* System Wake */
        ["DIK_WEBSEARCH"]       = 0xE5,    --/* Web Search */
        ["DIK_WEBFAVORITES"]    = 0xE6,    --/* Web Favorites */
        ["DIK_WEBREFRESH"]      = 0xE7,    --/* Web Refresh */
        ["DIK_WEBSTOP"]         = 0xE8,    --/* Web Stop */
        ["DIK_WEBFORWARD"]      = 0xE9,    --/* Web Forward */
        ["DIK_WEBBACK"]         = 0xEA,    --/* Web Back */
        ["DIK_MYCOMPUTER"]      = 0xEB,    --/* My Computer */
        ["DIK_MAIL"]            = 0xEC,    --/* Mail */
        ["DIK_MEDIASELECT"]     = 0xED,    --/* Media Select */
        
    }

    -- /* Alternate names for keys, to facilitate transition from DOS. */
    dik_to_keycodes["DIK_BACKSPACE"]      = dik_to_keycodes["DIK_BACK"]      --/* backspace */
    dik_to_keycodes["DIK_NUMPADSTAR"]     = dik_to_keycodes["DIK_MULTIPLY"]  --/* * on numeric keypad */
    dik_to_keycodes["DIK_LALT"]           = dik_to_keycodes["DIK_LMENU"]     --/* left Alt */
    dik_to_keycodes["DIK_CAPSLOCK"]       = dik_to_keycodes["DIK_CAPITAL"]   --/* CapsLock */
    dik_to_keycodes["DIK_NUMPADMINUS"]    = dik_to_keycodes["DIK_SUBTRACT"]  --/* - on numeric keypad */
    dik_to_keycodes["DIK_NUMPADPLUS"]     = dik_to_keycodes["DIK_ADD"]       --/* + on numeric keypad */
    dik_to_keycodes["DIK_NUMPADPERIOD"]   = dik_to_keycodes["DIK_DECIMAL"]   --/* . on numeric keypad */
    dik_to_keycodes["DIK_NUMPADSLASH"]    = dik_to_keycodes["DIK_DIVIDE"]    --/* / on numeric keypad */
    dik_to_keycodes["DIK_RALT"]           = dik_to_keycodes["DIK_RMENU"]     --/* right Alt */
    dik_to_keycodes["DIK_UPARROW"]        = dik_to_keycodes["DIK_UP"]        --/* UpArrow on arrow keypad */
    dik_to_keycodes["DIK_PGUP"]           = dik_to_keycodes["DIK_PRIOR"]     --/* PgUp on arrow keypad */
    dik_to_keycodes["DIK_LEFTARROW"]      = dik_to_keycodes["DIK_LEFT"]      --/* LeftArrow on arrow keypad */
    dik_to_keycodes["DIK_RIGHTARROW"]     = dik_to_keycodes["DIK_RIGHT"]     --/* RightArrow on arrow keypad */
    dik_to_keycodes["DIK_DOWNARROW"]      = dik_to_keycodes["DIK_DOWN"]      --/* DownArrow on arrow keypad */
    dik_to_keycodes["DIK_PGDN"]           = dik_to_keycodes["DIK_NEXT"]      --/* PgDn on arrow keypad */

    -- /* Alternate names for keys originally not used on US keyboards. */
    dik_to_keycodes["DIK_CIRCUMFLEX"]     = dik_to_keycodes["DIK_PREVTRACK"] --/* Japanese keyboard */

    local by_dik = {}
    local by_keycode = {}
    local by_text = {}
    local state = {}

    for k, v in pairs(text_to_dik) do
        local item = {
            text=k,
            dik=v,
            keycode=dik_to_keycodes[v],
        }
        by_dik[item.dik] = item
        by_keycode[item.keycode] = item
        by_text[item.text] = item
        state[item.keycode] = false
    end

    local modifier_map = {
        ["^"] = "control",
        ["!"] = "alt",
        ["@"] = "win",
        ["#"] = "apps",
        ["ctrl"] = "control",
        ["control"] = "control",
        ["alt"] = "alt",
        ["win"] = "win",
        ["windows"] = "win",
        ["apps"] = "apps",
    }

    function to_bindcode(keybind)
        local result = ''
        if keybind.control then result = result .. '^' end
        if keybind.alt then result = result .. '!' end
        if keybind.win then result = result .. '@' end
        if keybind.apps then result = result .. '#' end
        result = result .. keybind.button.text
        return result
    end

    function to_description(keybind)
        local result = ''
        if keybind.control then result = result .. 'Ctrl-' end
        if keybind.alt then result = result .. 'Alt-' end
        if keybind.win then result = result .. 'Win-' end
        if keybind.apps then result = result .. 'Apps-' end
        result = result .. keybind.button.text:sub(1, 1):upper() ..
                           keybind.button.text:sub(2)
        return result
    end

    function parse(text)
        local result = T{
            button=nil,
            control=false,
            alt=false,
            win=false,
            apps=false
        }
        local continue = true
        text = text:lower()
        while continue do
            local mod_match = text:match('^([!@#^])') or
                              text:match('^(ctrl)') or
                              text:match('^(control)') or
                              text:match('^(alt)') or
                              text:match('^(win)') or
                              text:match('^(windows)') or
                              text:match('^(apps)')

            if mod_match then
                local mod_name = modifier_map[mod_match]
                result[mod_name] = true
                text = text:sub(mod_match:len() + 1)
                if text:match('^-') then
                    text = text:sub(2)
                end
            else
                continue = false
            end
        end

        local button = by_text[text] or by_dik[text] or by_keycode[text]
        if button then
            result.button = button
        else
            return nil
        end

        result.bindcode = to_bindcode(result)
        result.description = to_description(result)

        return result
    end

    function match_modifiers(a, b)
        if a.control ~= b.control then return false end
        if a.alt ~= b.alt then return false end
        if a.win ~= b.win then return false end
        if a.apps ~= b.apps then return false end
        return true
    end

    local bindings = T{}
    
    local InputHandler = {}

    function InputHandler.bind(binding_definition, callback)
        local listener = parse(binding_definition)
        if not listener then
            return
        end
        listener.callback = callback or function() end
        InputHandler.unbind(binding_definition)
        -- Unbind any windower binding to the same key combination
        send_command("unbind " .. listener.bindcode)
        
        if not bindings[listener.button.keycode] then
            bindings[listener.button.keycode] = T{}
        end

        bindings[listener.button.keycode]:append(listener)

        return listener
    end

    function InputHandler.unbind(binding_definition)
        local listener = parse(binding_definition)
        if not listener then
            return
        end
        if not bindings[listener.button.keycode] then
            return
        end
        for i, handler in ipairs(bindings[listener.button.keycode]) do
            if(match_modifiers(listener, handler)) then
                table.remove(bindings[listener.button.keycode], i)
                return
            end
        end
    end

    local keyboard_flags = T{
        -- {flag = 0x20, modifier = "console is open"},
        {flag = 0x10, modifier = "apps"},
        {flag = 0x8,  modifier = "win"},
        {flag = 0x4,  modifier = "control"},
        {flag = 0x2,  modifier = "alt"},
        {flag = 0x1,  modifier = "shift"},
    }

    windower.register_event('keyboard', function(dik, pressed, flags, blocked)
        -- do nothing while console window is open
        if flags >= 0x20 then
            return
        end

        -- We only care if stuff changed
        if state[dik] == nil or state[dik] == pressed then
            return
        else
            -- update to current state
            state[dik] = pressed
        end

        -- Only care for listeners
        local listeners = bindings[dik]
        if not listeners then
            return
        end
        
        
        if pressed then
            -- Parse flags into a liste of modifier booleans
            local modifiers = T{}
            local test_flag = 0x10

            for i, flag in ipairs(keyboard_flags) do
                if flags >= flag.flag then
                    flags = flags - flag.flag
                    modifiers[flag.modifier] = true
                else
                    modifiers[flag.modifier] = false
                end
            end

            -- Call the callback on any listerner that matches the modifiers
            for i, listener in ipairs(listeners) do
                if match_modifiers(listener, modifiers) then
                    listener.callback(modifiers)
                end
            end
        end
    end)
    
    return InputHandler
end)()

MG.force_equip_set = function(set)
    gearswap.equip_sets(
        'equip_command',
        nil,
        set
    )
end

return MG
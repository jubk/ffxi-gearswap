--[[
    System for automatic execution of Immanence skillchains.

    To use include the following in your gearswap file:

        -- Top of file
        local AutoImmanence = require("AutoImmanence")

        function get_sets()
            ...
            auto_sc = AutoImmanence()
            ..
        end

        function precast(spell)
            ...
            auto_sc.precast(spell)
            ...
        end

        function midcast(spell)
            ...
            auto_sc.midcast(spell)
            ...
        end

        function aftercast(spell)
            ...
            auto_sc.aftercast(spell)
            ...
        end

        function self_command(command)
            if auto_sc.self_command(command) then
                return
            end
            ...
        end

        function filtered_action(spell)
            ...
            auto_sc.filtered_action(spell) then
            ...
        end

    To activate a skillchain do:

        //gs c sc scission
        //gs c sc fusion

    Or use the created alias

        //sc transfixion
        //sc gravitation

    Or you can use the name of the element you want to burst for single-
    element WSes:

        //sc water
        //sc darkness

]]

local AutoImmanence = function(options)
    local TRANSLATIONS = {
        fire="\253\2\2\27R\253",
        stone="\253\2\2\27X\253",
        water="\253\2\2\30\205\253",
        aero="\253\2\2\27T\253",
        blizzard="\253\2\2\27S\253",
        thunder="\253\2\2\27V\253",
        light="\253\2\2\30K\253",
        darkness="\253\2\2\30\202\253",
        detonation="\253\2\2\30\200\253",
        compression="\253\2\2\30\194\253",
        transfixion="\253\2\2\30\198\253",
        reverberation="\253\2\2\30\197\253",
        induration="\253\2\2\30\196\253",
        impaction="\253\2\2\30\201\253",
        liquefaction="\253\2\2\30\195\253",
        scission="\253\2\2\30\199\253",
        gravitation="\253\2\2\30\190\253",
        fusion="\253\2\2\30\193\253",
        distortion="\253\2\2\30\192\253",
        fragmentation="\253\2\2\30\191\253",
        scholar="\253\2\2\16\20\253",
        skillchain="\253\2\2\8-\253",
        magic="\253\2\2\8#\253",
        burst="\253\2\2\27W\253",
    }

    local options = options or {}
    local command_alias = options['command_alias'] or 'sc'

    local t = function(msg)
        if msg then
            return TRANSLATIONS[msg:lower()] or msg
        else
            return msg
        end
    end

    local DEFAULT_DELAY = 4
    local DELAY_OVERRIDES = {
        Luminohelix=7,
        Noctohelix=7,
    }

    local SECOND_SPELL_DELAY_ADJUSTMENT = -2

    local JA_WAIT_DELAY = 1

    local BLOCKING_DEBUFFS = {
        'Paralyze',
        'Stun',
        'Silence'
    }

    -- Number of seconds after a finished skillchain where nukes should be
    -- cast in MagicBurst gear.
    local MAX_SC_WINDOW = 8
    local last_skillchain_finished = 0

    local public = {
        -- Translations
        TRANSLATIONS=TRANSLATIONS,
        translate=t,
        active_skillchain=nil
    }

    function Step(name, perform_method)
        local name=name
        return {
            name=name,
            perform=perform_method
        }
    end

    local CAST_FIRST_SPELL = function(spell)
        local casting_delay = DELAY_OVERRIDES[spell] or DEFAULT_DELAY
        local function perform_method(step, skillchain)
            if skillchain.check_interrupt() then
                return
            end
            local expected = {}
            expected[spell] = true
            
            -- Default wait time is the casting delay of the spell
            skillchain.reset_delay()
            skillchain.add_delay(casting_delay)

            local msg = t(skillchain.name) .. " skillchain start: >> "
            if skillchain.burst_elements[2] then
                msg = msg .. t(skillchain.burst_elements[1]) .. " / "  ..
                      t(skillchain.burst_elements[2])
            else
                msg = msg .. t(skillchain.burst_elements[1])
            end
            msg = msg .. " <<"

            local cmd = "input /party " .. msg .. "; "

            -- If immanence is not up, enable it
            if not buffactive['Immanence'] then
                cmd = cmd ..
                      "input /ja Immanence <me>; " ..
                      "pause " .. JA_WAIT_DELAY .. "; "

                -- Add an extra second of delay
                skillchain.add_delay(1)
                expected['Immanence'] = true
            end

            cmd = cmd .. "input /ma '" .. spell .. "'"

            skillchain.set_expected(expected)

            send_command(cmd)

            skillchain.next_step()
            return true
        end
    
        return Step("Cast " .. spell, perform_method)
    end

    local WAIT_FOR_NEXT_STEP = function(name)
        local perform_method = function(step, skillchain)
            local function wait_coroutine()
                -- Check if all expected actions have been done
                local expected = skillchain.get_expected()
                for k, v in pairs(expected) do
                    if v ~= "done" then
                        skillchain.abort(
                            "Expected action " .. k .. " not done in time"
                        )
                    end
                end

                if skillchain.aborted() then
                    return
                end

                skillchain.next_step()
            end
            coroutine.schedule(wait_coroutine, skillchain.get_delay())
        end
        
        return Step(name, perform_method)
    end

    local CAST_SECOND_SPELL = function(spell)
        local casting_delay = DELAY_OVERRIDES[spell] or DEFAULT_DELAY
        local function perform_method(step, skillchain)
            if skillchain.check_interrupt() then
                return
            end

            local expected = {}
            expected[spell] = true

            -- Default wait time is the casting delay of the spell
            skillchain.reset_delay()
            -- Do the end message a bit before the spell has actually been cast
            skillchain.add_delay(
                casting_delay + SECOND_SPELL_DELAY_ADJUSTMENT
            )

            local cmd = "input /ma '" .. spell .. "'"

            -- If immanence is not up, enable it
            if not buffactive['Immanence'] then
                cmd = "input /ja Immanence <me>; " ..
                      "pause " .. JA_WAIT_DELAY .. "; " ..
                      cmd
                -- Add an extra second of delay
                skillchain.add_delay(1)
                expected['Immanence'] = true
            end

            skillchain.set_expected(expected)

            send_command(cmd)

            skillchain.next_step()
        end

        return Step("Cast " .. spell, perform_method)
    end

    local FINISH = function()
        local perform_method = function(step, skillchain)
            local msg = t(skillchain.name) .. " skillchain end: >> "
            if skillchain.burst_elements[2] then
                msg = msg .. t(skillchain.burst_elements[1]) .. " / " ..
                      t(skillchain.burst_elements[2])
            else
                msg = msg .. t(skillchain.burst_elements[1])
            end
            msg = msg .. " <<"
            send_command('input /party ' .. msg)

            skillchain.mark_finished()
            skillchain.perform_additional_steps()
        end

        return Step("Finishing skillchain", perform_method)
    end

    local function Skillchain(name, steps, burst_elements)
        local self = {}

        self.name = name
        self.burst_elements = burst_elements

        -- data
        local steps = steps

        -- state
        local step_idx = 0

        local finished = 0
        self.finished=function() return finished end
        self.mark_finished=function() finished = os.clock() end

        local aborted = false
        self.aborted=function() return aborted end

        local delay = 0
        self.get_delay=function() return delay end
        self.add_delay=function(v) delay = delay + v end
        self.reset_delay=function() delay = 0 end


        local options = {}
        self.set_options=function(v) options = v end

        local expected = {}
        self.get_expected=function() return expected end
        self.set_expected=function(v) expected = v end

        self.reset = function()
            delay = 0
            step_idx = 0
            finished = 0
            aborted = false
            expected = {}
            options = {}
        end

        self.next_step = function()
            if self.aborted() then
                return
            end
            step_idx = step_idx + 1
            new_step = steps[step_idx]
            if new_step == nil then
                self.abort("Trying to progres to non-existant next step")
            end
            new_step.perform(new_step, self)
        end

        self.start = function(options)
            self.reset()
            self.set_options(options)
            self.next_step()
        end

        self.abort = function(reason)
            -- Do not abort more than once
            if self.aborted() or self.finished() then
                return
            end
            aborted = true
            add_to_chat(128, name .. " skillchain aborted due to: " .. reason)
            send_command("input /party Skillchain aborted >_<")
        end

        self.perform_additional_steps = function()
            local extra_steps = {}
            local cmd = nil
            local ja_extra_delay = 2
            if options['ebullience'] then
                cmd = 'pause ' .. ja_extra_delay
                table.insert(
                    extra_steps,
                    'input /ja Ebullience <me>'
                )
            end
            if options['alacrity'] then
                cmd = 'pause ' .. ja_extra_delay
                table.insert(
                    extra_steps,
                    'input /ja Alacrity <me>'
                )
            end
            if options['nuke'] then
                table.insert(
                    extra_steps,
                    "input /ma '" .. options['nuke'] .. "' <t>"
                )
            end
            for k, v in ipairs(extra_steps) do
                if cmd == nil then
                    cmd = v
                else
                    cmd = cmd .. "; pause 1; " .. v
                end
            end
            if cmd ~= nil then
                send_command(cmd)
            end
        end

        self.check_interrupt = function(spell)
            if spell and not expected[spell.english] then
                self.abort("Unexpected spell/ja '" .. spell.english .. "'")
                return true
            end
            for k, v in ipairs(BLOCKING_DEBUFFS) do
                if buffactive[v] then
                    self.abort("Blocked by debuff '" .. v .. "'")
                    return true
                end
            end
            return false
        end
        
        self.mark_done = function(spell)
            local existing = expected[spell.english]
            if existing ~= true then
                self.abort(
                    "Trying to mark " .. spell.english .. " done, " ..
                    "but its value is " .. (existing or "<nil>")
                )
            end
            expected[spell.english] = "done"
        end

        self.name = name

        return self
    end

    local MAKE_SC = function(name, spell1, spell2, ...)
        return Skillchain(
            name,
            {
                CAST_FIRST_SPELL(spell1),
                WAIT_FOR_NEXT_STEP("Waiting for second step"),
                CAST_SECOND_SPELL(spell2),
                WAIT_FOR_NEXT_STEP("Waiting for finish message"),
                FINISH()
            },
            arg
        )
    end

    local SKILLCHAINS = {
        scission=MAKE_SC("Scission", "Aero", "Stone", "Stone"),
        detonation=MAKE_SC("Detonation", "Stone", "Aero", "Aero"),
        reverberation=MAKE_SC("Reverberation", "Stone", "Water", "Water"),
        induration=MAKE_SC("Induration", "Water", "Blizzard", "Blizzard"),
        impaction=MAKE_SC("Impaction", "Water", "Thunder", "Thunder"),
        liquefaction=MAKE_SC("Liquefaction", "Stone", "Fire", "Fire"),
        fusion=MAKE_SC('Fusion', 'Fire', 'Thunder', "Fire", "Light"),
        fragmentation=MAKE_SC(
            'Fragmentation', 'Blizzard', 'Water', "Aero", "Thunder"
        ),
        distortion=MAKE_SC(
            'Distortion', 'Luminohelix', 'Stone', "Water", "Blizzard"
        ),
        gravitation=MAKE_SC(
            'Gravitation', 'Aero', 'Noctohelix', "Stone", "Darkness"
        ),
        compression=MAKE_SC(
            "Compression", "Blizzard", "Noctohelix", "Darkness"
        ),
        transfixion=MAKE_SC(
            "Transfixion", "Noctohelix", "Luminohelix", "Light"
        ),
        -- Version two of the skillchains all use helix as second spell
        -- which allows for longer MB window
        scission_helix=MAKE_SC("Scission", "Aero", "Geohelix", "Stone"),
        detonation_helix=MAKE_SC("Detonation", "Stone", "Anemohelix", "Aero"),
        reverberation_helix=MAKE_SC("Reverberation", "Stone", "Hydrohelix", "Water"),
        induration_helix=MAKE_SC("Induration", "Water", "Cryohelix", "Blizzard"),
        impaction_helix=MAKE_SC("Impaction", "Water", "Ionohelix", "Thunder"),
        liquefaction_helix=MAKE_SC("Liquefaction", "Stone", "Pyrohelix", "Fire"),
        fusion_helix=MAKE_SC('Fusion', 'Fire', 'Ionohelix', "Fire", "Light"),
        fragmentation_helix=MAKE_SC(
            'Fragmentation', 'Blizzard', 'Hydrohelix', "Aero", "Thunder"
        ),
        distortion_helix=MAKE_SC(
            'Distortion', 'Luminohelix', 'Geohelix', "Water", "Blizzard"
        ),

    }
    -- Skillchains that already end with helix
    SKILLCHAINS["gravitation_helix"]=SKILLCHAINS["gravitation"]
    SKILLCHAINS["compression_helix"]=SKILLCHAINS["compression"]
    SKILLCHAINS["transfixion_helix"]=SKILLCHAINS["transfixion"]

    -- Easier-to-remember aliases
    SKILLCHAINS["stone"]=SKILLCHAINS["scission"]
    SKILLCHAINS["aero"]=SKILLCHAINS["detonation"]
    SKILLCHAINS["wind"]=SKILLCHAINS["detonation"]
    SKILLCHAINS["darkness"]=SKILLCHAINS["compression"]
    SKILLCHAINS["light"]=SKILLCHAINS["transfixion"]
    SKILLCHAINS["water"]=SKILLCHAINS["reverberation"]
    SKILLCHAINS["blizzard"]=SKILLCHAINS["induration"]
    SKILLCHAINS["ice"]=SKILLCHAINS["induration"]
    SKILLCHAINS["thunder"]=SKILLCHAINS["impaction"]
    SKILLCHAINS["fire"]=SKILLCHAINS["liquefaction"]

    SKILLCHAINS["stone_helix"]=SKILLCHAINS["scission_helix"]
    SKILLCHAINS["aero_helix"]=SKILLCHAINS["detonation_helix"]
    SKILLCHAINS["wind_helix"]=SKILLCHAINS["detonation_helix"]
    SKILLCHAINS["darkness_helix"]=SKILLCHAINS["compression_helix"]
    SKILLCHAINS["light_helix"]=SKILLCHAINS["transfixion_helix"]
    SKILLCHAINS["water_helix"]=SKILLCHAINS["reverberation_helix"]
    SKILLCHAINS["blizzard_helix"]=SKILLCHAINS["induration_helix"]
    SKILLCHAINS["ice_helix"]=SKILLCHAINS["induration_helix"]
    SKILLCHAINS["thunder_helix"]=SKILLCHAINS["impaction_helix"]
    SKILLCHAINS["fire_helix"]=SKILLCHAINS["liquefaction_helix"]

    local gearswap_handler = function(spell)
        if public.active_skillchain then
            return public.active_skillchain.check_interrupt(spell)
        end
        return false
    end

    public.precast = gearswap_handler
    public.midcast = gearswap_handler
    public.aftercast = function(spell)
        if public.active_skillchain then
            public.active_skillchain.mark_done(spell)
        end
    end

    public.filtered_action = function(spell)
        local sc = public.active_skillchain
        if sc and not sc.finished() then
            sc.abort(spell.name ' got filtered action')
        end
    end

    public.start_skillchain = function(sc, opts)
        local other_sc = public.active_skillchain
        if other_sc and not other_sc.finished() then
            return public.active_skillchain.abort(
                "Already have active skillchain, aborting it"
            )
        end

        -- Enable dark arts if it is not up
        if not (buffactive["Dark Arts"] or buffactive["Addendum: Black"]) then
            local recasts = windower.ffxi.get_ability_recasts()
            if (recasts[232] or 0) > 0 then
                return public.abort("Dark Arts not ready")
            end

            expected_next = "Dark Arts"
            send_command('input /ja "Dark Arts" <me>')
            add_to_chat(128, "Dark Arts not up, enabling it")
            return
        end

        sc.reset()
        sc.start(opts)
        public.active_skillchain = sc
    end

    public.start_skillchain_by_name = function(name, opts)
        local sc = SKILLCHAINS[name:lower()]
        if sc then
            public.start_skillchain(sc, opts)
        else
            add_to_chat(128, "No such skillchian '" .. name .. '"')
        end
    end

    public.self_command = function(command, eventArgs)
        local action, args_str
        -- Mote sends us a table with arguments, so we need to handle that
        if type(command) == "table" then
            action = command[1] or ""
            args_str = command[2] or ""
            idx = 3
            while command[idx] do
                args_str = args_str .. " " .. command[idx]
                idx = idx + 1
            end
        else
            action, args_str = command:match('(%a+)%s*(.*)')
        end
        if action == "sc" then
            if args_str == "" then
                add_to_chat(
                    128,
                    "You must specify a name of the skillchain you want to use"
                )
                return true
            end
            if args_str == "abort" then
                if public.active_skillchain then
                    public.active_skillchain.abort("Aborted by user")
                end
                return
            end
            local element, two, rest = args_str:match('(%a+)%s*(2?)%s*(.*)')
            local opts = {}
            if rest:find('[+]') then
                opts['ebullience'] = true
            end
            if rest:find('[+][+]') then
                opts['alacrity'] = true
            end
            opts['nuke'] = rest:match('%s*([%d%a%s]+)')

            if two and two ~= "" then
                element = element .. "_helix"
            end

            auto_sc.start_skillchain_by_name(element, opts)
        end
    end

    if not alias_initialized then
        send_command("alias " .. command_alias .. " gs c sc")
        alias_initialized = true
    end

    public.in_mb_window = function(spell)
        if not public.active_skillchain then
            return false
        end

        local last_finish = public.active_skillchain.finished()
        local since_skillchain = os.clock() - last_finish

        return since_skillchain <= MAX_SC_WINDOW
    end

    return public
end

return AutoImmanence;
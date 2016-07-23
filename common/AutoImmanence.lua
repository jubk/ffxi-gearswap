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

local t = function(msg)
    if msg then
        return TRANSLATIONS[msg:lower()] or msg
    else
        return msg
    end
end

local ANNOUNCE_START = { method='announce_start' }
local ANNOUNCE_END = { method='announce_end' }
local USE_IMMANENCE = {
    method='use_immanence',
    needs_forced_delay=true,
    advance_delay=1,
}
local CAST_SPELL = function(spellname)
    return {
        method='cast_spell',
        spell=spellname,
        needs_forced_delay=true,
        advance_delay=2,
    }
end
local FINISH = { method='finish' }
local STANDARD_PROGRAM = function(spell1, spell2)
    return {
        ANNOUNCE_START,
        USE_IMMANENCE,
        CAST_SPELL(spell1),
        USE_IMMANENCE,
        CAST_SPELL(spell2),
        ANNOUNCE_END,
        FINISH
    }
end
local SINGLE_ELEMENT_SC = function(name, spell1, spell2, burst)
    return {
        name=t(name),
        burst_elements={t(burst or spell2),},
        program=STANDARD_PROGRAM(spell1, spell2),
    }
end

local SKILLCHAINS = {
    distortion={
        name=t('Distortion'),
        burst_elements={t("Water"), t("Blizzard")},
        program = STANDARD_PROGRAM('Luminohelix', 'Stone')
    },
    fragmentation={
        name=t('Fragmentation'),
        burst_elements={t("Aero"), t("Thunder")},
        program = STANDARD_PROGRAM('Blizzard', 'Water')
    },
    fusion={
        name=t('Fusion'),
        burst_elements={t("Fire"), t("Light")},
        program = STANDARD_PROGRAM('Fire', 'Thunder')
    },
    gravitation={
        name=t('Gravitation'),
        burst_elements={t("Stone"), t("Darkness")},
        program = STANDARD_PROGRAM('Aero', 'Noctohelix')
    },
    scission=SINGLE_ELEMENT_SC("Scission", "Aero", "Stone"),
    detonation=SINGLE_ELEMENT_SC("Detonation", "Stone", "Aero"),
    compression=SINGLE_ELEMENT_SC(
        "Compression", "Blizzard", "Noctohelix", "Darkness"
    ),
    transfixion=SINGLE_ELEMENT_SC(
        "Transfixion", "Noctohelix", "Luminohelix", "Light"
    ),
    reverberation=SINGLE_ELEMENT_SC("Reverberation", "Stone", "Water"),
    induration=SINGLE_ELEMENT_SC("Induration", "Water", "Blizzard"),
    impaction=SINGLE_ELEMENT_SC("Impaction", "Water", "Thunder"),
    liquefaction=SINGLE_ELEMENT_SC("Liquefaction", "Stone", "Fire"),
}
SKILLCHAINS["stone"]=SKILLCHAINS["scission"]
SKILLCHAINS["aero"]=SKILLCHAINS["detonation"]
SKILLCHAINS["darkness"]=SKILLCHAINS["compression"]
SKILLCHAINS["light"]=SKILLCHAINS["transfixion"]
SKILLCHAINS["water"]=SKILLCHAINS["reverberation"]
SKILLCHAINS["blizzard"]=SKILLCHAINS["induration"]
SKILLCHAINS["thunder"]=SKILLCHAINS["impaction"]
SKILLCHAINS["fire"]=SKILLCHAINS["liquefaction"]

local alias_initialized = false


local AutoImmanence = function()

    local index = -1
    local skillchain = nil
    local expected_next = ''
    local cc = nil
    local advance_delay = 0
    local currently_delayed = 0
    local spell_count = 0
    local injected_command = nil

    local public = {
        -- Translations
        TRANSLATIONS=TRANSLATIONS,
        translate=t,

        -- Program-building methods
        STANDARD_PROGRAM=STANDARD_PROGRAM,
        SINGLE_ELEMENT_SC=SINGLE_ELEMENT_SC,

        -- Action-building methods
        ANNOUNCE_START=ANNOUNCE_START,
        ANNOUNCE_END=ANNOUNCE_END,
        USE_IMMANENCE=USE_IMMANENCE,
        CAST_SPELL=CAST_SPELL,
        FINISH=FINISH,
    }

    public.get_action = function()
        if skillchain ~= nil then
            return skillchain.program[index]
        else
            return nil
        end
    end

    public.get_next_action = function()
        local next_index = index + 1
        if skillchain ~= nil then
            return skillchain.program[next_index]
        else
            return nil
        end
    end


    public.advance = function()
        local action = public.get_action()
        if action == nil then
            return public.abort("Action missing")
        end

        local next_action = public.get_next_action()

        if next_action == nil then
            return public.abort("Can not advance: Next action missing")
        end
        
        if (next_action.needs_forced_delay and
            advance_delay and
            advance_delay > 0 and
            currently_delayed < advance_delay) then

            -- Start corouting to advance after advance_delay seconds
            local delay_fn = function()
                currently_delayed = advance_delay
                public.advance()
            end
            coroutine.schedule(delay_fn, advance_delay)

            return
        end

        currently_delayed = 0
        index = index + 1

        local method = public[next_action.method]
        if method then
            return method(next_action)
        else
            return public.abort("No such action: " .. (action.method or ""))
        end
    end

    public.resubmit = function()
        local action = public.get_action()
        if action == nil then
            return public.abort("Action missing")
        end

        if (action.needs_forced_delay and
            advance_delay and
            advance_delay > 0 and
            currently_delayed < advance_delay) then

            -- Start corouting to advance after advance_delay seconds
            local delay_fn = function()
                currently_delayed = advance_delay
                public.resubmit()
            end
            coroutine.schedule(delay_fn, advance_delay)

            return
        end

        currently_delayed = 0

        local method = public[action.method]
        if method then
            return method(action)
        else
            return public.abort("No such action: " .. (action.method or ""))
        end
    end


    public.announce_start = function()
        local sc = skillchain
        if sc ~= nil then
            local msg = sc.name .. " skillchain start: >> "
            if sc.burst_elements[2] then
                msg = msg .. sc.burst_elements[1] .. " / "  ..
                      sc.burst_elements[2]
            else
                msg = msg .. sc.burst_elements[1]
            end
            msg = msg .. " <<"
            send_command('input /party ' .. msg)
            public.advance()
        else
            public.abort("Skillchain not found")
        end
    end

    public.announce_end = function()
        local sc = skillchain
        if sc ~= nil then
            local msg = sc.name .. " skillchain end: >> "
            if sc.burst_elements[2] then
                msg = msg .. sc.burst_elements[1] .. " / " ..
                      sc.burst_elements[2]
            else
                msg = msg .. sc.burst_elements[1]
            end
            msg = msg .. " <<"
            send_command('input /party ' .. msg)
            public.advance()
        else
            public.abort("Skillchain not found")
        end
    end

    public.reset = function()
        skillchain = nil
        index = -1
        expected_next = ''
        advance_delay = 0
        currently_delayed = 0
        spell_count = 0

        if cc and cc.timer then
            coroutine.close(cc.timer)
            cc.timer = nil
        end
        cc = nil
    end

    public.finish = function()
        public.reset()
    end

    public.abort = function(message)
        send_command('input /party Skillchain aborted!')
        if message then
            add_to_chat(128, "Abort reason: " .. message)
        end
        public.reset()
    end

    public.check_interrupt = function(spell)
        if spell.english ~= expected_next then
            public.abort('Unexpected action: ' .. spell.english)
            return true
        end

        if spell.interrupted then
            public.retry_command()
            return true
        end

        return false
    end

    public.precast = function(spell)
        if not skillchain then
            return
        end
        if public.check_interrupt(spell) then
            return
        end
        -- Adjust total timeout to fit with casting time of spell
        if cc and spell.cast_time and not cc.cast_time_set then
            new_timeout = spell.cast_time + cc.time_elapsed + 2
            if new_timeout < cc.timeout then
                cc.timeout = new_timeout
            end
            cc.cast_time_set = true
        end
    end

    public.midcast = function(spell)
        if not skillchain then
            return
        end
        if public.check_interrupt(spell) then
            return
        end
    end

    public.aftercast = function(spell)
        if not skillchain then
            return
        end
        if public.check_interrupt(spell) then
            return
        end
        public.finish_command()
    end


    public.execute_command = function(cmd, max_delay, timeout)
        if cc ~= nil then
            -- kill the timer
            public.abort(
                "New command '" .. cmd .. "' " ..
                "while old command '" .. cc.input .. "' " ..
                "still active"
            )
        end
        local ticker
        ticker = function()
            if cc then
                -- advance time
                cc.time_elapsed = cc.time_elapsed + 0.1

                if cc.timeout and cc.time_elapsed >= cc.timeout then
                    public.abort("Timeout exeeded")
                else
                    -- Set up next tic
                    cc.timer = coroutine.schedule(ticker, 0.1)
                end
            end
        end
        cc = {
            time_elapsed=0,
            input=cmd,
            timer=coroutine.schedule(ticker, 0.1),
            max_wait=max_wait,
            timeout=timeout,
        }
        -- send the actual command
        send_command(cc.input)
    end


    public.inject_command = function(cmd, max_delay, timeout, grace_delay)
        public.execute_command(cmd, max_delay, timeout)
        advance_delay = grace_delay
        cc.injected = true
    end

    public.retry_command = function()
        if cc then
            if cc.max_delay and cc.max_delay > cc.time_elapsed then
                public.abort("Waited too long while retrying")
            else
                send_command(cc.input)
            end
        else
            public.abort("No current command while trying to retry")
        end
    end

    public.finish_command = function()
        if cc then
            if cc.timer then
                coroutine.close(cc.timer)
            end
            local injected = cc.injected
            cc = nil
            expected_next = ''
            if injected then
                public.resubmit()
            else
                public.advance()
            end
        end
    end

    public.use_immanence = function()
        -- Enable dark arts if it is not up
        if not (buffactive["Dark Arts"] or buffactive["Addendum: Black"]) then
            local recasts = windower.ffxi.get_ability_recasts()
            if (recasts[232] or 0) > 0 then
                return public.abort("Dark Arts not ready")
            end

            expected_next = "Dark Arts"
            return public.inject_command(
                'input /ja "Dark Arts" <me>', 1, 2, 1
            )
        end

        if buffactive["Immanence"] then
            advance_delay = 0
            public.advance()
        else
            public.execute_command("input /ja Immanence <me>", 1, 2)
            expected_next = "Immanence"
            advance_delay = public.get_action().advance_delay
        end
    end

    public.cast_spell = function()
        local action = public.get_action()
        cmd = 'input /ma "' .. action.spell .. '" <t>'
        -- 6 seconds timeout is a default and will be adjusted with actual
        -- casting time in precast method.
        public.execute_command(cmd, 1, 6)
        spell_count = spell_count + 1
        local msg = skillchain.name .. " skillchain spell #" .. spell_count
        send_command("input /party " .. msg)
        expected_next = action.spell
        advance_delay = action.advance_delay
    end

    public.start_skillchain = function(sc)
        if skillchain then
            return public.abort("Already have active skillchain, aborting it")
        end
        skillchain = sc
        index = 1
        local action = public.get_action()
        local method = public[action.method]
        if method then
            return method(action)
        end
    end

    public.start_skillchain_by_name = function(name)
        local sc = SKILLCHAINS[name:lower()]
        if sc then
            public.start_skillchain(sc)
        else
            add_to_chat(128, "No suck skillchian '" .. name .. '"')
        end
    end

    public.self_command = function(command)
        if command == "sc" then
            add_to_chat(
                128,
                "You must specify a name of the skillchain you want to use"
            )
            return true
        elseif command:sub(1, 3) == "sc " then
            auto_sc.start_skillchain_by_name(command:sub(4))
            return true
        else
            return false
        end
    end

    if not alias_initialized then
        send_command("alias sc gs c sc")
        alias_initialized = true
    end

    return public
end

return AutoImmanence;
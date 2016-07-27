--[[
    System for automatic execution of Immanence skillchains.

    To use include the following in your gearswap file:

        -- Top of file
        local AutoImmanence = require("AutoImmanence")

        function get_sets()
            ...
            -- Number for fastcast can be either 10 or 0.1 if you want to
            -- specify 10% fastcast.
            auto_sc = AutoImmanence({
                gear_fastcast=<number, default: 0>,
                uses_academics_loafers=<true/false, default: false>,
                uses_academics_loafers=<true/false, default: false>,
                uses_pedagogy_mortarboard=<true/false, default: false>,
            })
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
local USE_IMMANENCE = { method='use_immanence', }
local CAST_SPELL = function(spellname)
    return {
        method='cast_spell',
        on_finish='on_spell_finish',
        spell=spellname,
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

local SPELL_FORCED_DELAY = 2
local JA_FORCED_DELAY = 1

local MIN_SC_WINDOW = 3
local MAX_SC_WINDOW = 10

-- Spells before cast time is over, so we allow some fuzzyness
local SPELLS_FINISH_AT_FACTOR = 0.9

local alias_initialized = false

local spell_cache = {}
local res = require("resources")

function tprint(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local calculate_fast_cast = function(options)
    local job_and_gear = options['gear_fastcast'] or 0

    -- 10% gear fastcast might be specified as 10 instead of 0.1. If so
    -- convert it.
    if job_and_gear > 1 then
        job_and_gear = job_and_gear * 0.01
    end

    if player.sub_job == "RDM" then
        if player.sub_job_level >= 35 then
            job_and_gear = job_and_gear + 0.15
        elseif player.sub_job_level >= 15 then
            job_and_gear = job_and_gear + 0.1
        end
    end

    local grimoire = 0.1
    if options['uses_academics_loafers'] then
        grimoire = grimoire + 0.05
    elseif options['uses_scholars_loafers'] then
        grimoire = grimoire + 0.08
    end
    if options['uses_pedagogy_mortarboard'] then
        grimoire = grimoire + 0.1
    end

    return 1 * (1 - job_and_gear) * (1 - grimoire)
end

local AutoImmanence = function(options)

    local index = -1
    local skillchain = nil
    local expected_next = ''
    local cc = nil
    local spell_count = 0
    local injected_command = nil
    local forced_delay = 0
    local next_action_min_time = os.clock()
    local last_spell_cast_time = nil
    local fastcast = calculate_fast_cast(options or {})

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

        -- Constants
        SPELL_FORCED_DELAY=SPELL_FORCED_DELAY,
        JA_FORCED_DELAY=JA_FORCED_DELAY,
    }


    local update_next_action_time = function(when)
        if when > next_action_min_time then
            next_action_min_time = when
        end
    end

    local get_next_action_delay = function()
        local time = os.clock() - next_action_min_time
        if time > 0 then
            return time
        else
            return 0
        end
    end

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
        spell_count = 0
        forced_delay = 0
        next_action_min_time = os.clock()
        last_spell_cast_time = nil

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

    public.check_command_timeout = function()
        if cc and (os.clock() - cc.started) > cc.timeout then
            public.abort("Timeout exeeded")
            return true
        end
        return false
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

        cc = {
            started=os.clock(),
            input=cmd,
            max_delay=max_delay,
            delayed=0,
            timeout=timeout,
            timeout_handler=coroutine.schedule(
                public.check_command_timeout, timeout
            )
        }

        -- send the actual command
        send_command(cc.input)
    end

    public.command_delayed_too_long = function()
        if cc and (os.clock() - cc.started) <= cc.max_delay then
            return false
        else
            return true
        end
    end

    public.inject_command = function(cmd, max_delay, timeout)
        public.execute_command(cmd, max_delay, timeout)
        advance_delay = grace_delay
        cc.injected = true
    end

    public.retry_command = function()
        if cc then
            if public.command_delayed_too_long() then
                public.abort("Waited too long while retrying")
            else
                cc.delayed = os.clock() - cc.started
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
            if forced_delay > 0 then
                update_next_action_time(cc.started + forced_delay)
            end
            local injected = cc.injected
            cc = nil
            expected_next = ''
            local action = public.get_action()
            if action.on_finish then
                public[action.on_finish]()
            end
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
            public.advance()
        else
            local fn = function()
                public.execute_command("input /ja Immanence <me>", 1, 2)
                expected_next = "Immanence"
            end
            public.perform_forced_delay_action(fn, JA_FORCED_DELAY)
        end
    end

    public.test = function()
        print(fastcast)
    end



    public.perform_forced_delay_action = function(fn, delay)
        local until_next = get_next_action_delay()
        if until_next > 0 then
            local fn2 = function()
                forced_delay = delay
                fn()
            end
            coroutine.schedule(fn2, until_next)
        else
            forced_delay = delay
            fn()
        end
    end

    public.get_spellinfo = function(spellname)
        local spell = spell_cache[spellname:lower()]

        if spell == nil then
            spell = res.spells:with('name', spellname)

            if not spell then
                spell = res.spells:with('name', spellname:ucfirst())
            end

            spell_cache[spellname:lower()] = spell or ''
        end

        return spell
    end

    public.cast_spell = function()
        local action = public.get_action()
        local spell = public.get_spellinfo(action.spell)
        local cast_time = spell.cast_time * fastcast * SPELLS_FINISH_AT_FACTOR
        local since_last_spell = nil
        if last_spell_cast_time ~= nil then
            since_last_spell = os.clock() - last_spell_cast_time
        end

        -- Delay spell until SC window is open
        if since_last_spell ~= nil and
           (since_last_spell + cast_time) < MIN_SC_WINDOW then
            update_next_action_time(
                last_spell_cast_time + MIN_SC_WINDOW - cast_time
            )
        end

        cmd = 'input /ma "' .. action.spell .. '" <t>'
        local fn = function()
            local max_delay = 1
            if since_last_spell ~= nil then
                max_delay = MAX_SC_WINDOW - since_last_spell - cast_time - 0.5
            end
            public.execute_command(
                cmd, max_delay, max_delay + cast_time + 0.5
            )
            spell_count = spell_count + 1
            expected_next = action.spell

        end
        public.perform_forced_delay_action(fn, SPELL_FORCED_DELAY)
    end


    public.on_spell_finish = function()
        last_spell_cast_time = os.clock()
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
            if command:sub(4) == "test" then
                public.test()
            else
                public.start_skillchain_by_name(command:sub(4))
            end
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
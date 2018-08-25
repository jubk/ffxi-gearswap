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
}
local USE_EBULLIENCE = {
    method='use_ebullience',
    needs_forced_delay=true,
}
local USE_ALACRITY = {
    method='use_alacrity',
    needs_forced_delay=true,
}
local CAST_SPELL = function(spellname)
    return {
        method='cast_spell',
        spell=spellname,
        needs_forced_delay=true,
        on_finish='on_spell_finish',
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
SKILLCHAINS["wind"]=SKILLCHAINS["detonation"]
SKILLCHAINS["darkness"]=SKILLCHAINS["compression"]
SKILLCHAINS["light"]=SKILLCHAINS["transfixion"]
SKILLCHAINS["water"]=SKILLCHAINS["reverberation"]
SKILLCHAINS["blizzard"]=SKILLCHAINS["induration"]
SKILLCHAINS["ice"]=SKILLCHAINS["induration"]
SKILLCHAINS["thunder"]=SKILLCHAINS["impaction"]
SKILLCHAINS["fire"]=SKILLCHAINS["liquefaction"]

local SPELL_FORCED_DELAY = 2.3
local JA_FORCED_DELAY = 0

local MIN_SC_WINDOW = 3
local MAX_SC_WINDOW = 10

local alias_initialized = false
local spell_cache = {}

local res = require("resources")

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
        grimoire = grimoire + 0.08
    elseif options['uses_scholars_loafers'] then
        grimoire = grimoire + 0.05
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
    local forced_delay = 0
    local spell_count = 0
    local injected_command = nil
    local last_spell_cast_time = nil
    local last_action_finished = os.clock()
    local last_skillchain_finished = os.clock() - 10
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
            forced_delay and
            forced_delay > 0) then

            local dt = os.clock() - last_action_finished

            if (dt + 0.05) < forced_delay then
                -- Start corouting to advance after forced_delay seconds
                coroutine.schedule(public.advance, forced_delay - dt)
                return
            end
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

        if (action.needs_forced_delay and
            forced_delay and
            forced_delay > 0) then

            local dt = os.clock() - last_action_finished

            if dt < forced_delay then
                add_to_chat(128, "Forced delay: " .. (forced_delay - dt))
                -- Start corouting to advance after forced_delay seconds
                coroutine.schedule(public.advance, forced_delay - dt)
                return
            end
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
        forced_delay = 0
        spell_count = 0
        last_spell_cast_time = nil

        if cc and cc.timer then
            coroutine.close(cc.timer)
            cc.timer = nil
        end
        cc = nil
    end

    public.finish = function()
        public.reset()
        last_skillchain_finished = os.clock()
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
        if cc then
            cc.gearswap_spell = spell
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
        if not cc or cc.finished then
            return false
        end
        if (os.clock() - cc.started) > cc.timeout then
            public.abort(
                "Timeout exeeded (" .. cc.timeout .. "): " .. cc.input
            )
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
            time_elapsed=0,
            input=cmd,
            max_wait=max_wait,
            timeout=timeout,
            timer=coroutine.schedule(
                public.check_command_timeout, timeout + 0.01
            ),
        }
        -- send the actual command
        send_command(cc.input)
    end


    public.inject_command = function(cmd, max_delay, timeout, grace_delay)
        public.execute_command(cmd, max_delay, timeout)
        forced_delay = grace_delay
        cc.injected = true
    end

    public.retry_command = function()
        if cc then
            local time_elapsed = os.clock() - cc.started
            if cc.max_delay and cc.max_delay > time_elapsed then
                public.abort(
                    "Waited too long while retrying " .. cc.input
                )
            else
                add_to_chat(128, "Retrying " .. cc.input)
                local retry_fn = function()
                    send_command(cc.input)
                end
                coroutine.schedule(retry_fn, 0.3)
            end
        else
            public.abort("No current command while trying to retry")
        end
    end

    public.finish_command = function()
        if cc then
            cc.finished = true
            last_action_finished = os.clock()
            local injected = cc.injected
            local action = public.get_action()
            if action.on_finish then
                public[action.on_finish](cc)
            end
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
        -- We can not completely rely on buffactive, so check if we recently
        -- casted a spell as well.
        if (buffactive["Immanence"] and
            not (
                last_spell_cast_time ~= nil and
                (os.clock() - last_spell_cast_time) <= 3
            )) then
            forced_delay = 0
            public.advance()
        else
            public.execute_command("input /ja Immanence <me>", 1, 3)
            expected_next = "Immanence"
            forced_delay = JA_FORCED_DELAY
        end
    end

    public.use_ebullience = function()
        -- We can not completely rely on buffactive, so check if we recently
        -- casted a spell as well.
        if (buffactive["Ebullience"] and
            not (
                last_spell_cast_time ~= nil and
                (os.clock() - last_spell_cast_time) <= 3
            )) then
            forced_delay = 0
            public.advance()
        else
            public.execute_command("input /ja Ebullience <me>", 1, 3)
            expected_next = "Ebullience"
            forced_delay = JA_FORCED_DELAY
        end
    end

    public.use_alacrity = function()
        -- We can not completely rely on buffactive, so check if we recently
        -- casted a spell as well.
        if (buffactive["Alacrity"] and
            not (
                last_spell_cast_time ~= nil and
                (os.clock() - last_spell_cast_time) <= 3
            )) then
            forced_delay = 0
            public.advance()
        else
            public.execute_command("input /ja Alacrity <me>", 1, 3)
            expected_next = "Alacrity"
            forced_delay = JA_FORCED_DELAY
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
        local cast_time = spell.cast_time * fastcast
        local since_last_spell = nil
        local max_delay = 1

        if last_spell_cast_time ~= nil then
            since_last_spell = os.clock() - last_spell_cast_time
        end

        -- Delay spell until SC window is open
        if since_last_spell ~= nil and
           (since_last_spell + cast_time) < MIN_SC_WINDOW then
            local sc_delay = MIN_SC_WINDOW - since_last_spell - cast_time
            coroutine.schedule(public.resubmit, sc_delay + 0.01)
            return
        end


        cmd = 'input /ma "' .. action.spell .. '" <t>'
        if since_last_spell ~= nil then
            max_delay = MAX_SC_WINDOW - since_last_spell - cast_time - 0.5
        end

        public.execute_command(
            cmd, max_delay, MAX_SC_WINDOW - (since_last_spell or 0)
        )
        spell_count = spell_count + 1
        expected_next = action.spell
        forced_delay = SPELL_FORCED_DELAY
    end

    public.on_spell_finish = function(cc)
        local spell = cc.gearswap_spell or { cast_time=0 }
        -- It's a bit fuzzy when the spell ends, so we add a factor of the
        -- spells cast time to the finishing time.
        last_spell_cast_time = os.clock() + (spell.cast_time * 0.3)
    end

    public.start_skillchain = function(sc, opts)
        if skillchain then
            return public.abort("Already have active skillchain, aborting it")
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

        skillchain = {}

        -- Create a copy of the skillchain and add various options before
        -- the finish.
        for k, v in pairs(sc) do
            skillchain[k] = v
        end
        skillchain.program = {}

        for _, action in ipairs(sc.program) do
            if action.method == 'finish' then
                if opts['ebullience'] then
                    table.insert(skillchain.program, USE_EBULLIENCE)
                end
                if opts['alacrity'] then
                    table.insert(skillchain.program, USE_ALACRITY)
                end
                -- TODO: Cast nuke if opts['nuke'] is set
            end
            table.insert(skillchain.program, action)
        end

        index = 1
        local action = public.get_action()
        local method = public[action.method]
        if method then
            return method(action)
        end
    end

    public.start_skillchain_by_name = function(name, opts)
        local sc = SKILLCHAINS[name:lower()]
        if sc then
            public.start_skillchain(sc, opts)
        else
            add_to_chat(128, "No suck skillchian '" .. name .. '"')
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
            local element, rest = args_str:match('(%a+)%s*(.*)')
            local opts = {}
            if rest:find('[+]') then
                opts['ebullience'] = true
            end
            if rest:find('[+][+]') then
                opts['alacrity'] = true
            end
            opts['nuke'] = rest:match('(%d+)')
            
            auto_sc.start_skillchain_by_name(element, opts)
        end
    end

    if not alias_initialized then
        send_command("alias sc gs c sc")
        alias_initialized = true
    end

    public.in_mb_window = function(spell)
        local since_skillchain = os.clock() - last_skillchain_finished
        local cast_time = spell.cast_time * fastcast
        return (since_skillchain + cast_time) <= MAX_SC_WINDOW
    end

    return public
end

return AutoImmanence;
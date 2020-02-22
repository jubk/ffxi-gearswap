--------------------------------------------------------------------------------------------------------------------
-- (Original: Motenten / Modified: Arislan)
-------------------------------------------------------------------------------------------------------------------

--[[    Custom Features:
        QuickDraw Selector  Cycle through available primary and secondary shot types,
                            and trigger with a single macro
        Haste Detection     Detects current magic haste level and equips corresponding engaged set to
                            optimize delay reduction (automatic)
        Haste Mode          Toggles between Haste II and Haste I recieved, used by Haste Detection [WinKey-H]
        Capacity Pts. Mode  Capacity Points Mode Toggle [WinKey-C]
        Auto. Lockstyle     Automatically locks specified equipset on file load
--]]


-------------------------------------------------------------------------------------------------------------------

--[[
    Custom commands:
    
    gs c qd
        Uses the currently configured shot on the target, with either <t> or <stnpc> depending on setting.
    gs c qd t
        Uses the currently configured shot on the target, but forces use of <t>.
    
    
    Configuration commands:
    
    gs c cycle mainqd
        Cycles through the available steps to use as the primary shot when using one of the above commands.
        
    gs c cycle altqd
        Cycles through the available steps to use for alternating with the configured main shot.
        
    gs c toggle usealtqd
        Toggles whether or not to use an alternate shot.
        
    gs c toggle selectqdtarget
        Toggles whether or not to use <stnpc> (as opposed to <t>) when using a shot.
        
        
    gs c toggle LuzafRing -- Toggles use of Luzaf Ring on and off
    
    Offense mode is melee or ranged.  Used ranged offense mode if you are engaged
    for ranged weaponskills, but not actually meleeing.
    
    Weaponskill mode, if set to 'Normal', is handled separately for melee and ranged weaponskills.
--]]


-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
    
    -- Load and initialize the include file.
    include('Mote-Include.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    -- QuickDraw Selector
    state.Mainqd = M{['description']='Primary Shot', 'Fire Shot', 'Ice Shot', 'Wind Shot', 'Earth Shot', 'Thunder Shot', 'Water Shot'}
    state.Altqd = M{['description']='Secondary Shot', 'Fire Shot', 'Ice Shot', 'Wind Shot', 'Earth Shot', 'Thunder Shot', 'Water Shot'}
    state.UseAltqd = M(false, 'Use Secondary Shot')
    state.SelectqdTarget = M(false, 'Select Quick Draw Target')
    state.IgnoreTargetting = M(false, 'Ignore Targetting')

    state.FlurryMode = M{['description']='Flurry Mode', 'Flurry I', 'Flurry II'}
    state.HasteMode = M{['description']='Haste Mode', 'Haste II', 'Haste I'}
    state.DualWield = M(false, 'Dual Wield III')
    state.QDMode = M{['description']='Quick Draw Mode', 'Magic Enhance', 'Magic Attack', 'STP'}

    state.Currentqd = M{['description']='Current Quick Draw', 'Main', 'Alt'}
    
    -- Whether to use Luzaf's Ring
    state.LuzafRing = M(false, "Luzaf's Ring")
    -- Whether a warning has been given for low ammo
    state.warned = M(false)
    
    define_roll_values()
    determine_haste_group()

end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('STP', 'Normal', 'LowAcc', 'MidAcc', 'HighAcc')
    state.HybridMode:options('Normal', 'DT')
    state.RangedMode:options('STP', 'Normal', 'Acc', 'HighAcc', 'Critical')
    state.WeaponskillMode:options('Normal', 'Acc')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'DT')

    state.WeaponLock = M(false, 'Weapon Lock')    
    state.Gun = M{['description']='Current Gun', 'Death Penalty', 'Fomalhaut', 'Anarchy +2'}--, 'Armageddon'
    state.CP = M(false, "Capacity Points Mode")

    gear.RAbullet = "Chrono Bullet"
    gear.WSbullet = "Chrono Bullet"
    gear.MAbullet = "Living Bullet"
    gear.QDbullet = "Living Bullet"
    options.ammo_warning_limit = 50

    -- Additional local binds

    send_command('bind ^` input /ja "Double-up" <me>')
    send_command('bind ^c input /ja "Crooked Cards" <me>')
    send_command('bind ^s input /ja "Snake Eye" <me>')
    send_command('bind ^x input /ja "Fold" <me>')
    send_command('bind !` input /ja "Bolter\'s Roll" <me>')
    send_command ('bind @` gs c toggle LuzafRing')

    send_command('bind ^- gs c cycleback mainqd')
    send_command('bind ^= gs c cycle mainqd')
    send_command('bind !- gs c cycle altqd')
    send_command('bind != gs c cycleback altqd')
    send_command('bind ^[ gs c toggle selectqdtarget')
    send_command('bind ^] gs c toggle usealtqd')

    send_command('bind @c gs c toggle CP')
    send_command('bind @q gs c cycle QDMode')
    send_command('bind @b gs c cycle Gun')
    send_command('bind @f gs c cycle FlurryMode')
    send_command('bind @h gs c cycle HasteMode')
    send_command('bind @w gs c toggle WeaponLock')

    send_command('bind ^numlock input /ja "Triple Shot" <me>')

    if player.sub_job == 'WAR' then
        send_command('bind ^numpad/ input /ja "Berserk" <me>')
        send_command('bind ^numpad* input /ja "Warcry" <me>')
        send_command('bind ^numpad- input /ja "Aggressor" <me>')
    elseif player.sub_job == 'RNG' then
        send_command('bind ^numpad/ input /ja "Barrage" <me>')
        send_command('bind ^numpad* input /ja "Sharpshot" <me>')
        send_command('bind ^numpad- input /ja "Shadowbind" <me>')
    end

    send_command('bind ^numpad7 input /ws "Savage Blade" <t>')
    send_command('bind ^numpad8 input /ws "Last Stand" <t>')
    send_command('bind ^numpad4 input /ws "Leaden Salute" <t>')
    send_command('bind ^numpad6 input /ws "Wildfire" <t>')
    send_command('bind ^numpad1 input /ws "Requiescat" <t>')
    send_command('bind ^numpad2 input /ws "Sniper Shot" <t>')
    send_command('bind ^numpad3 input /ws "Numbing Shot" <t>')

    send_command('bind numpad0 input /ra <t>')

    select_default_macro_book()
    set_lockstyle()
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind ^-')
    send_command('unbind ^=')
    send_command('unbind !-')
    send_command('unbind !=')
    send_command('unbind ^[')
    send_command('unbind ^]')
    send_command('unbind ^,')
    send_command('unbind @c')
    send_command('unbind @q')
    send_command('unbind @b')
    send_command('unbind @f')
    send_command('unbind @h')
    send_command('unbind @w')
    send_command('unbind ^numlock')
    send_command('unbind ^numpad/')
    send_command('unbind ^numpad*')
    send_command('unbind ^numpad-')
    send_command('unbind ^numpad8')
    send_command('unbind ^numpad4')
    send_command('unbind ^numpad6')
    send_command('unbind ^numpad1')
    send_command('unbind ^numpad2')
    send_command('unbind ^numpad3')
    send_command('unbind numpad0')

    send_command('unbind #`')
    send_command('unbind #1')
    send_command('unbind #2')
    send_command('unbind #3')
    send_command('unbind #4')
    send_command('unbind #5')
    send_command('unbind #6')
    send_command('unbind #7')
    send_command('unbind #8')
    send_command('unbind #9')
    send_command('unbind #0')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.JA['Snake Eye'] = {legs="Lanun Trews +1"}
    sets.precast.JA['Wild Card'] = {feet="Lanun Bottes +2"}
    sets.precast.JA['Random Deal'] = {body="Lanun Frac +1"}

    sets.precast.CorsairRoll = {
        head="Lanun Tricorne +1",
        body="Meg. Cuirie +2", 
        hands="Chasseur's Gants +1",
        legs="Desultor Tassets",
        feet="Lanun Bottes +2",
        neck="Regal Necklace",
        ear1="Etiolation Earring",
        ear2="Odnowa Earring +1", 
        ring1="Luzaf's Ring",
        ring2="Defending Ring", 
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Magic dmg. taken-10%',}},
        waist="Flume Belt +1", 
        }

    sets.precast.CorsairRoll.Gun = set_combine(sets.precast.CorsairRoll.Engaged, {range="Compensator"})
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {legs="Chas. Culottes"})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {feet="Chass. Bottes +1"})
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {head="Chass. Tricorne"})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body="Chasseur's Frac +1"})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {hands="Chasseur's Gants +1"})
    
    sets.precast.LuzafRing = set_combine(sets.precast.CorsairRoll, {ring1="Luzaf's Ring"})
    sets.precast.FoldDoubleBust = {hands="Lanun Gants +1"}

    sets.precast.Waltz = {
        head="Mummu Bonnet +2", 
		body="Passion Jacket",
        neck="Phalaina Locket",
        ring1="Asklepian Ring",
        waist="Gishdubar Sash",
        }

    sets.precast.Waltz['Healing Waltz'] = {}
    
    sets.precast.FC = {
        head="Herculean Helm", --7
        hands="Leyline Gloves", --7
		body="Dread Jupon", --7
        neck="Baetyl Pendant", --4
        ear1="Loquacious Earring", --2
        ear2="Etiolation Earring", --1
        ring1="Kishar Ring", --4
        ring2="Weatherspoon Ring", --5
        }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        body="Passion Jacket",
        neck="Magoraga Beads",
        ring1="Lebeche Ring",
        })

    -- (10% Snapshot from JP Gifts)
    sets.precast.RA = {
        ammo=gear.RAbullet,
        head="Taeon Chapeau", --10/0
        body="Oshosi Vest", --12/0
        hands={ name="Carmine Fin. Ga. +1", augments={'Rng.Atk.+20','"Mag.Atk.Bns."+12','"Store TP"+6',}}, --8/11
        legs={ name="Adhemar Kecks", augments={'AGI+9','"Rapid Shot"+10','Enmity-4',}}, --9/10
        feet="Meg. Jam. +2", --10/0
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Magic dmg. taken-10%',}}, --10/0
        waist="Impulse Belt", --3/0
        } --62+10/21

    sets.precast.RA.Flurry1 = set_combine(sets.precast.RA, {
        body="Laksa. Frac +3", --0/20
		}) --50+25/41

    sets.precast.RA.Flurry2 = set_combine(sets.precast.RA.Flurry1, {
        }) --50+40/41


    ------------------------------------------------------------------------------------------------
    ------------------------------------- Weapon Skill Sets ----------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.WS = {
        ammo=gear.WSbullet,
        head="Meghanada Visor +2",
        body="Laksa. Frac +3",
        hands="Meg. Gloves +2",
        legs="Meg. Chausses +2",
        feet="Meg. Jam. +2",
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        ring1="Nekhan Ring",
        ring2="Cacoethic Ring +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
        waist="Fotia Belt",
        }

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {
        })

    sets.precast.WS['Last Stand'] = sets.precast.WS

    sets.precast.WS['Last Stand'].Acc = set_combine(sets.precast.WS['Last Stand'], {
        })

    sets.precast.WS['Wildfire'] = {
        ammo=gear.MAbullet,
		head={ name="Herculean Helm", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','Mag. Acc.+13','"Mag.Atk.Bns."+7',}},
		body="Lanun Frac +3",
		hands={ name="Herculean Gloves", augments={'"Mag.Atk.Bns."+24','Weapon skill damage +4%',}},
		legs={ name="Herculean Trousers", augments={'STR+11','Magic dmg. taken -1%','Weapon skill damage +4%','Accuracy+5 Attack+5','Mag. Acc.+20 "Mag.Atk.Bns."+20',}},
		feet="Lanun Bottes +2",
        neck="Baetyl Pendant",
        ear1="Hecate's Earring",
        ear2="Friomisi Earring",
        ring1="Acumen Ring",
        ring2="Arvina Ringlet +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',}},
        waist="Eschan Stone",
        }

    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS['Wildfire'], {
        head="Pixie Hairpin +1",
        ear1="Moonshade Earring",
        ring1="Archon Ring",
        })
    
	sets.precast.WS['Hot Shot'] = set_combine(sets.precast.WS['Wildfire'], {
        })
		
    sets.precast.WS['Leaden Salute'].FullTP = {ear1="Hecate's Earring", waist="Svelt. Gouriz +1"}
        
    sets.precast.WS['Evisceration'] = {
        head=gear.Adhemar_B_head,
        body="Abnoba Kaftan",
        hands="Mummu Wrists +2",
        legs="Samnuha Tights",
        feet="Mummu Gamash. +2",
        neck="Fotia Gorget",
        ear2="Brutal Earring",
        ring1="Regal Ring",
        ring2="Mummu Ring",
        back=gear.COR_TP_Cape,
        waist="Fotia Belt",
        }

    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {
        head="Meghanada Visor +2",
        body=gear.Adhemar_B_body,
        legs=gear.Herc_WS_legs,
        ear2="Telos Earring",
        })

	sets.precast.WS['Fast Blade'] = set_combine(sets.precast.WS, {
		body="Meg. Cuirie +2",
		ring1="Apate Ring",
		back={ name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
        })
		
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		ring1="Apate Ring",
		ring2="Rufescent Ring",
		waist="Prosilio Belt +1",
		back={ name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
        })
        
    sets.precast.WS['Savage Blade'].Acc = set_combine(sets.precast.WS['Savage Blade'], {
        })

    sets.precast.WS['Swift Blade'] = set_combine(sets.precast.WS, {
		body="Meg. Cuirie +2",
		ring1="Apate Ring",
		back={ name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}},
        })

    sets.precast.WS['Swift Blade'].Acc = set_combine(sets.precast.WS['Swift Blade'], {
        })

    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS['Swift Blade'], {
        hands="Meg. Gloves +2",
        ear1="Moonshade Earring",
        ear2="Telos Earring",
        ring2="Rufescent Ring",
        }) --MND

    sets.precast.WS['Requiescat'].Acc = set_combine(sets.precast.WS['Requiescat'], {
        head="Meghanada Visor +2",
        feet=gear.Herc_STP_feet,
        ear1="Cessance Earring",
        })

    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS['Wildfire'], {
        ear1="Moonshade Earring",
        ring1="Shiva Ring +1",
		feet="Lanun Bottes +2",
        })

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast.SpellInterrupt = {
        legs="Carmine Cuisses +1", --20
        ring1="Evanescence Ring", --5
        }

    sets.midcast.Cure = {
        neck="Incanter's Torque",
        ear1="Roundel Earring",
        ear2="Mendi. Earring",
        ring1="Lebeche Ring",
        ring2="Haoma's Ring",
        waist="Bishop's Sash",
        }    

    sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

    -- Occult Acumen Set
    sets.midcast['Dark Magic'] = {
        ammo=gear.QDbullet,
        head=gear.Herc_MAB_head,
        body="Mummu Jacket +2",
        hands=gear.Adhemar_B_hands,
        legs="Chas. Culottes +1",
        feet="Carmine Greaves +1",
        neck="Iskur Gorget",
        ear1="Dedition Earring",
        ear2="Telos Earring",
        ring1="Archon Ring",
        ring2="Dingir Ring",
        back=gear.COR_RA_Cape,
        waist="Oneiros Rope",        
        }

    sets.midcast.CorsairShot = {
        ammo=gear.QDbullet,
		head={ name="Herculean Helm", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','Mag. Acc.+13','"Mag.Atk.Bns."+7',}},
		body="Lanun Frac +3",
		hands={ name="Herculean Gloves", augments={'INT+2','"Mag.Atk.Bns."+30','Mag. Acc.+12 "Mag.Atk.Bns."+12',}},
		legs={ name="Herculean Trousers", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','Enmity-2','DEX+7','Mag. Acc.+10','"Mag.Atk.Bns."+12',}},
		feet="Lanun Bottes +2",
		neck="Baetyl Pendant",
        ear1="Hecate's Earring",
        ear2="Friomisi Earring",
        ring1="Acumen Ring",
        ring2="Arvina Ringlet +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',}},
        waist="Eschan Stone",
        }

    sets.midcast.CorsairShot.STP = {
        ammo=gear.QDbullet,
		head={ name="Herculean Helm", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','Mag. Acc.+13','"Mag.Atk.Bns."+7',}},
		body="Lanun Frac +3",
		hands={ name="Herculean Gloves", augments={'INT+2','"Mag.Atk.Bns."+30','Mag. Acc.+12 "Mag.Atk.Bns."+12',}},
		legs={ name="Herculean Trousers", augments={'Mag. Acc.+20 "Mag.Atk.Bns."+20','Enmity-2','DEX+7','Mag. Acc.+10','"Mag.Atk.Bns."+12',}},
		feet={ name="Adhe. Gamashes +1", augments={'HP+65','"Store TP"+7','"Snapshot"+10',}},
		neck="Baetyl Pendant",
        ear1="Telos Earring",
        ear2="Enervating Earring",
        ring1="Acumen Ring",
        ring2="Arvina Ringlet +1",
        back={ name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',}},
        waist="Eschan Stone",
        }

    sets.midcast.CorsairShot.Resistant = set_combine(sets.midcast.CorsairShot, {
		head="Laskamana's tricorne +2",
		body="Mummu Jacket +2",
		hands="Laskamana's gants +2",
		legs="Mummu Kecks +2",
		feet="Laskamana's boots +2",
		neck="Sanctity Necklace",
        ear1="Telos Earring",
		ear2="Hermetic Earring",
        ring1="Mummu Ring",
		ring2="Stikini Ring +1",
        })

    sets.midcast.CorsairShot['Light Shot'] = sets.midcast.CorsairShot.Resistant
    sets.midcast.CorsairShot['Dark Shot'] = sets.midcast.CorsairShot.Resistant
    sets.midcast.CorsairShot.Enhance = {feet="Chass. Bottes +1"}

    -- Ranged gear
    sets.midcast.RA = {
        ammo=gear.RAbullet,    
		head="Meghanada Visor +2",
		body="Mummu Jacket +2",
		hands="Adhemar wristbands +1",
		legs={ name="Adhemar Kecks +1", augments={'AGI+12','Rng.Acc.+20','Rng.Atk.+20',}},
		feet="Adhemar gamashes +1",
		neck="Iskur Gorget",
        ear1="Telos Earring",
        ear2="Enervating Earring",
        ring1="Cacoethic Ring +1",
        ring2="Hajduk Ring",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
        waist="Yemaya Belt",
        }

    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
        feet="Meg. Jam. +2",
		body="Laksa. Frac +3",
		})

    sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.Acc, {
		})

    sets.midcast.RA.Critical = set_combine(sets.midcast.RA, {
        })

    sets.midcast.RA.STP = set_combine(sets.midcast.RA, {
        })

    sets.TripleShot = {
        ammo=gear.RAbullet,    
		head="Oshosi Mask", --4
        body="Chasseur's Frac +1", --12
		hands="Adhemar wristbands +1",
		legs={ name="Adhemar Kecks +1", augments={'AGI+12','Rng.Acc.+20','Rng.Atk.+20',}},
		feet="Adhemar gamashes +1",
		neck="Iskur Gorget",
        ear1="Telos Earring",
        ear2="Enervating Earring",
        ring1="Cacoethic Ring +1",
        ring2="Hajduk Ring",
        back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}}, --5
        waist="Yemaya Belt",
        } --21



    ------------------------------------------------------------------------------------------------
    ----------------------------------------- Idle Sets --------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.resting = {}

    sets.idle = {
        ammo=gear.MAbullet,
		head="Meghanada Visor +2",
		body="Lanun Frac +3",
		hands="Meg. Gloves +2",
		legs="Mummu Kecks +2",
		feet={ name="Lanun Bottes +2", augments={'Enhances "Wild Card" effect',}},
		neck="Loricate Torque +1",
        ear1="Etiolation Earring",
        ear2="Odnowa Earring +1",
        ring1="Defending Ring",
        ring2="Gelatinous Ring +1",
        back={ name="Camulus's Mantle", augments={'INT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','"Snapshot"+10','Magic dmg. taken-10%',}},
        waist="Flume Belt +1",
        }

    sets.idle.DT = set_combine(sets.idle, {
        })

    sets.idle.Town = set_combine(sets.idle, {
		head="Meghanada Visor +2",
		body="Mummu Jacket +2",
		hands={ name="Adhemar Wrist. +1", augments={'AGI+12','Rng.Acc.+20','Rng.Atk.+20',}},
		legs={ name="Adhemar Kecks +1", augments={'AGI+12','Rng.Acc.+20','Rng.Atk.+20',}},
		feet="Skd. Jambeaux +1",
		neck="Iskur Gorget",
		waist="Yemaya Belt",
		left_ear="Telos Earring",
		right_ear="Enervating Earring",
		left_ring="Cacoethic Ring +1",
		right_ring="Hajduk Ring",
		back={ name="Camulus's Mantle", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
        })


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Defense Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.defense.PDT = sets.idle.DT
    sets.defense.MDT = sets.idle.DT

    sets.Kiting = {feet="Skd. Jambeaux +1"}


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Engaged Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    -- * DNC Subjob DW Trait: +15%
    -- * NIN Subjob DW Trait: +25%
    
    -- No Magic Haste (74% DW to cap)
    sets.engaged = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Meg. Chausses +2",
		feet="Mummu Gamash. +2",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},
        } -- 0%

    sets.engaged.LowAcc = set_combine(sets.engaged, {
        })

    sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {
        })

    sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {
		head="Meghanada Visor +2",
		neck="Clotharius Torque",
		waist="Hurch'lan Sash",
		left_ear="Telos Earring",
		right_ring="Cacoethic Ring +1",
        })

    sets.engaged.STP = set_combine(sets.engaged, {
        })

    -- 15% Magic Haste (67% DW to cap)
    sets.engaged.LowHaste = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Meg. Chausses +2",
		feet="Mummu Gamash. +2",
		neck="Clotharius Torque",
		waist="Windbuffet Belt +1",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},
        } -- 0%

    sets.engaged.LowAcc.LowHaste = set_combine(sets.engaged.LowHaste, {
        })

    sets.engaged.MidAcc.LowHaste = set_combine(sets.engaged.LowAcc.LowHaste, {
        })

    sets.engaged.HighAcc.LowHaste = set_combine(sets.engaged.MidAcc.LowHaste, {
		head="Meghanada Visor +2",
		neck="Clotharius Torque",
		waist="Hurch'lan Sash",
		left_ear="Telos Earring",
		right_ring="Cacoethic Ring +1",
        })

    sets.engaged.STP.LowHaste = set_combine(sets.engaged.LowHaste, {
        })

    -- 30% Magic Haste (56% DW to cap)
    sets.engaged.MidHaste = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Meg. Chausses +2",
		feet="Mummu Gamash. +2",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},
        } -- 0%

    sets.engaged.LowAcc.MidHaste = set_combine(sets.engaged.MidHaste, {
        })

    sets.engaged.MidAcc.MidHaste = set_combine(sets.engaged.LowAcc.MidHaste, {
        })

    sets.engaged.HighAcc.MidHaste = set_combine(sets.engaged.MidAcc.MidHaste, {
		head="Meghanada Visor +2",
		neck="Clotharius Torque",
		waist="Hurch'lan Sash",
		left_ear="Telos Earring",
		right_ring="Cacoethic Ring +1",
        })

    sets.engaged.STP.MidHaste = set_combine(sets.engaged.MidHaste, {
        })

    -- 35% Magic Haste (51% DW to cap)
    sets.engaged.HighHaste = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Meg. Chausses +2",
		feet="Mummu Gamash. +2",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},
        } -- 0%

    sets.engaged.LowAcc.HighHaste = set_combine(sets.engaged.HighHaste, {
        })

    sets.engaged.MidAcc.HighHaste = set_combine(sets.engaged.LowAcc.HighHaste, {
        })

    sets.engaged.HighAcc.HighHaste = set_combine(sets.engaged.MidAcc.HighHaste, {
		head="Meghanada Visor +2",
		neck="Clotharius Torque",
		waist="Hurch'lan Sash",
		left_ear="Telos Earring",
		right_ring="Cacoethic Ring +1",
        })

    sets.engaged.STP.HighHaste = set_combine(sets.engaged.HighHaste, {
        })
        
    -- 45% Magic Haste (36% DW to cap)
    sets.engaged.MaxHaste = {
		head={ name="Adhemar Bonnet", augments={'DEX+10','AGI+10','Accuracy+15',}},
		body={ name="Adhemar Jacket", augments={'DEX+10','AGI+10','Accuracy+15',}},
		hands={ name="Adhemar Wristbands", augments={'DEX+10','AGI+10','Accuracy+15',}},
		legs="Meg. Chausses +2",
		feet="Mummu Gamash. +2",
		neck="Iskur Gorget",
		waist="Windbuffet Belt +1",
		left_ear="Eabani Earring",
		right_ear="Suppanomimi",
		left_ring="Petrov Ring",
		right_ring="Epona's Ring",
		back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},
        } -- 0%

    sets.engaged.LowAcc.MaxHaste = set_combine(sets.engaged.MaxHaste, {
        })

    sets.engaged.MidAcc.MaxHaste = set_combine(sets.engaged.LowAcc.MaxHaste, {
        })

    sets.engaged.HighAcc.MaxHaste = set_combine(sets.engaged.MidAcc.MaxHaste, {
		head="Meghanada Visor +2",
		neck="Clotharius Torque",
		waist="Hurch'lan Sash",
		left_ear="Telos Earring",
		right_ring="Cacoethic Ring +1",
        })

    sets.engaged.STP.MaxHaste = set_combine(sets.engaged.MaxHaste, {
        })

    sets.LessDualWield = {back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Damage taken-5%',}},}

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Hybrid Sets -------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.engaged.Hybrid = {
        neck="Loricate Torque +1", --6/6
        ring2="Defending Ring", --10/10
        }
    
    sets.engaged.DT = set_combine(sets.engaged, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT = set_combine(sets.engaged.LowAcc, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT = set_combine(sets.engaged.MidAcc, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT = set_combine(sets.engaged.HighAcc, sets.engaged.Hybrid)
    sets.engaged.STP.DT = set_combine(sets.engaged.STP, sets.engaged.Hybrid)

    sets.engaged.DT.LowHaste = set_combine(sets.engaged.LowHaste, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT.LowHaste = set_combine(sets.engaged.LowAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT.LowHaste = set_combine(sets.engaged.MidAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT.LowHaste = set_combine(sets.engaged.HighAcc.LowHaste, sets.engaged.Hybrid)    
    sets.engaged.STP.DT.LowHaste = set_combine(sets.engaged.STP.LowHaste, sets.engaged.Hybrid)

    sets.engaged.DT.MidHaste = set_combine(sets.engaged.MidHaste, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT.MidHaste = set_combine(sets.engaged.LowAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT.MidHaste = set_combine(sets.engaged.MidAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT.MidHaste = set_combine(sets.engaged.HighAcc.MidHaste, sets.engaged.Hybrid)    
    sets.engaged.STP.DT.MidHaste = set_combine(sets.engaged.STP.MidHaste, sets.engaged.Hybrid)

    sets.engaged.DT.HighHaste = set_combine(sets.engaged.HighHaste, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT.HighHaste = set_combine(sets.engaged.LowAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT.HighHaste = set_combine(sets.engaged.MidAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT.HighHaste = set_combine(sets.engaged.HighAcc.HighHaste, sets.engaged.Hybrid)    
    sets.engaged.STP.DT.HighHaste = set_combine(sets.engaged.HighHaste.STP, sets.engaged.Hybrid)

    sets.engaged.DT.MaxHaste = set_combine(sets.engaged.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT.MaxHaste = set_combine(sets.engaged.LowAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT.MaxHaste = set_combine(sets.engaged.MidAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT.MaxHaste = set_combine(sets.engaged.HighAcc.MaxHaste, sets.engaged.Hybrid)    
    sets.engaged.STP.DT.MaxHaste = set_combine(sets.engaged.STP.MaxHaste, sets.engaged.Hybrid)


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Special Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.buff.Doom = {ring1="Eshmun's Ring", ring2="Eshmun's Ring", waist="Gishdubar Sash"}

    sets.Obi = {waist="Hachirin-no-Obi"}
    sets.CP = {back="Mecistopins Mantle"}
    sets.Reive = {neck="Ygnas's Resolve +1"}

end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    -- Check that proper ammo is available if we're using ranged attacks or similar.
    if spell.action_type == 'Ranged Attack' or spell.type == 'WeaponSkill' or spell.type == 'CorsairShot' then
        do_bullet_checks(spell, spellMap, eventArgs)
    end

    -- Gear
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") then
        if player.status ~= 'Engaged' then
            equip(sets.precast.CorsairRoll.Gun)
        end
        if state.LuzafRing.value then
            equip(sets.precast.LuzafRing)
        end
    elseif spell.type == 'CorsairShot' and state.CastingMode.value == 'Resistant' then
        classes.CustomClass = 'Acc'
    end
    
    if spell.english == 'Fold' and buffactive['Bust'] == 2 then
        if sets.precast.FoldDoubleBust then
            equip(sets.precast.FoldDoubleBust)
            eventArgs.handled = true
        end
    end
    if spellMap == 'Utsusemi' then
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
            cancel_spell()
            add_to_chat(123, '**!! '..spell.english..' Canceled: [3+ IMAGES] !!**')
            eventArgs.handled = true
            return
        elseif buffactive['Copy Image'] or buffactive['Copy Image (2)'] then
            send_command('cancel 66; cancel 444; cancel Copy Image; cancel Copy Image (2)')
        end
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if (spell.type == 'CorsairRoll' or spell.english == "Double-Up") then
        if player.status ~= 'Engaged' then
            equip(sets.precast.CorsairRoll.Gun)
        end
    elseif spell.action_type == 'Ranged Attack' then
        if state.FlurryMode.value == 'Flurry II' and (buffactive[265] or buffactive[581]) then
            equip(sets.precast.RA.Flurry2)
        elseif state.FlurryMode.value == 'Flurry I' and (buffactive[265] or buffactive[581]) then
            equip(sets.precast.RA.Flurry1)
        end
    -- Equip obi if weather/day matches for WS.
    elseif spell.type == 'WeaponSkill' then
        if spell.english == 'Leaden Salute' then
            if world.weather_element == 'Dark' or world.day_element == 'Dark' then
                equip(sets.Obi)
            end
            if player.tp > 2900 then
                equip(sets.precast.WS['Leaden Salute'].FullTP)
            end    
        elseif spell.english == 'Wildfire' and (world.weather_element == 'Fire' or world.day_element == 'Fire') then
            equip(sets.Obi)
        end
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Equip obi if weather/day matches for Quick Draw.
    if spell.type == 'CorsairShot' then
        if (spell.element == world.day_element or spell.element == world.weather_element) and 
        (spell.english ~= 'Light Shot' and spell.english ~= 'Dark Shot') then
            equip(sets.Obi)
        end
        if state.QDMode.value == 'Magic Enhance' then
            equip(sets.midcast.CorsairShot.Enhance)
        elseif state.QDMode.value == 'STP' then
            equip(sets.midcast.CorsairShot.STP)
        end
    elseif spell.action_type == 'Ranged Attack' and buffactive['Triple Shot'] then
        equip(sets.TripleShot)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairRoll' and not spell.interrupted then
        display_roll_info(spell)
    end
    if spell.english == "Light Shot" then
        send_command('@timers c "Light Shot ['..spell.target.name..']" 60 down abilities/00195.png')
    end
end

function job_buff_change(buff,gain)
    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S{'haste', 'march', 'mighty guard', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
        determine_haste_group()
        customize_melee_set()
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end

--    if buffactive['Reive Mark'] then
--        if gain then           
--            equip(sets.Reive)
--            disable('neck')
--        else
--            enable('neck')
--        end
--    end

    if buff == "doom" then
        if gain then           
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist')
        else
            enable('ring1','ring2','waist')
            handle_equipping_gear(player.status)
        end
    end

end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if state.WeaponLock.value == true then
        disable('ranged')
    else
        enable('ranged')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if state.Gun.current == 'Death Penalty' then
        equip({ranged="Death Penalty"})
    elseif state.Gun.current == 'Fomalhaut' then
        equip({ranged="Fomalhaut"})
    elseif state.Gun.current == 'Anarchy +2' then
        equip({ranged="Anarchy +2"})
--    elseif state.Gun.current == 'Armageddon' then
--        equip({ranged="Armageddon"})
    end

    if state.CP.current == 'on' then
        equip(sets.CP)
        disable('back')
    else
        enable('back')
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.DualWield.value == true and player.sub_job == 'NIN' then
        meleeSet = set_combine(meleeSet, sets.LessDualWield)
    end

    return meleeSet
end


-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.

function job_update(cmdParams, eventArgs)
    determine_haste_group()
end

-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)
    if spell.type == 'CorsairShot' then
        if state.IgnoreTargetting.value == true then
            state.IgnoreTargetting:reset()
            eventArgs.handled = true
        end
        
        eventArgs.SelectNPCTargets = state.SelectqdTarget.value
    end
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''
    
    msg = msg .. '[ Offense/Ranged: '..state.OffenseMode.current
    
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    
    msg = msg .. '/' ..state.RangedMode.current .. ' ]'

    if state.WeaponskillMode.value ~= 'Normal' then
        msg = msg .. '[ WS: '..state.WeaponskillMode.current .. ' ]'
    end

    if state.DefenseMode.value ~= 'None' then
        msg = msg .. '[ Defense: ' .. state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ' ]'
    end
    
    if state.Kiting.value then
        msg = msg .. '[ Kiting Mode: ON ]'
    end

    msg = msg .. '[ ' .. state.HasteMode.value .. ' ][ ' .. state.FlurryMode.value .. ' ]'

    msg = msg .. '[ *'..state.Mainqd.current

    if state.UseAltqd.value == true then
        msg = msg .. '/'..state.Altqd.current
    end
    
    msg = msg .. '* '

    if state.QDMode.value == 'Magic Enhance' then
        msg = msg .. '(E)'
    end    

    msg = msg .. ']'
    
    add_to_chat(060, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- User self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'qd' then
        if cmdParams[2] == 't' then
            state.IgnoreTargetting:set()
        end

        local doqd = ''
        if state.UseAltqd.value == true then
            doqd = state[state.Currentqd.current..'qd'].current
            state.Currentqd:cycle()
        else
            doqd = state.Mainqd.current
        end        
        
        send_command('@input /ja "'..doqd..'" <t>')
    end
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()

    -- Gearswap can't detect the difference between Haste I and Haste II
    -- so use winkey-H to manually set Haste spell level.

    -- Haste (buffactive[33]) - 15%
    -- Haste II (buffactive[33]) - 30%
    -- Haste Samba - 5~10%
    -- Honor March - 12~16%
    -- Victory March - 15~28%
    -- Advancing March - 10~18%
    -- Embrava - 25%
    -- Mighty Guard (buffactive[604]) - 15%
    -- Geo-Haste (buffactive[580]) - 30~40%

    classes.CustomMeleeGroups:clear()

    if state.HasteMode.value == 'Haste II' then
        if(((buffactive[33] or buffactive[580] or buffactive.embrava) and (buffactive.march or buffactive[604])) or
            (buffactive[33] and (buffactive[580] or buffactive.embrava)) or
            (buffactive.march == 2 and buffactive[604]) or buffactive.march == 3) or buffactive[580] == 2 then
            --add_to_chat(122, 'Magic Haste Level: 43%')
            classes.CustomMeleeGroups:append('MaxHaste')
            state.DualWield:set()
        elseif ((buffactive[33] or buffactive.march == 2 or buffactive[580]) and buffactive['haste samba']) then
            --add_to_chat(122, 'Magic Haste Level: 35%')
            classes.CustomMeleeGroups:append('HighHaste')
            state.DualWield:set()
        elseif ((buffactive[580] or buffactive[33] or buffactive.march == 2) or
            (buffactive.march == 1 and buffactive[604])) then
            --add_to_chat(122, 'Magic Haste Level: 30%')
            classes.CustomMeleeGroups:append('MidHaste')
            state.DualWield:set()
        elseif (buffactive.march == 1 or buffactive[604]) then
            --add_to_chat(122, 'Magic Haste Level: 15%')
            classes.CustomMeleeGroups:append('LowHaste')
            state.DualWield:set()
        else
            state.DualWield:set(false)
        end
    else
        if (buffactive[580] and ( buffactive.march or buffactive[33] or buffactive.embrava or buffactive[604]) ) or
            (buffactive.embrava and (buffactive.march or buffactive[33] or buffactive[604])) or
            (buffactive.march == 2 and (buffactive[33] or buffactive[604])) or
            (buffactive[33] and buffactive[604] and buffactive.march ) or buffactive.march == 3 or buffactive[580] == 2 then
            --add_to_chat(122, 'Magic Haste Level: 43%')
            classes.CustomMeleeGroups:append('MaxHaste')
            state.DualWield:set()
        elseif ((buffactive[604] or buffactive[33]) and buffactive['haste samba'] and buffactive.march == 1) or
            (buffactive.march == 2 and buffactive['haste samba']) or
            (buffactive[580] and buffactive['haste samba'] ) then
            --add_to_chat(122, 'Magic Haste Level: 35%')
            classes.CustomMeleeGroups:append('HighHaste')
            state.DualWield:set()
        elseif (buffactive.march == 2 ) or
            ((buffactive[33] or buffactive[604]) and buffactive.march == 1 ) or  -- MG or haste + 1 march
            (buffactive[580] ) or  -- geo haste
            (buffactive[33] and buffactive[604]) then
            --add_to_chat(122, 'Magic Haste Level: 30%')
            classes.CustomMeleeGroups:append('MidHaste')
            state.DualWield:set()
        elseif buffactive[33] or buffactive[604] or buffactive.march == 1 then
            --add_to_chat(122, 'Magic Haste Level: 15%')
            classes.CustomMeleeGroups:append('LowHaste')
            state.DualWield:set()
        else
            state.DualWield:set(false)
        end
    end
end


function define_roll_values()
    rolls = {
        ["Corsair's Roll"]   = {lucky=5, unlucky=9, bonus="Experience Points"},
        ["Ninja Roll"]       = {lucky=4, unlucky=8, bonus="Evasion"},
        ["Hunter's Roll"]    = {lucky=4, unlucky=8, bonus="Accuracy"},
        ["Chaos Roll"]       = {lucky=4, unlucky=8, bonus="Attack"},
        ["Magus's Roll"]     = {lucky=2, unlucky=6, bonus="Magic Defense"},
        ["Healer's Roll"]    = {lucky=3, unlucky=7, bonus="Cure Potency Received"},
        ["Drachen Roll"]      = {lucky=4, unlucky=8, bonus="Pet Magic Accuracy/Attack"},
        ["Choral Roll"]      = {lucky=2, unlucky=6, bonus="Spell Interruption Rate"},
        ["Monk's Roll"]      = {lucky=3, unlucky=7, bonus="Subtle Blow"},
        ["Beast Roll"]       = {lucky=4, unlucky=8, bonus="Pet Attack"},
        ["Samurai Roll"]     = {lucky=2, unlucky=6, bonus="Store TP"},
        ["Evoker's Roll"]    = {lucky=5, unlucky=9, bonus="Refresh"},
        ["Rogue's Roll"]     = {lucky=5, unlucky=9, bonus="Critical Hit Rate"},
        ["Warlock's Roll"]   = {lucky=4, unlucky=8, bonus="Magic Accuracy"},
        ["Fighter's Roll"]   = {lucky=5, unlucky=9, bonus="Double Attack Rate"},
        ["Puppet Roll"]     = {lucky=3, unlucky=7, bonus="Pet Magic Attack/Accuracy"},
        ["Gallant's Roll"]   = {lucky=3, unlucky=7, bonus="Defense"},
        ["Wizard's Roll"]    = {lucky=5, unlucky=9, bonus="Magic Attack"},
        ["Dancer's Roll"]    = {lucky=3, unlucky=7, bonus="Regen"},
        ["Scholar's Roll"]   = {lucky=2, unlucky=6, bonus="Conserve MP"},
        ["Naturalist's Roll"]       = {lucky=3, unlucky=7, bonus="Enh. Magic Duration"},
        ["Runeist's Roll"]       = {lucky=4, unlucky=8, bonus="Magic Evasion"},
        ["Bolter's Roll"]    = {lucky=3, unlucky=9, bonus="Movement Speed"},
        ["Caster's Roll"]    = {lucky=2, unlucky=7, bonus="Fast Cast"},
        ["Courser's Roll"]   = {lucky=3, unlucky=9, bonus="Snapshot"},
        ["Blitzer's Roll"]   = {lucky=4, unlucky=9, bonus="Attack Delay"},
        ["Tactician's Roll"] = {lucky=5, unlucky=8, bonus="Regain"},
        ["Allies' Roll"]    = {lucky=3, unlucky=10, bonus="Skillchain Damage"},
        ["Miser's Roll"]     = {lucky=5, unlucky=7, bonus="Save TP"},
        ["Companion's Roll"] = {lucky=2, unlucky=10, bonus="Pet Regain and Regen"},
        ["Avenger's Roll"]   = {lucky=4, unlucky=8, bonus="Counter Rate"},
    }
end

function display_roll_info(spell)
    rollinfo = rolls[spell.english]
    local rollsize = (state.LuzafRing.value and 'Large') or 'Small'

    if rollinfo then
        add_to_chat(104, '[ Lucky: '..tostring(rollinfo.lucky)..' / Unlucky: '..tostring(rollinfo.unlucky)..' ] '..spell.english..': '..rollinfo.bonus..' ('..rollsize..') ')
    end
end


-- Determine whether we have sufficient ammo for the action being attempted.
function do_bullet_checks(spell, spellMap, eventArgs)
    local bullet_name
    local bullet_min_count = 1
    
    if spell.type == 'WeaponSkill' then
        if spell.skill == "Marksmanship" then
            if spell.english == 'Wildfire' or spell.english == 'Leaden Salute' then
                -- magical weaponskills
                bullet_name = gear.MAbullet
            else
                -- physical weaponskills
                bullet_name = gear.WSbullet
            end
        else
            -- Ignore non-ranged weaponskills
            return
        end
    elseif spell.type == 'CorsairShot' then
        bullet_name = gear.QDbullet
    elseif spell.action_type == 'Ranged Attack' then
        bullet_name = gear.RAbullet
        if buffactive['Triple Shot'] then
            bullet_min_count = 3
        end
    end
    
    local available_bullets = player.inventory[bullet_name] or player.wardrobe[bullet_name] or player.wardrobe4[bullet_name]
    
    -- If no ammo is available, give appropriate warning and end.
    if not available_bullets then
        if spell.type == 'CorsairShot' and player.equipment.ammo ~= 'empty' then
            add_to_chat(104, 'No Quick Draw ammo left.  Using what\'s currently equipped ('..player.equipment.ammo..').')
            return
        elseif spell.type == 'WeaponSkill' and player.equipment.ammo == gear.RAbullet then
            add_to_chat(104, 'No weaponskill ammo left.  Using what\'s currently equipped (standard ranged bullets: '..player.equipment.ammo..').')
            return
        else
            add_to_chat(104, 'No ammo ('..tostring(bullet_name)..') available for that action.')
            eventArgs.cancel = true
            return
        end
    end
    
    -- Don't allow shooting or weaponskilling with ammo reserved for quick draw.
    if spell.type ~= 'CorsairShot' and bullet_name == gear.QDbullet and available_bullets.count <= bullet_min_count then
        add_to_chat(104, 'No ammo will be left for Quick Draw.  Cancelling.')
        eventArgs.cancel = true
        return
    end
    
    -- Low ammo warning.
    if spell.type ~= 'CorsairShot' and state.warned.value == false
        and available_bullets.count > 1 and available_bullets.count <= options.ammo_warning_limit then
        local msg = '*****  LOW AMMO WARNING: '..bullet_name..' *****'
        --local border = string.repeat("*", #msg)
        local border = ""
        for i = 1, #msg do
            border = border .. "*"
        end
        
        add_to_chat(104, border)
        add_to_chat(104, msg)
        add_to_chat(104, border)

        state.warned:set()
    elseif available_bullets.count > options.ammo_warning_limit and state.warned then
        state.warned:reset()
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    if player.sub_job == 'DNC' then
        set_macro_page(1, 7)
    else
        set_macro_page(1, 7)
    end
end

function set_lockstyle()
    send_command('wait 5; input /lockstyleset 1')
end
-- MG library
local MG = require("mg-lib")

function user_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','AoE')
    state.IdleMode:options('Normal','PDT')
	state.Weapons:options('None','Aeneas','DualWeapons','DualSwords','DualNukeWeapons')

	-- Adjust this if using the Terpander (new +song instrument)
    info.ExtraSongInstrument = 'Daurdabla'
	-- How many extra songs we can keep from Daurdabla/Terpander
    info.ExtraSongs = 2
	
	-- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(false, 'Use Custom Timers')
	
	-- Additional local binds
    -- send_command('bind ^` gs c cycle ExtraSongsMode')
	-- send_command('bind !` input /ma "Chocobo Mazurka" <me>')
	-- send_command('bind @` gs c cycle MagicBurstMode')
	-- send_command('bind @f10 gs c cycle RecoverMode')
	-- send_command('bind @f8 gs c toggle AutoNukeMode')
	-- send_command('bind !q gs c weapons NukeWeapons;gs c update')
	-- send_command('bind ^q gs c weapons Swords;gs c update')

	send_command('bind ^f10 gs c cycle Weapons')

	select_default_macro_book()

	MG.hud.initialize({})
	MG.BardSongs({
		NumberOfExtraSongs=2,
		DefaultGroupName = "Melee songs",
		SongGroup2 = {
			name = "Ballads",
			songlist = {"Mage's Ballad III", "Mage's Ballad II", "Mage's Ballad"},
			defaults = {
				Song1 = "Mage's Ballad III",
				Song2 = "Mage's Ballad II",
				Song3 = "Mage's Ballad",
				Song4 = "None",
				CCSong = "None"
			},
			add_none_choice = true,
		}
	})

	send_command("input /lockstyleset 5")
end

function init_gear_sets()

	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	local AF = {
		head="Brioso Roundlet +1",
		feet="Brioso Slippers +2",
	}

	local relic = {
		body="Bihu Jstcorps +1",
		hands="Bihu Cuffs +1",
		legs="Bihu Cannions +1",
		feet="Bihu Slippers +1",
	}

	local empy = {
		head="Fili Calot +1",
		body="Fili Hongreline +1",
		hands="Fili Manchettes +1",
		legs="Fili Rhingrave +1",
		feet="Fili Cothurnes +1",
	}

	local ambu = {
		head="Aya. Zucchetto +2",
		body="Ayanmo Corazza +1",
		hands="Aya. Manopolas +1",
		legs="Aya. Cosciales +1",
		feet="Aya. Gambieras +2",
	}

	-- Weapons sets
	sets.weapons.Aeneas = {
		--main="Aeneas",
		main="Tauret",
		sub="Genmei Shield"
	}
	sets.weapons.DualWeapons = {
		main="Tauret",
		sub="Blurred Knife +1",
	}
	sets.weapons.DualSwords = {
		--main="Vampirism",
		--sub="Vampirism"
		main="Naegling",
		sub="Demers. Degen +1",
	}
	sets.weapons.DualNukeWeapons = {
		main={ name="Malevolence", augments={'INT+9','Mag. Acc.+10','"Mag.Atk.Bns."+9','"Fast Cast"+4',}},
		sub={ name="Malevolence", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+8','"Fast Cast"+5',}},
	}
	
	-- Precast Sets

	-- Fast cast sets for spells
	sets.precast.FC = {
		main={
			name="Grioavolr",
			augments={
				'"Fast Cast"+5',
				'MP+32',
				'Mag. Acc.+9',
				'Magic Damage +3',
			}
		},
		-- fc +14
		body="Inyanga Jubbah +2",
		-- fc +7
		hands="Gende. Gages +1",
		-- fc +4
		legs="Gyve Trousers",
		-- fc +6
		feet="Volte Gaiters",
		-- fc +4
		neck="Voltsurge Torque",
		-- fc +2
		waist="Channeler's Stone",
		-- fc +1
		left_ear="Etiolation Earring",
		-- fc +?
		right_ear="Loquac. Earring",
		-- fc +?
		left_ring="Prolix Ring",
		-- fc +4
		right_ring="Kishar Ring",
		-- fc +3
		back="Swith Cape +1",
	}

	sets.precast.FC.Cure = set_combine(sets.precast.FC, {
		feet="Vanya Clogs",
		-- cure casting time -15%
		legs="Doyen Pants",
		feet={ name="Vanya Clogs", augments={'"Cure" potency +5%','"Cure" spellcasting time -15%','"Conserve MP"+6',}},
		back="Pahtli Cape",
	})

	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
		--waist="Siegel Sash"
	})
	
	sets.precast.FC.BardSong = set_combine(sets.precast.FC, {
		main="Kali",
		sub="Genmei Shield",
		head="Fili Calot +1",
		range="Gjallarhorn",
		-- song casting time -6%
		legs="Doyen Pants",
		-- song casting time -6%
		feet="Telchine Pigaches",
	})

	sets.precast.FC.SongDebuff = set_combine(sets.precast.FC.BardSong,{
		range="Marsyas"
	})
	sets.precast.FC.SongDebuff.Resistant = set_combine(sets.precast.FC.BardSong,{
		range="Gjallarhorn"
	})
	sets.precast.FC.Lullaby = {
		range="Marsyas"
	}
	sets.precast.FC.Lullaby.Resistant = {
		range="Gjallarhorn"
	}
	sets.precast.FC['Horde Lullaby'] = {
		range="Marsyas"
	}
	sets.precast.FC['Horde Lullaby'].Resistant = {
		range="Gjallarhorn"
	}
	sets.precast.FC['Horde Lullaby'].AoE = {
		range="Gjallarhorn"
	}
	sets.precast.FC['Horde Lullaby II'] = {
		range="Marsyas"
	}
	sets.precast.FC['Horde Lullaby II'].Resistant = {
		range="Gjallarhorn"
	}
	sets.precast.FC['Horde Lullaby II'].AoE = {
		range="Gjallarhorn"
	}
		
	sets.precast.FC.Mazurka = set_combine(sets.precast.FC.BardSong,{
		range="Marsyas"
	})
	sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong,{
		range="Marsyas"
	})

	sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {
		range=info.ExtraSongInstrument
	})
	sets.precast.DaurdablaDummy = sets.precast.FC.Daurdabla
		
	
	-- Precast sets to enhance JAs
	
	sets.precast.JA.Nightingale = {
		feet=relic.feet
	}
	sets.precast.JA.Troubadour = {
		body=relic.body
	}
	sets.precast.JA['Soul Voice'] = {
		legs=relic.legs
	}

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {
		head=ambu.head,
		--neck="Caro Necklace",
		ear1="Moonshade Earring",
		ear2="Ishvara Earring",
		body=ambu.body,
		hands=ambu.hands,
		--ring1="Ramuh Ring +1",
		ring2="Ilabrat Ring",
		--back="Ground. Mantle +1",
		--waist="Grunfeld Rope",
		legs=ambu.legs,
		feet=ambu.feet,
	}
		
	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {
		ear1="Ishvara Earring",
		--ear2="Telos Earring",
	}
	sets.AccMaxTP = {
		--ear1="Zennaroi Earring",
		--ear2="Telos Earring"
	}

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.


	-- Midcast Sets

	-- General set for recast times.
	sets.midcast.FastRecast = {
		main=gear.grioavolr_fc_staff,
		sub="Clerisy Strap",
		--head="Nahtirah Hat",
		neck="Voltsurge Torque",
		--ear1="Enchntr. Earring +1",
		ear2="Loquacious Earring",
		body="Inyanga Jubbah +2",
		--hands="Leyline Gloves",
		ring2="Kishar Ring",
		--ring1="Lebeche Ring",
		--back="Intarabus's Cape",
		--waist="Witful Belt",
		legs=ambu.legs,
		--feet="Gende. Galosh. +1"
	}

	-- Gear to enhance certain classes of songs
	sets.midcast.Ballad = {
		legs=empy.legs,
	}
	sets.midcast.Lullaby = {
		range="Marsyas"
	}
	sets.midcast.Lullaby.Resistant = {
		range="Gjallarhorn"
	}
	sets.midcast['Horde Lullaby'] = {
		range="Marsyas"
	}
	sets.midcast['Horde Lullaby'].Resistant = {
		range="Gjallarhorn"
	}
	sets.midcast['Horde Lullaby'].AoE = {
		range="Gjallarhorn"
	}
	sets.midcast['Horde Lullaby II'] = {
		range="Marsyas"
	}
	sets.midcast['Horde Lullaby II'].Resistant = {
		range="Gjallarhorn"
	}
	sets.midcast['Horde Lullaby II'].AoE = {
		range="Gjallarhorn"
	}
	sets.midcast.Madrigal = {
		head=empy.head
	}
	sets.midcast.Paeon = {}
	sets.midcast.March = {
		hands=empy.hands
	}
	sets.midcast['Honor March'] = set_combine(sets.midcast.March,{
		range="Marsyas"
	})
	sets.midcast.Minuet = {
		body=empy.body
	}
	sets.midcast.Minne = {}
	sets.midcast.Carol = {}
	sets.midcast["Sentinel's Scherzo"] = {} 
	sets.midcast['Magic Finale'] = {
		range="Gjallarhorn"
	}
	sets.midcast.Mazurka = {
		range="Marsyas"
	}
	

	-- For song buffs (duration and AF3 set bonus)
	sets.midcast.SongEffect = {
		main="Kali",
		sub="Genmei Shield",
		head=AF.head,
		neck="Moonbow whistle",
		ear2="Loquacious Earring",
		--ear1="Musical earring",
		body=empy.body,
		hands=empy.hands,
		--back="Intarabus's cape",
		--waist="Harfner's sash",
		legs="Inyanga Shalwar +2",
		feet=AF.feet,
	}
		
	sets.midcast.SongEffect.DW = {}

	-- For song defbuffs (duration primary, accuracy secondary)
	sets.midcast.SongDebuff = {
		ain="Kali",
		sub="Ammurapi Shield",
		range="Marsyas",
		--ammo=empty,
		head=ambu.head,
		neck="Moonbow Whistle",
		--ear1="Gwati Earring",
		ear2="Digni. Earring",
		body=empy.body,
		--hands="Inyan. Dastanas +2",
		--ring1="Stikini Ring",
		--ring2="Stikini Ring",
		--back="Intarabus's Cape",
		waist="Luminary Sash",
		legs="Inyanga Shalwar +2",
		feet=AF.feet,
	}

	-- For song defbuffs (accuracy primary, duration secondary)
	sets.midcast.SongDebuff.Resistant = {
		main="Kali",
		sub="Ammurapi Shield",
		range="Gjallarhorn",
		--ammo=empty,
		head=ambu.head,
		neck="Moonbow Whistle",
		--ear1="Gwati Earring",
		ear2="Digni. Earring",
		body="Inyanga Jubbah +2",
		--hands="Inyan. Dastanas +2",
		--ring1="Stikini Ring",
		--ring2="Stikini Ring",
		--back="Intarabus's Cape",
		waist="Luminary Sash",
		legs="Inyanga Shalwar +2",
		feet=ambu.feet,
	}

	-- Song-specific recast reduction
	sets.midcast.SongRecast = {
		main=gear.grioavolr_fc_staff,
		sub="Clerisy Strap",
		range="Gjallarhorn",
		--ammo=empty,
		--head="Nahtirah Hat",
		neck="Voltsurge Torque",
		--ear1="Enchntr. Earring +1",
		ear2="Loquacious Earring",
		body="Inyanga Jubbah +2",
		--hands="Gendewitha Gages +1",
		ring2="Kishar Ring",
		ring1="Prolix Ring",
		--back="Intarabus's Cape",
		--waist="Witful Belt",
		legs=empy.legs,
		feet=ambu.feet,
	}
		
	sets.midcast.SongDebuff.DW = {}

	-- Cast spell with normal gear, except using Daurdabla instead
    sets.midcast.Daurdabla = {
		range=info.ExtraSongInstrument
	}

	-- Dummy song with Daurdabla; minimize duration to make it easy to overwrite.
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.SongRecast, {
		range=info.ExtraSongInstrument
	})

	-- Other general spells and classes.
	sets.midcast.Cure = {
		main="Daybreak",
		sub="Genmei Shield",
		--head="Gende. Caubeen",
		neck="Nodens Gorget",
		--ear1="Gifted Earring",
		ear2="Mendi. Earring",
		--body="Gendewitha bliaut",
		hands={ name="Telchine Gloves", augments={'"Cure" potency +4%','Enh. Mag. eff. dur. +10',}},
		--ring1="Ephedra ring",
		--ring2="Menelaus's Ring",
		back="Solemnity Cape",
		waist="Bishop's sash",
		legs="Gyve Trousers",
		feet={ name="Vanya Clogs", augments={'"Cure" potency +5%','"Cure" spellcasting time -15%','"Conserve MP"+6',}},
	}
		
	sets.Self_Healing = {
		--neck="Phalaina Locket",
		--hands="Buremte Gloves",
		--ring2="Kunaji Ring",
		--waist="Gishdubar Sash"
	}
	sets.Cure_Received = {
		--neck="Phalaina Locket",
		--hands="Buremte Gloves",
		--ring2="Kunaji Ring",
		--waist="Gishdubar Sash"
	}
	sets.Self_Refresh = {
		--back="Grapevine Cape",
		--waist="Gishdubar Sash"
	}
		
	sets.midcast['Enhancing Magic'] = {
		--main="Serenity",
		--sub="Fulcio Grip",
		head="Telchine Cap",
		neck="Voltsurge Torque",
		ear1="Andoaa Earring",
		--ear2="Gifted Earring",
		body="Telchine Chas.",
		hands="Telchine Gloves",
		--ring1="Stikini Ring",
		--ring2="Stikini Ring",
		--back="Intarabus's Cape",
		--waist="Witful Belt",
		legs="Telchine Braconi",
		feet="Telchine Pigaches"
	}
		
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
		neck="Nodens Gorget",
		--ear2="Earthcry Earring",
		--waist="Siegel Sash",
		--legs="Shedir Seraweels"
	})
		
	sets.midcast['Elemental Magic'] = {
		--main="Marin Staff +1",
		--sub="Zuuxowu Grip",
		--ammo="Dosis Tathlum",
		--head="Buremte Hat",
		neck="Sanctity Necklace",
		ear1="Friomisi Earring",
		--ear2="Crematio Earring",
		--body="Chironic Doublet",
		hands="Volte Gloves",
		ring1="Shiva Ring +1",
		ring2="Shiva Ring +1",
		--back="Toro Cape",
		--waist="Sekhmet Corset",
		legs="Gyve Trousers",
		feet=gear.chironic_nuke_feet
	}
		
	sets.midcast['Elemental Magic'].Resistant = {
		--main="Marin Staff +1",
		sub="Clerisy Strap",
		--ammo="Dosis Tathlum",
		--head="Buremte Hat",
		neck="Sanctity Necklace",
		ear1="Friomisi Earring",
		--ear2="Crematio Earring",
		--body="Chironic Doublet",
		hands="Volte Gloves",
		ring1="Shiva Ring +1",
		--ring2="Shiva Ring +1",
		--back="Toro Cape",
		--waist="Yamabuki-no-Obi",
		legs="Gyve Trousers",
		feet=gear.chironic_nuke_feet
	}
		
	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {
		--neck="Debilis Medallion",
		--hands="Hieros Mittens",
		--ring1="Haoma's Ring",
		--ring2="Menelaus's Ring",
		--waist="Witful Belt",
		feet="Vanya Clogs"
	})
		
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
		main=gear.grioavolr_fc_staff,
		--sub="Clemency Grip"
	})

	-- Resting sets
	sets.resting = {
		--head=empty,
		neck="Loricate Torque +1",
		ear1="Etiolation Earring",
		--ear2="Ethereal Earring",
		--body="Respite Cloak",
		hands=gear.chironic_refresh_hands,
		ring1="Defending Ring",
		--ring2="Dark Ring",
		--back="Umbra Cape",
		--waist="Flume Belt",
		--legs="Assid. Pants +1",
		feet=gear.chironic_refresh_feet
	}
	
	sets.idle = {
		main="Naegling",
		sub="Genmei Shield",
		head=ambu.head,
		legs=ambu.legs,
		feet=ambu.feet,
		neck="Loricate Torque +1",
		ear1="Etiolation Earring",
		--ear2="Ethereal Earring",
		body=ambu.body,
		hands=ambu.hands,
		left_ring="Defending Ring",
		right_ring="Vocane Ring",
		back="Solemnity Cape",
		--back="Umbra Cape",
		--waist="Flume Belt",
		--legs="Assid. Pants",
		feet=empy.feet,
	}

	sets.idle.PDT ={
		main="Naegling",
		sub="Genmei Shield",
		legs=ambu.legs,
		feet=ambu.feet,
		head=ambu.head,
		neck="Loricate Torque +1",
		ear1="Etiolation Earring",
		--ear2="Ethereal Earring",
		body=ambu.body,
		hands=ambu.hands,
		left_ring="Defending Ring",
		right_ring="Vocane Ring",
		back="Solemnity Cape",
		--back="Umbra Cape",
		--waist="Flume Belt",
		--legs="Assid. Pants",
		feet=empy.feet,
	}
	
	-- Defense sets

	sets.defense.PDT = {
		main="Naegling",
		sub="Genmei Shield",
		--main="Terra's Staff",
		--sub="Umbra Strap",
		ammo="Staunch Tathlum",
		head="Hike Khat",
		body="Inyanga Jubbah +2",
		hands="Volte Gloves",
		legs=ambu.legs,
		feet=ambu.feet,
		neck="Loricate Torque +1",
		ear1="Etiolation Earring",
		--ear2="Ethereal Earring",
		--body="Respite Cloak",
		hands=gear.chironic_refresh_hands,
		left_ring="Defending Ring",
		right_ring="Vocane Ring",
		back="Solemnity Cape",
		--back="Umbra Cape",
		--waist="Flume Belt",
		--legs="Assid. Pants +1",
		feet=gear.chironic_refresh_feet
	}

	sets.defense.MDT = {
		main="Naegling",
		sub="Genmei Shield",
		--main="Terra's Staff",
		--sub="Umbra Strap",
		ammo="Staunch Tathlum",
		head="Hike Khat",
		body="Inyanga Jubbah +2",
		hands="Volte Gloves",
		legs=ambu.legs,
		feet=ambu.feet,
		neck="Loricate Torque +1",
		ear1="Etiolation Earring",
		--ear2="Ethereal Earring",
		--body="Respite Cloak",
		hands=gear.chironic_refresh_hands,
		left_ring="Defending Ring",
		right_ring="Vocane Ring",
		back="Solemnity Cape",
		--back="Umbra Cape",
		--waist="Flume Belt",
		--legs="Assid. Pants +1",
		feet=gear.chironic_refresh_feet
	}

	sets.Kiting = {
		feet=empy.feet,
	}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	sets.engaged = {
		main="Tauret",
		sub="Genmei Shield",
		--ammo="Ginsen",
		head=ambu.head,
		neck="Sanctity Necklace",
		--neck="Asperity Necklace",
		ear1="Cessance Earring",
		ear2="Brutal Earring",
		body=ambu.body,
		hands=ambu.hands,
		ring1="Petrov Ring",
		ring2="Ilabrat Ring",
		back="Kayapa Cape",
		--back="Bleating Mantle",
		waist="Windbuffet Belt +1",
		legs=ambu.legs,
		feet=ambu.feet,
	}
	sets.engaged.Acc = {
		--main="Aeneas",
		sub="Genmei Shield",
		--ammo="Ginsen",
		head=ambu.head,
		neck="Sanctity Necklace",
		--neck="Combatant's Torque",
		ear1="Digni. Earring",
		--ear2="Telos Earring",
		body=ambu.body,
		hands=ambu.hands,
		--ring1="Ramuh Ring +1",
		ring2="Ilabrat Ring",
		back="Kayapa Cape",
		--back="Letalis Mantle",
		waist="Olseni Belt",
		legs=ambu.legs,
		feet=ambu.feet,
	}
	sets.engaged.DW = {
		--main="Aeneas",
		sub="Blurred Knife +1",
		--ammo="Ginsen",
		head=ambu.head,
		neck="Sanctity Necklace",
		--neck="Asperity Necklace",
		ear1="Suppanomimi",
		ear2="Brutal Earring",
		body=ambu.body,
		hands=ambu.hands,
		ring1="Petrov Ring",
		ring2="Ilabrat Ring",
		back="Kayapa Cape",
		--back="Bleating Mantle",
		--waist="Reiki Yotai",
		legs=ambu.legs,
		feet=ambu.feet,
	}
	sets.engaged.DW.Acc = {
		--main="Aeneas",
		sub="Blurred Knife +1",
		--ammo="Ginsen",
		head=ambu.head,
		neck="Sanctity Necklace",
		--neck="Combatant's Torque",
		ear1="Suppanomimi",
		--ear2="Telos Earring",
		body=ambu.body,
		hands=ambu.hands,
		--ring1="Ramuh Ring +1",
		ring2="Ilabrat Ring",
		back="Kayapa Cape",
		--back="Bleating Mantle",
		--waist="Reiki Yotai",
		legs=ambu.legs,
		feet=ambu.feet,
	}


	-- Dummy songs for use with cureplease
	sets.precast["Fire Carol"] = sets.precast.Daurdabla
	sets.midcast["Fire Carol"] = sets.midcast.Daurdabla
	sets.precast["Ice Carol"] = sets.precast.Daurdabla
	sets.midcast["Ice Carol"] = sets.midcast.Daurdabla
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	set_macro_page(1, 3)
end
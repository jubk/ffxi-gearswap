
--[[
        Custom commands:
    
        Toggle Function: 
        gs c toggle melee               Toggle Melee mode on / off and locking of weapons
        gs c toggle mb                  Toggles Magic Burst Mode on / off.
        gs c toggle runspeed            Toggles locking on / off Herald's Gaiters
        gs c toggle idlemode            Toggles between Refresh and DT idle mode. Activating Sublimation JA will auto replace refresh set for sublimation set. DT set will superceed both.        
        gs c toggle regenmode           Toggles between Hybrid, Duration and Potency mode for regen set  
        gs c toggle nukemode            Toggles between Normal and Accuracy mode for midcast Nuking sets (MB included)  
        gs c toggle matchsc             Toggles auto swapping element to match the last SC that just happenned.
		
        Casting functions:
        these are to set fewer macros (2 cycle, 5 cast) to save macro space when playing lazily with controler
        
        gs c nuke cycle              	Cycles element type for nuking & SC
        gs c nuke cycledown				Cycles element type for nuking & SC	in reverse order
        gs c nuke t1                    Cast tier 1 nuke of saved element 
        gs c nuke t2                    Cast tier 2 nuke of saved element 
        gs c nuke t3                    Cast tier 3 nuke of saved element 
        gs c nuke t4                    Cast tier 4 nuke of saved element 
        gs c nuke t5                    Cast tier 5 nuke of saved element 
        gs c nuke ra1                   Cast tier 1 -ra nuke of saved element 
        gs c nuke ra2                   Cast tier 2 -ra nuke of saved element 
        gs c nuke ra3                   Cast tier 3 -ra nuke of saved element 	
		
        gs c geo geocycle				Cycles Geomancy Spell
        gs c geo geocycledown			Cycles Geomancy Spell in reverse order
        gs c geo indicycle				Cycles IndiColure Spell
        gs c geo indicycledown			Cycles IndiColure Spell in reverse order
        gs c geo geo					Cast saved Geo Spell
        gs c geo indi					Cast saved Indi Spell

        HUD Functions:
        gs c hud hide                   Toggles the Hud entirely on or off
        gs c hud hidemode               Toggles the Modes section of the HUD on or off
        gs c hud hidejob                Toggles the job section of the HUD on or off
        gs c hud hidebattle             Toggles the Battle section of the HUD on or off
        gs c hud lite                   Toggles the HUD in lightweight style for less screen estate usage. Also on ALT-END
        gs c hud keybinds               Toggles Display of the HUD keybindings (my defaults) You can change just under the binds in the Gearsets file.

        // OPTIONAL IF YOU WANT / NEED to skip the cycles...  
        gs c nuke Ice                   Set Element Type to Ice DO NOTE the Element needs a Capital letter. 
        gs c nuke Air                   Set Element Type to Air DO NOTE the Element needs a Capital letter. 
        gs c nuke Dark                  Set Element Type to Dark DO NOTE the Element needs a Capital letter. 
        gs c nuke Light                 Set Element Type to Light DO NOTE the Element needs a Capital letter. 
        gs c nuke Earth                 Set Element Type to Earth DO NOTE the Element needs a Capital letter. 
        gs c nuke Lightning             Set Element Type to Lightning DO NOTE the Element needs a Capital letter. 
        gs c nuke Water                 Set Element Type to Water DO NOTE the Element needs a Capital letter. 
        gs c nuke Fire                  Set Element Type to Fire DO NOTE the Element needs a Capital letter. 
--]]


-- Gear with augments
local aug_gear = require('shared/aug_gear');

-- include('organizer-lib') -- Remove if you dont use Organizer

--------------------------------------------------------------------------------------------------------------
res = require('resources')      -- leave this as is    
texts = require('texts')        -- leave this as is    
include('Modes.lua')            -- leave this as is      
--------------------------------------------------------------------------------------------------------------

-- Define your modes: 
-- You can add or remove modes in the table below, they will get picked up in the cycle automatically. 
-- to define sets for idle if you add more modes, name them: sets.me.idle.mymode and add 'mymode' in the group.
-- to define sets for regen if you add more modes, name them: sets.midcast.regen.mymode and add 'mymode' in the group.
-- Same idea for nuke modes. 
idleModes = M('normal', 'dt', 'mdt')
-- To add a new mode to nuking, you need to define both sets: sets.midcast.nuking.mynewmode as well as sets.midcast.MB.mynewmode
nukeModes = M('normal', 'acc')

-- Setting this to true will stop the text spam, and instead display modes in a UI.
-- Currently in construction.
use_UI = true
hud_x_pos = 1510    --important to update these if you have a smaller screen
hud_y_pos = 230     --important to update these if you have a smaller screen
hud_draggable = true
hud_font_size = 10
hud_transparency = 200 -- a value of 0 (invisible) to 255 (no transparency at all)
hud_font = 'Impact'

windower.send_command('bind ^f9 gs c toggle idlemode')
windower.send_command('bind ^f10 gs c toggle nukemode')
windower.send_command('bind ^f11 gs c toggle mb')
windower.send_command('bind ^f12 gs c toggle runspeed')

keybinds_on = {}
keybinds_on['key_bind_idle'] = '(CTRL-9)'
keybinds_on['key_bind_casting'] = '(CTRL-F10)'
keybinds_on['key_bind_mburst'] = '(CTRL-F11)'
keybinds_on['key_bind_movespeed_lock'] = '(CTRL-F12)'

-- Remember to unbind your keybinds on job change.
function user_unload()
end

--------------------------------------------------------------------------------------------------------------
include('GEO_Lib.lua')          -- leave this as is     
--------------------------------------------------------------------------------------------------------------

geomancy:set('Geo-Frailty')     -- Geo Spell Default      (when you first load lua / change jobs the saved spells is this one)
indicolure:set('Indi-Haste')    -- Indi Spell Default     (when you first load lua / change jobs the saved spells is this one)
validateTextInformation()

-- Optional. Swap to your geo macro sheet / book
set_macros(1,5) -- Sheet, Book   
    
-- Setup your Gear Sets below:
function get_sets()

    AF = {
        head="Geo. Galero +2",
        body="Geomancy Tunic +2",
        hands="Geo. Mitaines +2",
        legs="Geomancy Pants +2",
        feet="Geo. Sandals +3",
    }
    relic = {
        head = "Bagua Galero +2",
        body = "Bagua Tunic +3",
        hands = "Bagua Mitaines +2",
        legs = "Bagua Pants +2",
        feet = "Bagua Sandals +2",
    }
    empy = {
        head = "Azimuth Hood +1",
        body = "Azimuth Coat +1",
        hands = "Azimuth Gloves +1",
        legs = "Azimuth Tights +1",
        feet = "Azimuth Gaiters +1",
    }
    capes = {}
    capes.geomancy_skill = {
        name="Lifestream Cape",
        augments={
            'Geomancy Skill +10',
            'Indi. eff. dur. +11',
            'Pet: Damage taken -5%',
        }
    }
    capes.pet_dt = capes.geomancy_skill
    capes.fastcast = capes.geomancy_skill
  
    -- My formatting is very easy to follow. All sets that pertain to my character doing things are under 'me'.
    -- All sets that are equipped to faciliate my.pan's behaviour or abilities are under .pan', eg, Perpetuation, Blood Pacts, etc
      
    sets.me = {}        -- leave this empty
    sets.pan = {}       -- leave this empty
    sets.me.idle = {}	-- leave this empty
    sets.pan.idle = {}	-- leave this empty

    -- sets starting with sets.me means you DONT have a luopan currently out.
    -- sets starting with sets.pan means you DO have a luopan currently out.

    -- Your idle set when you DON'T have a luopan out
    sets.me.idle.normal = {
        head="Befouled Crown",
        body="Jhakri Robe +2",
        hands=relic.hands,
        legs="Assiduity Pants",
        feet=relic.feet,
        neck="Loricate Torque +1",
        waist="Isa Belt",
        left_ear="Merman's Earring",
        right_ear="Moonshade Earring",
        left_ring="Patricius Ring",
        right_ring="Defending Ring",
        back=capes.pet_dt,
    }
	
    -- This or herald gaiters or +1 +2 +3...
    sets.me.movespeed = {feet=AF.feet}
	
    -- Your idle MasterDT set (Notice the sets.me, means no Luopan is out)
    sets.me.idle.dt = set_combine(sets.me.idle.normal,{
        -- def 107, mdef 5
        head=AF.head,
        -- pdt -3
        body="Vrikodara Jupon",
        -- pdt -2
        hands=AF.hands,
        -- mdt -2
        legs="Gyve Trousers",
        -- pdt -4
        feet=empy.feet,
        -- dt -6
        neck="Loricate Torque +1",
        -- mdt -2
        left_ear="Merman's Earring",
        -- mdt -2
        right_ear="Odnowa Earring +1",
        -- pdt -5
        left_ring="Patricius Ring",
        -- dt -10
        right_ring="Defending Ring",
        -- dt -4
        back="Solemnity Cape",
    })
    sets.me.idle.mdt = set_combine(sets.me.idle.dt,{

    })	
    -- Your MP Recovered Whilst Resting Set
    sets.me.resting = { 
        body="Errant Hpl.",
        neck="Eidolon Pendant",
        hands="Oracle's Gloves",
        feet="Oracle's Pigaches",
        waist="Shinjutsu-no-Obi +1",
        left_ear="Antivenom Earring",
    }
	
    sets.me.latent_refresh = {
        -- waist="Fucho-no-obi"
    }
	
	
    -----------------------
    -- Luopan Perpetuation
    -----------------------
      
    -- Luopan's Out --  notice sets.pan 
    -- This is the base for all perpetuation scenarios, as seen below
    sets.pan.idle.normal = {
        -- refresh +1
        head="Befouled Crown",
        -- refresh +4
        body="Jhakri Robe +2",
        -- refresh +1
        hands=relic.hands,
        -- refresh +1
        legs="Assiduity Pants",
        feet=empy.feet,
        neck="Loricate Torque +1",
        waist="Isa Belt",
        left_ear="Merman's Earring",
        right_ear="Odnowa Earring +1",
        left_ring="Patricius Ring",
        right_ring="Defending Ring",
        back=capes.pet_dt,
    }
	
    -- This is when you have a Luopan out but want to sacrifice some slot for master DT, put those slots in.
    sets.pan.idle.dt = set_combine(sets.pan.idle.normal,{
        head=empy.head,
        body="Vrikodara Jupon",
        legs="Gyve Trousers",
    })   
    sets.pan.idle.mdt = set_combine(sets.pan.idle.normal,{
        head=empy.head,
        body="Vrikodara Jupon",
        legs="Gyve Trousers",
    })   
    -- Combat Related Sets
      
    -- Melee
    -- Anything you equip here will overwrite the perpetuation/refresh in that slot.
	-- No Luopan out
	-- they end in [idleMode] so it will derive from either the normal or the dt set depending in which mode you are then add the pieces filled in below.
    sets.me.melee = set_combine(sets.me.idle[idleMode],{

    })
	
    -- Luopan is out
    sets.pan.melee = set_combine(sets.pan.idle[idleMode],{

    }) 
    
    -- Weapon Skill sets
	-- Example:
    sets.me["Flash Nova"] = {

    }

    sets.me["Realmrazer"] = {

    }
	
    sets.me["Exudation"] = {

    } 
    -- Feel free to add new weapon skills, make sure you spell it the same as in game.
  
    ---------------
    -- Casting Sets
    ---------------
      
    sets.precast = {}               -- leave this empty    
    sets.midcast = {}               -- leave this empty    
    sets.aftercast = {}             -- leave this empty    
    sets.midcast.nuking = {}        -- leave this empty
    sets.midcast.MB = {}            -- leave this empty    
    ----------
    -- Precast
    ----------
      
    -- Generic Casting Set that all others take off of. Here you should add all your fast cast  
    sets.precast.casting = {
        -- Fast cast +8
        head="Merlinic Hood",
        -- Fast cast +8
        body="Shango Robe",
        -- Fast cast +13
        legs=AF.legs,
        -- Fast cast +4-6
        feet="Regal Pumps",
        -- Fast cast +2
        waist="Channeler's Stone",
        -- Fast cast +2
        left_ear="Loquac. Earring",
        -- Fast cast +2
        left_ring="Prolix Ring",
        -- Fast cast +4
        right_ring="Kishar Ring",
        -- Fast cast +7
        back=capes.fastcast,
    }   

    sets.precast.geomancy = set_combine(sets.precast.casting,{
        
    })
    -- Enhancing Magic, eg. Siegal Sash, etc
    sets.precast.enhancing = set_combine(sets.precast.casting,{
        -- enhancing magic time -8%
        waist="Siegel Sash",
    })
  
    -- Stoneskin casting time -, works off of enhancing -
    sets.precast.stoneskin = set_combine(sets.precast.enhancing,{

    })
      
    -- Curing Precast, Cure Spell Casting time -
    sets.precast.cure = set_combine(sets.precast.casting,{
        -- Cure magic time -7%
        body="Vanya Robe",
        -- Cure magic time -3%
        left_ear="Mendi. Earring",
        -- Cure magic time -8%
        back="Pahtli Cape",
        -- Cure casting time -15%
        feet="Vanya Clogs",
        -- Healing magic time -5%
        back="Disperser's Cape",
    })
    sets.precast.regen = set_combine(sets.precast.casting,{

    })     
    ---------------------
    -- Ability Precasting
    ---------------------
	
	-- Fill up with your JSE! 
    sets.precast["Life Cycle"] = {
    	body = AF.body,
    }
    sets.precast["Bolster"] = {
    	body = relic.body,
    }
    sets.precast["Primeval Zeal"] = {
    	head = relic.head,
    }  
    sets.precast["Cardinal Chant"] = {
    	head = AF.head,
    }  
    sets.precast["Full Circle"] = {
    	head = empy.head,
    }  
    sets.precast["Curative Recantation"] = {
    	hands = relic.hands,
    }  
    sets.precast["Mending Halation"] = {
    	legs = relic.legs,
    }
    sets.precast["Radial Arcana"] = {
    	feet = relic.feet,
    }

    ----------
    -- Midcast
    ----------
            
    -- Whatever you want to equip mid-cast as a catch all for all spells, and we'll overwrite later for individual spells
    sets.midcast.casting = {

    }
	
	-- For Geo spells /
    sets.midcast.geo = set_combine(sets.midcast.casting,{
        -- Geomancy +15
        head=empy.head,
        -- Set bonus
        body=empy.body,
        -- Set bonus
        hands=empy.hands,
        -- Indi duration +12
        legs=relic.legs,
        -- Indi duration +20, set bonus
        feet=empy.feet,
        -- Geomancy +10
        neck="Deceiver's Torque",
        -- Geomancy +15
        back=capes.geomancy_skill,
    })
	-- For Indi Spells
    sets.midcast.indi = set_combine(sets.midcast.geo,{
    })

    sets.midcast.Obi = {
        waist="Hachirin-no-Obi",
    }
	
	-- Nuking
    sets.midcast.nuking.normal = set_combine(sets.midcast.casting,{
        -- matk +50 (aug), macc +40 (aug)
        head=aug_gear.nuke.head,
        -- macc 40, matk 63
        body=relic.body,
        -- macc 43, matk 40
        hands="Jhakri Cuffs +2",
        -- macc 40 (aug), matk 13 (aug), mdam 13
        legs="Merlinic Shalwar",
        -- macc 42, matk 39
        feet="Jhakri Pigaches +2",
        -- macc 10, matk 10
        neck="Sanctity Necklace",
        -- macc 4, matk 10
        waist="Refoccilation Stone",
        -- matk 8, macc 8
        left_ear="Barkaro. Earring",
        -- matk 10
        right_ear="Friomisi Earring",
        -- macc 6, matk 3, mb bonus 2
        left_ring="Jhakri Ring",
        -- MB bonus
        right_ring="Mujin Band",
    })
    sets.midcast.MB.normal = set_combine(sets.midcast.nuking.normal, {

    })
    sets.midcast.nuking.acc = set_combine(sets.midcast.nuking.normal,{

    })
    sets.midcast.MB.acc = set_combine(sets.midcast.MB.normal, {

    })

	-- Enfeebling
    sets.midcast.IntEnfeebling = set_combine(sets.midcast.casting,{
        -- macc 40
        head=aug_gear.nuke.head,
        -- macc 46
        body="Jhakri Robe +2",
        -- macc 43
        hands="Jhakri Cuffs +2",
        -- macc 45
        legs="Jhakri Slops +2",
        -- macc 46
        feet="Geo. Sandals +3",
        -- macc 10
        neck="Sanctity Necklace",
        -- macc 7
        waist="Eschan Stone",
        -- macc 8
        left_ear="Barkaro. Earring",
        -- macc 10
        right_ear="Digni. Earring",
        -- macc 6
        left_ring="Jhakri Ring",
        -- macc 5
        right_ring="Vertigo Ring",
        -- macc 5
        back="Izdubar Mantle",
    })
    sets.midcast.MndEnfeebling = set_combine(sets.midcast.casting,{
        -- macc 40
        head=aug_gear.nuke.head,
        -- macc 46
        body="Jhakri Robe +2",
        -- macc 43
        hands="Jhakri Cuffs +2",
        -- macc 45
        legs="Jhakri Slops +2",
        -- macc 46
        feet="Geo. Sandals +3",
        -- macc 10
        neck="Sanctity Necklace",
        -- macc 7
        waist="Eschan Stone",
        -- macc 8
        left_ear="Barkaro. Earring",
        -- macc 10
        right_ear="Digni. Earring",
        -- macc 6
        left_ring="Jhakri Ring",
        -- macc 5
        right_ring="Vertigo Ring",
        -- macc 5
        back="Izdubar Mantle",
    })

    -- Enhancing
    sets.midcast.enhancing = set_combine(sets.midcast.casting,{
        -- Conserver MP 3
        head="Selenian Cap",
        -- Enh. skill 12
        body="Telchine Chas.",
        -- Buffs stoneskin
        waist="Siegel Sash",
        -- enmity -3, MND
        left_ring="Tamas Ring",
        -- enmity -7
        right_ring="Janniston Ring",
    })
	
    -- Stoneskin
    sets.midcast.stoneskin = set_combine(sets.midcast.enhancing,{
        -- Stoneskin +30
        neck="Nodens Gorget",
        -- enhances stoneskin
        waist="Siegel Sash",
    })
    sets.midcast.refresh = set_combine(sets.midcast.enhancing,{
    })
    sets.midcast.aquaveil = sets.midcast.refresh
	
    sets.midcast["Drain"] = set_combine(sets.midcast.IntEnfeebling, {

    })

    sets.midcast["Aspir"] = sets.midcast["Drain"]
     
    sets.midcast.cure = {} -- Leave This Empty
    -- Cure Potency
    sets.midcast.cure.normal = set_combine(sets.midcast.casting,{
        -- Cure pot +5
        neck="Nodens Gorget",
        -- cure pot 13
        body="Vrikodara Jupon",
        -- cure pot 10
        legs="Gyve Trousers",
        -- cure pot 5
        feet="Vanya Clogs",
        -- cure pot 5-6
        left_ear="Mendi. Earring",
        -- healing magic skill 10
        left_ring="Sirona's Ring",
        -- cure pot II 5
        right_ring="Janniston Ring",
        -- cure pot 4
        back="Tempered Cape",
    })
    sets.midcast.cure.weather = set_combine(sets.midcast.cure.normal,{

    })    
    sets.midcast.regen = set_combine(sets.midcast.enhancing,{

    }) 
   
    ------------
    -- Aftercast
    ------------
      
    -- I don't use aftercast sets, as we handle what to equip later depending on conditions using a function, eg, do we have a Luopan pan out?
  
end

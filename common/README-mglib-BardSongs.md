# MG-lib BardSongs

This documents how to use the BardSongs feature of the MG library.

## What do you need?

You will need FFXI Windower, GearSwap and a GearSwap lua file for your BRD.

You will need a copy of the [mg-lib.lua](mg-lib.lua) file, probably found together
with this README. You can place this next to your `BRD.lua` or in the
`addons/GearSwap/common` folder under your Windower installation. 

## Getting started

To get BardSongs to work you need to open your existing BRD lua file and
at the top add the following, outside of any functions:

```
local MG = require("mg-lib")
```

Then, inside a method that is called during GearSwap initialization 
(`user_setup` or `get_sets` are good choices), initialize the MG hud and add
BardSongs to it:

```
MG.hud.initialize({})
MG.BardSongs({
    NumberOfExtraSongs=2,

    DefaultGroupName = "Melee songs",

    SongChoices = T{
        "Honor March",
        "Valor Minuet V",
        "Valor Minuet IV",
        "Blade Madrigal",
        "Sword Madrigal",
        "Fire Carol II",
        "Victory March",
        "Advancing March",
    },

    KeyBinds = T{
        Song1 = "Ctrl-F1",
        Song2 = "Ctrl-F2",
        Song3 = "Ctrl-F3",
        Song4 = "Ctrl-F4",
        CCSong = "Ctrl-F5",
    },

    DefaultSongs = T{
        Song1 = "Honor March",
        Song2 = "Valor Minuet V",
        Song3 = "Valor Minuet IV",
        Song4 = "Blade Madrigal",
    },

    DummySongs = T{
        "Fire Carol",
        "Ice Carol",
    },

    -- Extra song group, can add more with SongGroup3, SongGroup4 etc.
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
      -- Whether "None" should be a choice for all song slots
			add_none_choice = true,
		}
})
```

## Commands

Command are issued using `//mgsongs <command> [<args>]` from the chat console
or by using `/console mgsongs <command> [<args>]` from macros.

Targets can be specified using the ingame special targets like `<t>` and
`<lastst>`. To make a macro that targets a chosen player do something like:

```
Macro line 1: /target <stpc>
Macro line 2: /console mgsongs singall <lastst>
```

* `sing_all [target]` 

  Sings all available buff songs as AoE songs, using dummy songs to make sure
  the maximum number of songs is reached. Can be used for getting from 0 to 4
  songs by singing only 6 times.

  Aliases: `singall, recover_all, re, rec`

* `dummy [target]` 

  Puts up dummy songs. The two initial songs will be Song1 and Song2. Can be
  used to put up dummy songs before overwriting everything with Nitro songs.

  Aliases: `dummies`

* `dummy_extras [target]` 

  Put up only the "extra" dummy songs used for song slots 3 and 4. Good for
  recovering missing songs on people who got dispelled.

* `refresh [target]`

  Refresh the current songs with new versions. Can be used together with Nitro
  to overwrite everything with Nitro songs.

* `reset`

  Stops and cancels the current action queue.

  Aliases: `stop`, `cancel`

# MG-lib BardSongs

This documents how to use the BardSongs feature of the MG library.

## What do you need?

You will need FFXI Windower, GearSwap and a GearSwap lua file for your BRD.

You will need a copy of the `mg-lib.lua` file, probably found together
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
})
```

## Commands

Command are issued using `//mgsongs <command> [<args>]` from the chat console
or by using `/console mgsongs <command> [<args>]` from macros.

There are currently the following commands:

* `sing_all`

  Sings all available buff songs as AoE songs, using dummy songs to make sure
  the maximum number of songs is reached. Can be used for getting from 0 to 4
  songs by singing only 6 times.

  Aliases: `singall`
* `dummy`

  Puts up dummy songs. The two initial songs will be Song1 and Song2. Can be
  used to put up dummy songs before overwriting everything with Nitro songs.

  Aliases: `dummies`

* `refresh`

  Refresh the current songs with new versions. Can be used together with Nitro
  to overwrite everything with Nitro songs.

  Aliases: `

* `recover_all`

  Requires a target player. Tries to recover all songs for the specified 
  target by singing songs and dummy songs using Pianissimo.

  Aliases: `re`, `rec`

* `reset`

  Stops and cancels the current action queue.

  Aliases: `stop`, `cancel`

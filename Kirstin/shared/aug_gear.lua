local aug_gear = {
    nuke={
        head={
            name="Merlinic Hood",
            augments={
                'Mag. Acc.+25 "Mag.Atk.Bns."+25',
                'Magic Damage +2',
                'AGI+9',
                '"Mag.Atk.Bns."+15',
            }
        },
        -- macc 46, matk 46, refresh +4
        body="Jhakri Robe +2",
        -- macc 48 (aug), matk 50 (aug)
        hands="Chironic Gloves",
        -- macc 36 (aug), matk 42 (aug), mdam 13
        legs={
            name="Merlinic Shalwar",
            augments={
                '"Mag.Atk.Bns."+11',
                'INT+8',
                'Mag. Acc.+16 "Mag.Atk.Bns."+16',
            },
        },
        -- macc 42, matk 39
        feet="Jhakri Pigaches +2",
    },
    burst={
        head={
            name="Merlinic Hood",
            augments={
                '"Mag.Atk.Bns."+19','Magic burst dmg.+11%','Mag. Acc.+14',
            }
        },
        -- macc 46, matk 46, refresh +4
        body="Jhakri Robe +2",
        hands={
            name="Merlinic Dastanas",
            augments={'"Mag.Atk.Bns."+19','Magic burst dmg.+10%','MND+10',}
        },
        legs={
            name="Merlinic Shalwar",
            augments={
                'Mag. Acc.+20','Magic burst dmg.+10%','"Mag.Atk.Bns."+13',
            }
        },
        -- macc 42, matk 39
        feet="Jhakri Pigaches +2",
    },
    fastcast = {
        -- fastcast +11
        main={
            name="Grioavolr",
            augments={'"Fast Cast"+7','MP+94','Magic Damage +2',}
        },
        -- fastcast +13
        head={
            name="Merlinic Hood",
            augments={
                '"Mag.Atk.Bns."+24',
                '"Fast Cast"+5',
                'INT+8',
                'Mag. Acc.+10',
            }
        },
        -- fastcast +11
        feet={
            name="Merlinic Crackows",
            augments={'"Fast Cast"+6','CHR+9','Mag. Acc.+1',}
        },
    },
    enh_duration = {
        head={ name="Telchine Cap", augments={'Enh. Mag. eff. dur. +10',}},
        body={ name="Telchine Chas.", augments={'Enh. Mag. eff. dur. +8',}},
        hands={ name="Telchine Gloves", augments={'Enh. Mag. eff. dur. +9',}},
        legs={ name="Telchine Braconi", augments={'Enh. Mag. eff. dur. +10',}},
        feet={ name="Telchine Pigaches", augments={'Enh. Mag. eff. dur. +9',}},
    },
};

aug_gear.acc = aug_gear.nuke;

return aug_gear;
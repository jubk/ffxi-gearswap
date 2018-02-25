local aug_gear = {
    nuke = {
        head = {
            name ="Merlinic Hood",
            augments = {
                'Mag. Acc.+22 "Mag.Atk.Bns."+22',
                'Damage taken-2%',
                'CHR+1',
                'Mag. Acc.+15',
                '"Mag.Atk.Bns."+15',
            },
        },
        legs = {
            name = "Merlinic Shalwar",
            augments = {
                'Mag. Acc.+23 "Mag.Atk.Bns."+23',
                '"Conserve MP"+3',
                'Mag. Acc.+14',
                '"Mag.Atk.Bns."+15',
            },
        },
    },
    burst = {
        -- 15 + 23, 10 +23
        -- MB+10, macc 38, matk 33
        head = {
            name="Merlinic Hood",
            augments = {
                'Mag. Acc.+23 "Mag.Atk.Bns."+23',
                'Magic burst dmg.+10%',
                'INT+5',
            }
        },
        -- MB II+5, macc 15, matk 38, elem. magic skill +13
        hands = {
            name="Amalric Gages",
            augments={
                'INT+10',
                'Mag. Acc.+15',
                '"Mag.Atk.Bns."+15',
            }
        },
        -- MB+10, macc 43, matk 37, mdam +13
        legs={
            name="Merlinic Shalwar",
            augments={
                'Mag. Acc.+9 "Mag.Atk.Bns."+9',
                'Magic burst dmg.+10%',
                'MND+4','Mag. Acc.+14',
                '"Mag.Atk.Bns."+13',
            }
        },
        feet = {
            name="Merlinic Crackows",
            augments={
                'Mag. Acc.+21',
                'Magic burst dmg.+10%',
                '"Mag.Atk.Bns."+5',
            },
        },
    },
    acc = {},
}
aug_gear.acc.head = aug_gear.nuke.head;
aug_gear.acc.legs = aug_gear.nuke.legs;

return aug_gear;
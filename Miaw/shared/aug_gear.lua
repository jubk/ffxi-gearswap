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
        head = {
            name = "Merlinic Hood",
            augments = {
                'Pet: DEX+8',
                'Pet: Mag. Acc.+24',
                'Magic burst mdg.+13%',
                'Mag. Acc.+13 "Mag.Atk.Bns."+13',
            },
        },
        -- MB+10, macc 15, matk 38, elem. magic skill +13
        hands = {
            name="Amalric Gages",
            augments={
                'INT+10',
                'Mag. Acc.+15',
                '"Mag.Atk.Bns."+15',
            }
        },
        legs = {
            name="Merlinic Shalwar",
            augments={
                'Mag. Acc.+27',
                'Magic burst mdg.+8%',
                'VIT+7',
                '"Mag.Atk.Bns."+2',
            }
        },
        feet = {
            name="Merlinic Crackows",
            augments={
                'Mag. Acc.+21',
                'Magic burst mdg.+10%',
                '"Mag.Atk.Bns."+5',
            }
        },
    },
    acc = {},
}
aug_gear.acc.head = aug_gear.nuke.head;
aug_gear.acc.legs = aug_gear.nuke.legs;

return aug_gear;
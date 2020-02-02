-- Config file for mg-invenotry.

function setup()
    --[[

    If you want certain gear to have a fixed position specify that
    position here like this:

        fixed_position["Warp Ring"] = "Mog Wardrobe"

    If you instead want the gear to be floating, eg. placed in a specific
    location by default but allowed to move around, specify it as follows:

        floating_position["Warp Ring"] = "Mog Wardrobe 3"

    --]]

    -- Mog Safe
    fixed_position["Alchemist's Belt"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Alchemist's Smock"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Alchemst. Torque"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Brewer's Shield"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Caduceus"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Craftkeeper's Ring"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]
    fixed_position["Craftmaster's Ring"] = "Mog Safe" -- Used by 1 jobs: extra_sets["crafting"]


    -- Mog Wardrobe (used):
    fixed_position["Argocham. Mantle"] = "Mog Wardrobe" -- Used by 2 jobs: BST, PLD
    fixed_position["Augury Cuisses"] = "Mog Wardrobe" -- Used by 2 jobs: DRK, PLD
    fixed_position["Austerity Belt"] = "Mog Wardrobe" -- Used by 4 jobs: BLM, GEO, PLD, SCH
    fixed_position["Begrudging Ring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Bladeborn Earring"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Cab. Gauntlets +1{'Enhances \"Chivalry\" effect'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Cacoethic Ring"] = "Mog Wardrobe" -- Used by 4 jobs: DRK, GEO, PLD, THF
    fixed_position["Cacoethic Ring +1"] = "Mog Wardrobe" -- Used by 5 jobs: COR, DRK, GEO, PLD, THF
    fixed_position["Carmine Cuisses +1{'Accuracy+20','Attack+12','\"Dual Wield\"+6'}"] = "Mog Wardrobe" -- Used by 3 jobs: COR, PLD, RNG
    fixed_position["Carmine Mask{'Accuracy+15','Mag. Acc.+10','\"Fast Cast\"+3'}"] = "Mog Wardrobe" -- Used by 4 jobs: COR, DRK, PLD, RNG
    fixed_position["Cessance Earring"] = "Mog Wardrobe" -- Used by 4 jobs: COR, PLD, RNG, THF
    fixed_position["Chaac Belt"] = "Mog Wardrobe" -- Used by 1 jobs: SCH
    fixed_position["Coatl Gorget +1"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Creed Baudrier"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Cryptic Earring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Defending Ring"] = "Mog Wardrobe" -- Used by 3 jobs: PLD, RNG, SCH
    fixed_position["Diemer Gorget"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Eschan Stone"] = "Mog Wardrobe" -- Used by 5 jobs: BLM, COR, GEO, RNG, THF
    fixed_position["Eshmun's Ring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Evanescence Ring"] = "Mog Wardrobe" -- Used by 2 jobs: PLD, SCH
    fixed_position["Fotia Belt"] = "Mog Wardrobe" -- Used by 5 jobs: COR, DRK, PLD, RNG, THF
    fixed_position["Fotia Gorget"] = "Mog Wardrobe" -- Used by 5 jobs: COR, DRK, PLD, RNG, THF
    fixed_position["Found. Breastplate{'Accuracy+15','Mag. Acc.+15','Attack+15','\"Mag.Atk.Bns.\"+15'}"] = "Mog Wardrobe" -- Used by 2 jobs: DRK, PLD
    fixed_position["Founder's Corona{'DEX+9','Accuracy+14','Mag. Acc.+15','Magic dmg. taken -4%'}"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Founder's Gauntlets{'STR+8','Attack+15','\"Mag.Atk.Bns.\"+13','Phys. dmg. taken -3%'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Founder's Greaves{'VIT+9','Accuracy+14','\"Mag.Atk.Bns.\"+13','Mag. Evasion+15'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Founder's Hose{'MND+1'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Friomisi Earring"] = "Mog Wardrobe" -- Used by 7 jobs: BLM, COR, DRK, GEO, PLD, RNG, THF
    fixed_position["Ghastly Tathlum"] = "Mog Wardrobe" -- Used by 3 jobs: BLM, PLD, SCH
    fixed_position["Hecate's Earring"] = "Mog Wardrobe" -- Used by 4 jobs: COR, PLD, RNG, THF
    fixed_position["Jumalik Helm{'MND+10','\"Mag.Atk.Bns.\"+15','Magic burst dmg.+10%','\"Refresh\"+1'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Kentarch Belt +1"] = "Mog Wardrobe" -- Used by 4 jobs: COR, PLD, RNG, THF
    fixed_position["Knobkierrie"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Loess Barbuta"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Mendi. Earring"] = "Mog Wardrobe" -- Used by 2 jobs: PLD, SCH
    fixed_position["Moonbeam Necklace"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Nourish. Earring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Odyss. Chestplate{'Mag. Acc.+21','\"Fast Cast\"+4','AGI+9','\"Mag.Atk.Bns.\"+15'}"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Odyssean Greaves{'Accuracy+10','\"Fast Cast\"+5','Attack+13'}"] = "Mog Wardrobe" -- Used by 2 jobs: DRK, PLD
    fixed_position["Olseni Belt"] = "Mog Wardrobe" -- Used by 2 jobs: BST, PLD
    fixed_position["Purity Ring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Reiki Cloak"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Rev. Surcoat +3"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Sailfi Belt"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Shabti Cuisses"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Shiva Ring +1"] = "Mog Wardrobe" -- Used by 2 jobs: PLD, THF
    fixed_position["Silver Obi +1"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Sirona's Ring"] = "Mog Wardrobe" -- Used by 2 jobs: BLM, SCH
    fixed_position["Souv. Diechlings +1{'HP+105','Enmity+9','Potency of \"Cure\" effect received +15%'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Souv. Handsch. +1{'HP+105','Enmity+9','Potency of \"Cure\" effect received +15%'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Souv. Schaller +1{'HP+105','Enmity+9','Potency of \"Cure\" effect received +15%'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Souveran Schuhs +1{'HP+105','Enmity+9','Potency of \"Cure\" effect received +15%'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Staunch Tathlum"] = "Mog Wardrobe" -- Used by 2 jobs: PLD, SCH
    fixed_position["Steelflash Earring"] = "Mog Wardrobe" -- Used by 6 jobs: BST, COR, DRK, GEO, PLD, THF
    fixed_position["Sulev. Cuisses +2"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Sulev. Gauntlets +2"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Sulev. Leggings +2"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Sulevia's Mask +2"] = "Mog Wardrobe" -- Used by 2 jobs: DRK, PLD
    fixed_position["Sulevia's Plate. +2"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Trux Earring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Varar Ring"] = {"Mog Wardrobe", "Mog Wardrobe 4"} -- Used by 1 jobs: BST
    fixed_position["Vengeful Ring"] = "Mog Wardrobe" -- Used by 1 jobs: PLD
    fixed_position["Vocane Ring"] = "Mog Wardrobe" -- Used by 3 jobs: PLD, RNG, SCH
    fixed_position["Volte Jupon"] = "Mog Wardrobe" -- Used by 1 jobs: SCH
    fixed_position["Weard Mantle{'VIT+2','Enmity+3','Phalanx +4'}"] = "Mog Wardrobe" -- Used by 1 jobs: PLD

    -- Mog Wardrobe (unused):
    fixed_position["Aegis{}"] = "Mog Wardrobe" -- Not used
    fixed_position["Burtgang"] = "Mog Wardrobe" -- Not used
    fixed_position["Cab. Breeches{'Enhances \"Invincible\" effect'}"] = "Mog Wardrobe" -- Not used
    fixed_position["Cab. Coronet +1{'Enhances \"Iron Will\" effect'}"] = "Mog Wardrobe" -- Not used
    fixed_position["Cab. Leggings +1{'Enhances \"Guardian\" effect'}"] = "Mog Wardrobe" -- Not used
    fixed_position["Cab. Surcoat +1{'Enhances \"Fealty\" effect'}"] = "Mog Wardrobe" -- Not used
    fixed_position["Dim. Ring (Holla)"] = "Mog Wardrobe" -- Not used
    fixed_position["Ochain{}"] = "Mog Wardrobe" -- Not used
    floating_position["Odnowa Earring"] = "Mog Wardrobe" -- Not used
    floating_position["Odnowa Earring +1"] = "Mog Wardrobe" -- Not used
    fixed_position["Rev. Coronet +1"] = "Mog Wardrobe" -- Not used
    fixed_position["Trizek Ring"] = "Mog Wardrobe" -- Not used
    fixed_position["Warp Ring"] = "Mog Wardrobe" -- Not used

    -- Mog Wardrobe 2 (used):
    fixed_position["Acad. Bracers +3"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Acad. Gown +3"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Acad. Loafers +3"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Acad. Mortar. +3"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Acad. Pants +3"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Akademos{'INT+15','\"Mag.Atk.Bns.\"+15','Mag. Acc.+15'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Amalric Gages{'INT+10','Mag. Acc.+15','\"Mag.Atk.Bns.\"+15'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Ammurapi Shield"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Andoaa Earring"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Arbatel Bonnet +1"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Arbatel Bracers +1"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Barkaro. Earring"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Bishop's Sash"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Bolelabunga"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Bookworm's Cape{'INT+2','MND+1','Helix eff. dur. +19','\"Regen\" potency+9'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Channeler's Stone"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Chatoyant Staff"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Chironic Gloves{'Mag. Acc.+24 \"Mag.Atk.Bns.\"+24','\"Fast Cast\"+4','Mag. Acc.+5','\"Mag.Atk.Bns.\"+13'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Clerisy Strap"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Digni. Earring"] = "Mog Wardrobe 2" -- Used by 8 jobs: BLM, BST, COR, DRK, GEO, PLD, SCH, THF
    fixed_position["Doyen Pants"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Enki Strap"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Erra Pendant"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, DRK, SCH
    fixed_position["Etana Ring"] = "Mog Wardrobe 2" -- Used by 5 jobs: BLM, COR, DRK, GEO, SCH
    fixed_position["Etiolation Earring"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Felicitas Cape"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Freke Ring"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Fucho-no-Obi"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Gada{'Enh. Mag. eff. dur. +5'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Genmei Shield"] = "Mog Wardrobe 2" -- Used by 2 jobs: GEO, SCH
    fixed_position["Grioavolr{'\"Fast Cast\"+5','MP+32','Mag. Acc.+9','Magic Damage +3'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Jhakri Pigaches +2"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Jhakri Ring"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Kaja Grip"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Kishar Ring"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, COR, SCH
    fixed_position["Locus Ring"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Loquac. Earring"] = "Mog Wardrobe 2" -- Used by 7 jobs: BLM, COR, DRK, GEO, PLD, RNG, SCH
    fixed_position["Lugh's Cape{'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','\"Mag.Atk.Bns.\"+10','Damage taken-5%'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Luminary Sash"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Mallquis Saio +2"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Mephitas's Ring +1"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, RNG, SCH
    fixed_position["Merlinic Crackows{'\"Fast Cast\"+5','\"Mag.Atk.Bns.\"+4'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Merlinic Hood{'Mag. Acc.+19 \"Mag.Atk.Bns.\"+19','\"Fast Cast\"+6','CHR+5'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Merlinic Hood{'Mag. Acc.+22 \"Mag.Atk.Bns.\"+22','Damage taken-2%','CHR+1','Mag. Acc.+15','\"Mag.Atk.Bns.\"+15'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Merlinic Shalwar{'Mag. Acc.+23 \"Mag.Atk.Bns.\"+23','\"Conserve MP\"+3','Mag. Acc.+14','\"Mag.Atk.Bns.\"+15'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Mizu. Kubikazari"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Mujin Band"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Niobid Strap"] = "Mog Wardrobe 2" -- Used by 2 jobs: BLM, SCH
    fixed_position["Nodens Gorget"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Pahtli Cape"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Peda. Bracers +3{'Enh. \"Tranquility\" and \"Equanimity\"'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Peda. Gown +3{'Enhances \"Enlightenment\" effect'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Peda. M.Board +3{'Enh. \"Altruism\" and \"Focalization\"'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Peda. Pants +3{'Enhances \"Tabula Rasa\" effect'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Pemphredo Tathlum"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, DRK, SCH
    fixed_position["Pinga Pants"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Pinga Tunic"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Pixie Hairpin +1"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, COR, SCH
    fixed_position["Prolix Ring"] = "Mog Wardrobe 2" -- Used by 6 jobs: BLM, COR, DRK, GEO, RNG, SCH
    fixed_position["Refoccilation Stone"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Regal Earring"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Sanctity Necklace"] = "Mog Wardrobe 2" -- Used by 8 jobs: BLM, COR, DRK, GEO, PLD, RNG, SCH, THF
    fixed_position["Sapience Orb"] = "Mog Wardrobe 2" -- Used by 3 jobs: DRK, PLD, SCH
    fixed_position["Savant's Earring"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Siriti"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Solemnity Cape"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Swith Cape +1"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Telchine Braconi{'Enh. Mag. eff. dur. +10'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Telchine Cap{'Enh. Mag. eff. dur. +10'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Telchine Gloves{'\"Cure\" potency +4%','Enh. Mag. eff. dur. +10'}"] = "Mog Wardrobe 2" -- Used by 3 jobs: BLM, GEO, SCH
    fixed_position["Telchine Pigaches{'Enh. Mag. eff. dur. +9'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Malignance Pole"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Vanya Clogs{'\"Cure\" potency +5%','\"Cure\" spellcasting time -15%','\"Conserve MP\"+6'}"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Volte Gaiters"] = "Mog Wardrobe 2" -- Used by 1 jobs: SCH
    fixed_position["Voltsurge Torque"] = "Mog Wardrobe 2" -- Used by 7 jobs: BLM, COR, DRK, GEO, PLD, RNG, SCH
    -- Mog Wardrobe 2 (unused):
    fixed_position["Arbatel Loafers +1"] = "Mog Wardrobe 2" -- Not used
    fixed_position["Arbatel Pants +1"] = "Mog Wardrobe 2" -- Not used
    fixed_position["Hachirin-no-Obi"] = "Mog Wardrobe 2" -- Not used
    fixed_position["Peda. Loafers +3{'Enhances \"Stormsurge\" effect'}"] = "Mog Wardrobe 2" -- Not used
    fixed_position["Twilight Cape"] = "Mog Wardrobe 2" -- Not used


    -- Mog Wardrobe 3 (used):
    fixed_position["Adhemar Kecks +1{'AGI+12','Rng.Acc.+20','Rng.Atk.+20'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Archon Ring"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Armageddon"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Arvina Ringlet +1"] = "Mog Wardrobe 3" -- Used by 6 jobs: BLM, COR, DRK, GEO, PLD, RNG
    fixed_position["Ataktos{'Delay:+60','TP Bonus +1000'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Aurore Beret +1"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Belenus's Cape{'\"Snapshot\"+10'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Belenus's Cape{'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Belenus's Cape{'AGI+20','Rng.Acc.+20 Rng.Atk.+20','\"Store TP\"+10'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Belenus's Cape{'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Blurred Knife +1"] = "Mog Wardrobe 3" -- Used by 2 jobs: BRD, COR
    fixed_position["Camulus's Mantle{'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Camulus's Mantle{'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Camulus's Mantle{'AGI+20','Rng.Acc.+20 Rng.Atk.+20','Rng.Acc.+10','\"Store TP\"+10'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Camulus's Mantle{'STR+20','Accuracy+20 Attack+20','Accuracy+5','Weapon skill damage +10%'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Carmine Fin. Ga. +1{'Rng.Atk.+20','\"Mag.Atk.Bns.\"+12','\"Store TP\"+6'}"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Chas. Culottes +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Chass. Bottes +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Chass. Tricorne +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Chasseur's Frac +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Chasseur's Gants +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Death Penalty"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Demers. Degen +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: BRD
    fixed_position["Dingir Ring"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Enervating Earring"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Herculean Boots{'Rng.Acc.+14 Rng.Atk.+14','Weapon skill damage +3%','Rng.Acc.+2','Rng.Atk.+12'}"] = "Mog Wardrobe 3" -- Used by 2 jobs: RNG, THF
    fixed_position["Herculean Trousers{'Rng.Acc.+26','Weapon skill damage +4%','DEX+5','Rng.Atk.+15'}"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Impulse Belt"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Ishvara Earring"] = "Mog Wardrobe 3" -- Used by 3 jobs: BRD, COR, RNG
    fixed_position["Iskur Gorget"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Kustawi +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Laksa. Boots +3"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Laksa. Frac +3"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Laksa. Gants +2"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Laksa. Tricorne +2"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Lanun Bottes +3{'Enhances \"Wild Card\" effect'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Lanun Frac +3{'Enhances \"Loaded Deck\" effect'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Lanun Trews +1{'Enhances \"Snake Eye\" effect'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Lanun Tricorne +3{'Enhances \"Winning Streak\" effect'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Liv. Bul. Pouch"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Loricate Torque +1"] = "Mog Wardrobe 3" -- Used by 4 jobs: BRD, COR, RNG, SCH
    fixed_position["Luzaf's Ring"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Malevolence{'INT+10','Mag. Acc.+10','\"Mag.Atk.Bns.\"+8','\"Fast Cast\"+5'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: BRD
    fixed_position["Malevolence{'INT+9','Mag. Acc.+10','\"Mag.Atk.Bns.\"+9','\"Fast Cast\"+4'}"] = "Mog Wardrobe 3" -- Used by 1 jobs: BRD
    fixed_position["Malignance Gloves"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Meg. Chausses +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Meg. Cuirie +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Meg. Gloves +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Meg. Jam. +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Meghanada Ring"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Meghanada Visor +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Moonshade Earring{'Rng.Atk.+4','TP Bonus +250'}"] = "Mog Wardrobe 3" -- Used by 4 jobs: BRD, COR, RNG, THF
    fixed_position["Mummu Jacket +2"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Naegling"] = "Mog Wardrobe 3" -- Used by 2 jobs: BRD, COR
    fixed_position["Navarch's Mantle"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Neritic Earring"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Nusku Shield"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Ocachi Gorget"] = "Mog Wardrobe 3" -- Used by 1 jobs: RNG
    fixed_position["Oshosi Mask"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Oshosi Trousers"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Oshosi Vest"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Regal Necklace"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Regal Ring"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Samnuha Coat{'Mag. Acc.+13','\"Mag.Atk.Bns.\"+14','\"Fast Cast\"+3','\"Dual Wield\"+4'}"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    fixed_position["Samnuha Tights{'STR+10','DEX+10','\"Dbl.Atk.\"+3','\"Triple Atk.\"+3'}"] = "Mog Wardrobe 3" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Svelt. Gouriz +1"] = "Mog Wardrobe 3" -- Used by 1 jobs: COR
    fixed_position["Tauret"] = "Mog Wardrobe 3" -- Used by 1 jobs: BRD
    fixed_position["Volley Earring"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    floating_position["Windbuffet Belt +1"] = "Mog Wardrobe 3" -- Used by 2 jobs: BRD, COR
    fixed_position["Yemaya Belt"] = "Mog Wardrobe 3" -- Used by 2 jobs: COR, RNG
    -- Mog Wardrobe 3 (unused):
    fixed_position["Arendsi Fleuret"] = "Mog Wardrobe 3" -- Not used
    fixed_position["Hep. Rapier +1"] = "Mog Wardrobe 3" -- Not used
    fixed_position["Hunter's Braccae"] = "Mog Wardrobe 3" -- Not used
    fixed_position["Laksa. Trews +2"] = "Mog Wardrobe 3" -- Not used
    fixed_position["Orion Beret +2"] = "Mog Wardrobe 3" -- Not used
    fixed_position["Perun +1"] = "Mog Wardrobe 3" -- Not used
    floating_position["Sarissapho. Belt"] = "Mog Wardrobe 3" -- Not used
    floating_position["Scout's Socks"] = "Mog Wardrobe 3" -- Not used
    floating_position["Sherida Earring"] = "Mog Wardrobe 3" -- Not used

    -- Mog Wardrobe 4 (used):
    fixed_position["Ankusa Gloves +1{'Enhances \"Beast Affinity\" effect'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Apate Ring"] = "Mog Wardrobe 4" -- Used by 2 jobs: COR, THF
    fixed_position["Bane Cape{'Elem. magic skill +10','Dark magic skill +6','\"Mag.Atk.Bns.\"+1'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: BLM
    fixed_position["Canny Cape{'DEX+3','AGI+2','\"Dual Wield\"+4'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Despair Greaves{'Accuracy+10','Pet: VIT+7','Pet: Damage taken -3%'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Desultor Tassets{'\"Sic\" and \"Ready\" ability delay -5','Pet: Accuracy+7 Pet: Rng. Acc.+7'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Dunna{'MP+20','Mag. Acc.+10','\"Fast Cast\"+3'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Eddy Necklace"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Gende. Gages +1"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Gyve Trousers"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Herculean Boots{'\"Mag.Atk.Bns.\"+25','Weapon skill damage +3%','INT+2','Mag. Acc.+5'}"] = "Mog Wardrobe 4" -- Used by 2 jobs: RNG, THF
    fixed_position["Herculean Gloves{'Mag. Acc.+20 \"Mag.Atk.Bns.\"+20','STR+4','Mag. Acc.+10','\"Mag.Atk.Bns.\"+10'}"] = "Mog Wardrobe 4" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Herculean Helm{'\"Mag.Atk.Bns.\"+25','Weapon skill damage +3%','INT+7','Mag. Acc.+7'}"] = "Mog Wardrobe 4" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Herculean Trousers{'Mag. Acc.+19 \"Mag.Atk.Bns.\"+19','INT+4','\"Mag.Atk.Bns.\"+12'}"] = "Mog Wardrobe 4" -- Used by 3 jobs: COR, RNG, THF
    fixed_position["Herculean Vest{'Mag. Acc.+18 \"Mag.Atk.Bns.\"+18','INT+10','\"Mag.Atk.Bns.\"+11'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Hike Khat"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Ilabrat Ring"] = "Mog Wardrobe 4" -- Used by 2 jobs: RNG, THF
    fixed_position["Izdubar Mantle"] = "Mog Safe" -- Used by 1 jobs: DRK
    fixed_position["Jhakri Coronal +1"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Jhakri Cuffs +1"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Jhakri Robe +1"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Jute Boots +1"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Kayapa Cape"] = "Mog Wardrobe 4" -- Used by 2 jobs: DRK, GEO
    fixed_position["Lathi{'INT+15','\"Mag.Atk.Bns.\"+15','Mag. Acc.+15'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: BLM
    fixed_position["Lifestream Cape{'Geomancy Skill +8','Indi. eff. dur. +16','Pet: Damage taken -3%'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Loyalist Sabatons{'STR+10','Attack+15','Phys. dmg. taken -3%','Haste+3'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Merlinic Crackows{'Mag. Acc.+21','Magic burst dmg.+10%','\"Mag.Atk.Bns.\"+5'}"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Merlinic Hood{'Mag. Acc.+23 \"Mag.Atk.Bns.\"+23','Magic burst dmg.+10%','INT+5'}"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Merlinic Jubbah{'\"Mag.Atk.Bns.\"+27','Magic burst dmg.+10%','INT+13','Mag. Acc.+3'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: BLM
    fixed_position["Merlinic Shalwar{'Mag. Acc.+9 \"Mag.Atk.Bns.\"+9','Magic burst dmg.+10%','MND+4','Mag. Acc.+14','\"Mag.Atk.Bns.\"+13'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Moonbeam Ring"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Persis Ring"] = "Mog Wardrobe 4" -- Used by 1 jobs: BLM
    fixed_position["Pet Food Theta"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Plun. Armlets +1{'Enhances \"Perfect Dodge\" effect'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Sacro Mantle"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Seething Bomblet"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Shango Robe"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Shulmanu Collar"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Skulk. Poulaines"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Solstice{'Mag. Acc.+20','Pet: Damage taken -4%','\"Fast Cast\"+5'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: GEO
    fixed_position["Strendu Ring"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Tali'ah Crackows +2"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Tali'ah Gages +1"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Tali'ah Manteel +2"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Tali'ah Sera. +2"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Tali'ah Turban +2"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Taranus's Cape{'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Mag. Acc.+10','\"Mag.Atk.Bns.\"+10'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: BLM
    fixed_position["Telchine Chas.{'Enh. Mag. eff. dur. +9'}"] = "Mog Wardrobe 4" -- Used by 2 jobs: BLM, GEO
    fixed_position["Toutatis's Cape{'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%'}"] = "Mog Wardrobe 4" -- Used by 1 jobs: THF
    fixed_position["Valor. Hose{'Accuracy+23 Attack+23','Weapon skill damage +3%','AGI+4'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Valor. Hose{'Pet: Accuracy+28 Pet: Rng. Acc.+28','Pet: STR+2','Pet: Attack+15 Pet: Rng.Atk.+15'}"] = "Mog Safe 2" -- Used by 1 jobs: BST
    fixed_position["Varar Ring"] = {"Mog Wardrobe", "Mog Wardrobe 4"} -- Used by 1 jobs: BST
    -- Mog Wardrobe 4 (unused):
    fixed_position["Aganoshe{'\"Store TP\"+6','DEX+8','Accuracy+21','Attack+2','DMG:+26'}"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Bloodrain Strap"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Bubbly Broth"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Charmer's Merlin"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Deathbane"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Jokushuono"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Sandung"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Skullrender{'DMG:+15','Pet: Accuracy+20','Pet: Attack+20'}"] = "Mog Wardrobe 4" -- Not used
    fixed_position["Taming Sari{'STR+10','DEX+10','DMG:+15','\"Treasure Hunter\"+1'}"] = "Mog Wardrobe 4" -- Not used

    extra_sets["crafting"] = {
        main="Caduceus",
        sub="Brewer's Shield",
        body="Alchemist's Smock",
        neck="Alchemst. Torque",
        waist="Alchemist's Belt",
        left_ring="Craftmaster's Ring",
        right_ring="Craftkeeper's Ring",
    }
end


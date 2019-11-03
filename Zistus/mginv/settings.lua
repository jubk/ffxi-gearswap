-- Config file for mg-invenotry.

function setup(fixed_position, floating_position)
    --[[

    If you want certain gear to have a fixed position specify that
    position here like this:

        fixed_position["Warp Ring"] = "Mog Wardrobe"

    If you instead want the gear to be floating, eg. placed in a specific
    location by default but allowed to move around, specify it as follows:

        floating_position["Warp Ring"] = "Mog Wardrobe 3"

    If you need to have two of the same item in different wardrobes,
    specify a list of locations instead:

        fixed_position["Varar Ring"] = {"Mog Wardrobe", "Mog Wardrobe 4"}

    --]]

end


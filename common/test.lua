dofile("dumper.lua");
dofile("spelltools.lua");

pseudo_player = {
    main_job = "SCH",
    sub_job = "RDM",
    main_job_level = 99,
    sub_job_level = 49
};

buffactive = {};

setup_spellcost_map(pseudo_player);

print(DataDumper(spellcost_map, ""));
print(DataDumper(addendum_map, ""));

print(check_addendum("Silena"))

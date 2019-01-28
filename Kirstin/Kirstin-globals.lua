-- Function to bind GearSwap binds when loading a GS script.
function global_on_load()
	-- send_command('bind f9 gs c cycle OffenseMode')
	send_command('bind ^f9 gs c cycle HybridMode')
	send_command('bind !f9 gs c cycle RangedMode')
	send_command('bind @f9 gs c cycle WeaponskillMode')
	-- send_command('bind f10 gs c set DefenseMode Physical')
	send_command('bind ^f10 gs c cycle PhysicalDefenseMode')
	send_command('bind !f10 gs c toggle Kiting')
	-- send_command('bind f11 gs c set DefenseMode Magical')
	send_command('bind ^f11 gs c cycle CastingMode')
	-- send_command('bind f12 gs c update user')
	-- send_command('bind ^f12 gs c cycle IdleMode')
	send_command('bind !f12 gs c reset DefenseMode')

	send_command('bind ^- gs c toggle selectnpctargets')
	send_command('bind ^= gs c cycle pctargetmode')
end

-- Function to revert binds when unloading.
function global_on_unload()
	-- send_command('unbind f9')
	send_command('unbind ^f9')
	send_command('unbind !f9')
	send_command('unbind @f9')
	-- send_command('unbind f10')
	send_command('unbind ^f10')
	send_command('unbind !f10')
	-- send_command('unbind f11')
	send_command('unbind ^f11')
	send_command('unbind !f11')
	-- send_command('unbind f12')
	-- send_command('unbind ^f12')
	send_command('unbind !f12')

	send_command('unbind ^-')
	send_command('unbind ^=')
end

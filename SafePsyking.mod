return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Safe Psyking` encountered an error loading the Darktide Mod Framework.")

		new_mod("SafePsyking", {
			mod_script       = "SafePsyking/scripts/mods/SafePsyking/SafePsyking",
			mod_data         = "SafePsyking/scripts/mods/SafePsyking/SafePsyking_data",
			mod_localization = "SafePsyking/scripts/mods/SafePsyking/SafePsyking_localization",
		})
	end,
	packages = {},
}
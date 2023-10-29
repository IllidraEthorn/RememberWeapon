local mod = get_mod("SafePsyking")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "safe_actions",
				type = "group",
				sub_widgets = {
					{
						setting_id = "rapid_left_forcestaff_p1_m1_projectile",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_trigger_explosion_forcestaff_p1_m1_use_aoe",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_shoot_flame_forcestaff_p2_m1_flame_burst",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_shoot_charged_flame_forcestaff_p2_m1_flamer_gas",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "rapid_left_forcestaff_p3_m1_projectile",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_shoot_charged_forcestaff_p3_m1_chain_lightning",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "rapid_left_forcestaff_p4_m1_projectile",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_shoot_charged_forcestaff_p4_m1_charged_projectile",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_assail",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_brainburst",
						type = "checkbox",
						default_value = true
					},
					{
						setting_id = "action_shoot_charged_plasmagun_p1_m1_shoot_charged",
						type = "checkbox",
						default_value = true
					},
				}
			},
			{
                setting_id = "debug",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                }
            },
		}
	}
}

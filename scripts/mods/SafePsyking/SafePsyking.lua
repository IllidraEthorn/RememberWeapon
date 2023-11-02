local mod = get_mod("SafePsyking")

local Overheat = require("scripts/utilities/overheat")
local ItemUtils = require("scripts/utilities/items")

local prev_action = nil
local block_request = nil
local after_request_type = nil
local count = 0

local grenade = ""

local shriek_equipped = false

local allow_when_can_shriek = false

local action_one_used = {"action_one_pressed", "action_one_hold"}

local started_brain_burst = false

local talents_index = {
    veteran = {
        {"veteran_combat_ability_elite_and_special_outlines","veteran_combat_ability_stagger_nearby_enemies","veteran_invisibility_on_combat_ability"},
        {"veteran_grenade_apply_bleed","veteran_krak_grenade","veteran_smoke_grenade"},
        {"veteran_aura_gain_ammo_on_elite_kill_improved","veteran_increased_damage_coherency","veteran_movement_speed_coherency"},
    },
    zealot = {
        {"zealot_attack_speed_post_ability","zealot_bolstering_prayer","zealot_stealth"},
        {"zealot_improved_stun_grenade","zealot_flame_grenade","zealot_throwing_knives"},
        {"zealot_toughness_damage_reduction_coherency_improved","zealot_corruption_healing_coherency_improved","zealot_always_in_coherency"},
    },
    psyker = {
        {"psyker_shout_vent_warp_charge","psyker_combat_ability_force_field","psyker_combat_ability_stance"},
        {"psyker_brain_burst_improved","psyker_grenade_chain_lightning","psyker_grenade_throwing_knives"},
        {"psyker_aura_damage_vs_elites","psyker_cooldown_aura_improved","psyker_aura_crit_chance_aura"},
    },
    ogryn = {
        {"ogryn_longer_charge","ogryn_taunt_shout","ogryn_special_ammo"},
        {"ogryn_grenade_friend_rock","ogryn_box_explodes","ogryn_grenade_frag"},
        {"ogryn_melee_damage_coherency_improved","ogryn_toughness_regen_aura","ogryn_damage_vs_suppressed_coherency"},
    },
}

--these 2 tables are not needed
local unsafe_at_100_percent = {
    'rapid_left_forcestaff_p1_m1_projectile', 
    'action_trigger_explosion_forcestaff_p1_m1_use_aoe', 
    'action_shoot_flame_forcestaff_p2_m1_flame_burst', 
    'action_shoot_charged_flame_forcestaff_p2_m1_flamer_gas',
    'rapid_left_forcestaff_p3_m1_projectile',
    'action_shoot_charged_forcestaff_p3_m1_chain_lightning',
    'rapid_left_forcestaff_p4_m1_projectile',
    'action_shoot_charged_forcestaff_p4_m1_charged_projectile',
    'action_rapid_right_psyker_throwing_knives',
    'action_rapid_left_psyker_throwing_knives',
    'action_rapid_zoomed_psyker_throwing_knives_homing',
    'action_charge_target_lock_on_psyker_smite_lock_target'
}
local unsafe_at_97_percent = {
    'action_charge_target_sticky_psyker_smite_lock_target'
}

local unsafe_at_100_percent_warp_charge_level_left_click_config = {}
local unsafe_at_100_percent_warp_charge_level_right_click_config = {}

local unsafe_at_97_percent_warp_charge_level_left_click_config = {}
local unsafe_at_97_percent_warp_charge_level_right_click_config = {}

--local unsafe_at_100_percent_overheat_level_left_click_config = {}
local unsafe_at_100_percent_overheat_level_right_click_config = {}

local function weapon_name(profile,slot)
	local loadout = profile.loadout
	local slots = { slot_primary = "slot_primary",slot_secondary = "slot_secondary", }
	local kind = slots[slot]
	local weapon = loadout[kind]
	local name = " "
	if not slot or not slots[slot] then
		return name
	else		
		name = weapon.display_name or " "
	end
	return string.trim(name)
end

local _update_talents = function()
    local local_player_id = 1
    local player_manager = Managers.player
    local player = player_manager and player_manager:local_player(local_player_id)
    local character_id = player and player:character_id()
    local profile = player:profile()
    local profile_archetype = profile.archetype
    local archetype = profile.archetype.name
    local talents = profile.talents
    local player_class = profile.specialization
    local ult = ""
    
    if talents_index[archetype] then
        local current = talents_index[archetype][2]
        for o = 1,3 do
            if talents[current[o]] then
                grenade = current[o]
            end
        end
        local current = talents_index[archetype][1]
        for o = 1,3 do
            if talents[current[o]] then
                ult = current[o]
            end
        end
    end

    if player_class == "psyker_2" then
        shriek_equipped = ult == "psyker_shout_vent_warp_charge" or ult == ""
    else
        shriek_equipped = false
    end
    if shriek_equipped then
        mod.debug.echo("Shriek")
    else
        mod.debug.echo("Not Shriek")
    end
end

local _update_config = function()
    unsafe_at_100_percent_warp_charge_level_left_click_config = {}
    unsafe_at_100_percent_warp_charge_level_right_click_config = {}

    unsafe_at_97_percent_warp_charge_level_left_click_config = {}
    unsafe_at_97_percent_warp_charge_level_right_click_config = {}

    unsafe_at_100_percent_overheat_level_right_click_config = {}

    if mod:get('rapid_left_forcestaff_p1_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_left_click_config, 'loc_forcestaff_p1_m1')
    end
    if mod:get('action_trigger_explosion_forcestaff_p1_m1_use_aoe') then
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'loc_forcestaff_p1_m1')
    end
    if mod:get('action_shoot_flame_forcestaff_p2_m1_flame_burst') then
        table.insert(unsafe_at_100_percent_warp_charge_level_left_click_config, 'loc_forcestaff_p2_m1')
    end
    if mod:get('action_shoot_charged_flame_forcestaff_p2_m1_flamer_gas') then
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'loc_forcestaff_p2_m1')
    end
    if mod:get('rapid_left_forcestaff_p3_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_left_click_config, 'loc_forcestaff_p3_m1')
    end
    if mod:get('action_shoot_charged_forcestaff_p3_m1_chain_lightning') then
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'loc_forcestaff_p3_m1')
    end
    if mod:get('rapid_left_forcestaff_p4_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_left_click_config, 'loc_forcestaff_p4_m1')
    end
    if mod:get('action_shoot_charged_forcestaff_p4_m1_charged_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'loc_forcestaff_p4_m1')
    end
    if mod:get('action_assail') then
        table.insert(unsafe_at_100_percent_warp_charge_level_left_click_config, 'psyker_grenade_throwing_knives')
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'psyker_grenade_throwing_knives')
    end
    if mod:get('action_brainburst') then
        table.insert(unsafe_at_100_percent_warp_charge_level_right_click_config, 'psyker_brain_burst_improved')
        table.insert(unsafe_at_97_percent_warp_charge_level_left_click_config, 'psyker_brain_burst_improved')
    end
    if mod:get('action_shoot_charged_plasmagun_p1_m1_shoot_charged') then
        table.insert(unsafe_at_100_percent_overheat_level_right_click_config, 'loc_plasmagun_p1_m1')
    end
    if mod:get('override_if_shriek') then
        allow_when_can_shriek = true
    end
end

local _input_action_hook = function(func, self, action_name)
    local val = func(self, action_name)

    if val then
        --print(action_name)
    end

    --print(action_name)
    if val and has_value(action_one_used, action_name) then

        local holding_right_click = func(self, "action_two_hold")

        if holding_right_click then
            --print("Secondary")
        end
        --print("Action 1: "..action_name)
        local local_player_id = 1
        local player_manager = Managers.player
        local player = player_manager and player_manager:local_player(local_player_id)
        local profile = player:profile()

        local player_class = profile.specialization
        
        local player_unit = player.player_unit
        local unit_data_extension = ScriptUnit.extension(player_unit, "unit_data_system")
        local warp_charge_component = unit_data_extension:read_component("warp_charge")
        local warp_charge_level = 0
        
        local inventory_component = unit_data_extension:read_component("inventory")
        local slot = inventory_component.wielded_slot

        local archetype = profile.archetype.name
	    local talents = profile.talents

        local weapon = weapon_name(profile, slot)

        if warp_charge_component ~= nil then
            warp_charge_level = warp_charge_component.current_percentage
        end
        local overheat_level = 0
        local inventory_slot_component = unit_data_extension:read_component("slot_secondary")

        if inventory_slot_component ~= nil and inventory_slot_component.overheat_current_percentage ~= nil then
            overheat_level = inventory_slot_component.overheat_current_percentage
        end

        local ability_component = unit_data_extension:read_component("combat_ability")

        local cooldown = 0

        if ability_component then
            local time = Managers.time:time("gameplay")

            local time_remaining = ability_component.cooldown - time

            cooldown = time_remaining
            
            --mod.debug.echo("Cooldown: "..cooldown)
        end
        --print("Slot: '"..slot.."'")
        if slot ~= nil and inventory_slot_component ~= nil then
            --print(weapon_name(profile, slot))
        end

        --print("Grenade: "..grenade.." Weapon: "..weapon.." Warp: "..warp_charge_level.." Overheat: "..overheat_level)
        
        if player_class == "psyker_2" then
            if allow_when_can_shriek and shriek_equipped and cooldown <= 0 then
                return val
            end
            if slot == "slot_grenade_ability" then
                if grenade == "psyker_brain_burst_improved" and warp_charge_level < 0.97 then
                    started_brain_burst = true
                end
                if not holding_right_click and has_value(unsafe_at_97_percent_warp_charge_level_left_click_config, grenade) and (warp_charge_level >= 0.97)  then
                    if started_brain_burst then
                        --print("Brain Burst Override")
                    else
                        --print("Canceling")
                        val = false
                    end
                elseif not holding_right_click and has_value(unsafe_at_100_percent_warp_charge_level_left_click_config, grenade) and (warp_charge_level == 1)  then
                    --print("Canceling")
                    val = false
                elseif holding_right_click and has_value(unsafe_at_100_percent_warp_charge_level_right_click_config, grenade) and (warp_charge_level == 1)  then
                    --print("Canceling")
                    val = false
                end
            elseif slot == "slot_secondary" then
                if not holding_right_click and has_value(unsafe_at_100_percent_warp_charge_level_left_click_config, weapon) and (warp_charge_level == 1) then
                    --print("Canceling")
                    val = false
                elseif holding_right_click and has_value(unsafe_at_100_percent_warp_charge_level_right_click_config, weapon) and (warp_charge_level == 1) then
                    --print("Canceling")
                    val = false
                end
            end
        elseif player_class == "veteran_2" then 
            if holding_right_click and has_value(unsafe_at_100_percent_overheat_level_right_click_config, weapon) and (overheat_level == 1) then
                --print("Canceling")
                val = false
            end
        end
        return val
    end

    if val and action_name == "action_one_release" then
        --print("Release brainburst")
        started_brain_burst = false
    end
    return val
end

mod:hook(CLASS.InputService, "_get", _input_action_hook)
mod:hook(CLASS.InputService, "_get_simulate", _input_action_hook)

mod:hook_safe(CLASS.TalentBuilderView, "on_exit", _update_talents)
mod:hook_safe(CLASS.InventoryView, "on_exit", _update_talents)
mod:hook_safe(CLASS.UIManager, "event_player_profile_updated", _update_talents)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _update_config(self)
        _update_talents()
    end
end)

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateIngame" then
        _update_talents()
    end
end

mod.on_all_mods_loaded = function()
    --_update_talents()
    _update_config()
end

mod.on_setting_changed = function(id)
    _update_config()
    --_update_talents()
end

mod.debug = {
    is_enabled = function()
        return mod:get("enable_debug_mode")
    end,
    echo = function(text)
        if mod.debug.is_enabled() then
            mod:echo(text)
        end
    end,
}

--recursively prints an entire table, used for debugging only
function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            --print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

--checks to see if a table has a specified value
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
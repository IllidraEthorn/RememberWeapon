local mod = get_mod("SafePsyking")

local Overheat = require("scripts/utilities/overheat")

local prev_action = nil
local request = nil
local after_request_type = nil
local count = 0

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

local unsafe_at_100_percent_warp_charge_level_config = {}
local unsafe_at_97_percent_warp_charge_level_config = {}
local unsafe_at_100_percent_overheat_level_config = {}

local _update_config = function()
    unsafe_at_100_percent_warp_charge_level_config = {}
    unsafe_at_97_percent_warp_charge_level_config = {}
    unsafe_at_100_percent_overheat_level_config = {}
    if mod:get('rapid_left_forcestaff_p1_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'rapid_left_forcestaff_p1_m1_projectile')
    end
    if mod:get('action_trigger_explosion_forcestaff_p1_m1_use_aoe') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_trigger_explosion_forcestaff_p1_m1_use_aoe')
    end
    if mod:get('action_shoot_flame_forcestaff_p2_m1_flame_burst') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_shoot_flame_forcestaff_p2_m1_flame_burst')
    end
    if mod:get('action_shoot_charged_flame_forcestaff_p2_m1_flamer_gas') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_shoot_charged_flame_forcestaff_p2_m1_flamer_gas')
    end
    if mod:get('rapid_left_forcestaff_p3_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'rapid_left_forcestaff_p3_m1_projectile')
    end
    if mod:get('action_shoot_charged_forcestaff_p3_m1_chain_lightning') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_shoot_charged_forcestaff_p3_m1_chain_lightning')
    end
    if mod:get('rapid_left_forcestaff_p4_m1_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'rapid_left_forcestaff_p4_m1_projectile')
    end
    if mod:get('action_shoot_charged_forcestaff_p4_m1_charged_projectile') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_shoot_charged_forcestaff_p4_m1_charged_projectile')
    end
    if mod:get('action_assail') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_rapid_right_psyker_throwing_knives')
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_rapid_left_psyker_throwing_knives')
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_rapid_zoomed_psyker_throwing_knives_homing')
    end
    if mod:get('action_brainburst') then
        table.insert(unsafe_at_100_percent_warp_charge_level_config, 'action_charge_target_lock_on_psyker_smite_lock_target')
        table.insert(unsafe_at_97_percent_warp_charge_level_config, 'action_charge_target_sticky_psyker_smite_lock_target')
    end
    if mod:get('action_shoot_charged_plasmagun_p1_m1_shoot_charged') then
        table.insert(unsafe_at_100_percent_overheat_level_config, 'action_shoot_charged_plasmagun_p1_m1_shoot_charged')
    end
end

mod:hook(CLASS.ActionHandler, "_validate_action", function(func, self, action_settings, condition_func_params, t, used_input)
    local val = func(self, action_settings, condition_func_params, t, used_input)

    if action_settings.charge_template then
        local unit_data_extension = self._unit_data_extension


        local warp_charge_component = unit_data_extension:read_component("warp_charge")
        local warp_charge_level = warp_charge_component.current_percentage
        local overheat_level = 0
        local inventory_slot_component = unit_data_extension:read_component("slot_secondary")

        if inventory_slot_component ~= nil and inventory_slot_component.overheat_current_percentage ~= nil then
            
            overheat_level = inventory_slot_component.overheat_current_percentage
            --print("-----"..count.."-----")
            --tprint(inventory_slot_component)
        end

        count = count + 1
        mod.debug.echo("-----"..count.."-----")

        mod.debug.echo(action_settings.charge_template)
        mod.debug.echo("Overheat: "..overheat_level.." Peril: "..warp_charge_level)

        if has_value(unsafe_at_100_percent_warp_charge_level_config, action_settings.charge_template) and not (warp_charge_level < 1) then
            mod.debug.echo("Cancel ACTION")
            return false
        elseif has_value(unsafe_at_97_percent_warp_charge_level_config, action_settings.charge_template) and not (warp_charge_level < 0.97) then
            mod.debug.echo("Cancel ACTION")
            return false
        elseif has_value(unsafe_at_100_percent_overheat_level_config, action_settings.charge_template) and not (overheat_level < 1) then
            mod.debug.echo("Cancel ACTION")
            return false
        end
    end
    return val
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _update_config()
    end
end)

mod.on_all_mods_loaded = function()
    _update_config()
end

mod.on_setting_changed = function(id)
    _update_config()
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
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
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
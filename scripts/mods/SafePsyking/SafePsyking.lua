local mod = get_mod("SafePsyking")

local Overheat = require("scripts/utilities/overheat")

local prev_action = nil
local request = nil
local after_request_type = nil
local count = 0
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

local _update_request_type = function()
    if Managers and Managers.player then
        local player = Managers.player:local_player(1)
        if player and player._profile and player._profile.specialization then
            local plr_class = player._profile.specialization

            if plr_class == "psyker_2" then
                after_request_type = mod:get("sp_psyker")
            end

            if after_request_type == "" then
                after_request_type = nil
            end
        end
    end
end

mod:hook(CLASS.ActionHandler, "_validate_action", function(func, self, action_settings, condition_func_params, t, used_input)
    local val = func(self, action_settings, condition_func_params, t, used_input)
    local unit_data_extension = self._unit_data_extension

    warp_charge_component = unit_data_extension:read_component("warp_charge")
    warp_charge_level = warp_charge_component.current_percentage

    if action_settings.charge_template then
        count = count + 1
        mod.debug.echo("-----"..count.."-----")
        --mod.debug.echo("Charge Template: "..action_settings.charge_template)

        if has_value(unsafe_at_100_percent, action_settings.charge_template) and not (warp_charge_level < 1) then
            mod.debug.echo("Cancel ACTION")
            return
        elseif has_value(unsafe_at_97_percent, action_settings.charge_template) and not (warp_charge_level < 0.97) then
            mod.debug.echo("Cancel ACTION")
            return
        end
    end
    return val
end)

mod:hook_safe(CLASS.GameModeManager, "init", function(self, game_mode_context, game_mode_name, ...)
    if game_mode_name ~= "hub" then
        _update_request_type()
    end
end)

mod.on_setting_changed = function(id)
    _update_request_type()
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

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
/* AddCSLuaFile */
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("client/round/cl_round_manager.lua")
AddCSLuaFile("client/hud/cl_hud.lua")
AddCSLuaFile("client/hud/cl_scoreboard.lua")

/* Include Server Files */
include("shared.lua")

include("server/utils/sv_timers.lua")

include("server/sv_entry_point.lua")
include("server/round/sv_round.lua")

include("server/internals/sv_network.lua")
include("server/internals/sv_map.lua")
include("server/internals/sv_spawns.lua")
include("server/internals/sv_player.lua")

include("server/extensions/sv_entity.lua")
include("server/extensions/sv_player.lua")
include("server/extensions/sv_spectator.lua")

hook.Add("AllowPlayerPickup", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)
hook.Add("PlayerCanPickupItem", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)
hook.Add("PlayerCanPickupWeapon", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)

hook.Add("EntityTakeDamage", "DamageMultiplier", function(target, dmginfo)
    if (target:IsPlayer() && dmginfo:GetAttacker():IsPlayer() && dmginfo:GetDamageType() == DMG_CLUB) then
        dmginfo:SetDamage(target:GetMaxHealth() / 2)
    end
end)
hook.Add("PlayerShouldTakeDamage", "AntiTeamKill", function(ply, attacker)
	if (attacker:IsPlayer() && ply:Team() == attacker:Team()) then
		return false
	end
end)
hook.Add("PlayerShouldTakeDamage", "SpectatorGodMode", function(ply, attacker)
	if (ply:IsSpectator()) then
		return false
	end
end)

hook.Add("EntityKeyValue", "tf2_logic_auto_fix", function(ent, key, value)
    if (ent:GetClass() == "logic_auto" && (key == "OnMultiNewMap" || key == "OnMultiNewRound")) then
        ent:Fire("AddOutput", string.format("%s %s", "OnMapSpawn", value))
    end
end)

hook.Add("PlayerUse", "DisallowSpectatorUse", function(ply, ent)
	if (ply:IsSpectator()) then
		return false
	end
end)
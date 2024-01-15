/* AddCSLuaFile */
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("client/cl_round_manager.lua")
AddCSLuaFile("client/cl_hud.lua")

/* Include Server Files */
include("shared.lua")
include("server/sv_timers.lua")
include("server/sv_round_manager.lua")
include("server/sv_entry_point.lua")

include("server/sv_utils.lua")
include("server/sv_spawns.lua")

include("server/sv_entity.lua")
include("server/sv_player.lua")
include("server/sv_spectator.lua")

util.AddNetworkString("SyncTeamCreation")

function GM:PlayerInitialSpawn(ply)
    ply:SyncTeams()

    net.Start('GameStateUpdate')
        net.WriteInt(RoundManager.GameState, 8)
    net.Send(ply)

    ply.InitialSpawn = true
end

function GM:PlayerSpawn(ply)
    if (ply.Initialized == nil) then ply.Initialized = false end

	if (!ply.Initialized) then
		ply.Initialized = true

		if (RoundManager.GameState == STATE.AWAIT) then
			ply:SetRunner()
		else
			ply:SetSpectator()
		end
	end

	ply.InitialSpawn = false
end

function GM:PlayerDeath(ply)
    ply.NextRespawn = CurTime() + 3
end

function GM:PlayerDeathThink(ply)
    if (CurTime() > ply.NextRespawn) then
        ply.Initialized = false
        ply:Spawn()
        return
    end

    return false
end

function GM:PlayerNoClip()
    return true
end

function GM:PlayerSpawnAsSpectator(ply)
    ply:SetSpectator()
end

function GM:CanPlayerSuicide(ply)
    return ply:IsRunner() || ply:IsActivator()
end

function GM:GetFallDamage(ply, speed)
    return (5 * ( speed / 300 ))
end

hook.Add("AllowPlayerPickup", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)
hook.Add("PlayerCanPickupItem", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)
hook.Add("PlayerCanPickupWeapon", "SpectatorDisablePickup", function(ply, ent)
    if (ply:IsSpectator()) then return false end
end)

hook.Add("EntityTakeDamage", "ActivatorCrushDmgDisable", function(target, dmginfo)
    if (target:IsPlayer() && target:IsActivator() && dmginfo:GetDamageType() == DMG_CRUSH) then return true end
end)
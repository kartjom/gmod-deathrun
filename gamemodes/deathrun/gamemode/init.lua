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
util.AddNetworkString("PlaySound")
util.AddNetworkString("RoundEnd")

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

    if (ply:Team() == TEAM.RUNNER) then
        local runnersRemaining = #RoundManager.GetRunners()
    
        if (!RoundManager.FirstBlood && runnersRemaining > 1) then
            RoundManager.FirstBlood = true
    
            PlaySound(string.format("vo/announcer_am_firstblood0%d.mp3", math.random(1, 6)))
        end
    
        if (!RoundManager.LastManAlive && runnersRemaining == 1) then
            RoundManager.LastManAlive = true
    
            PlaySound(string.format("vo/announcer_am_lastmanalive0%d.mp3", math.random(1, 4)))
        end
    end
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

function GM:IsSpawnpointSuitable(ply, spawnpoint, makeSuitable)
    return true
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
hook.Add("PlayerShouldTakeDamage", "AntiTeamKill", function(ply, attacker)
	if (attacker:IsPlayer() && ply:Team() == attacker:Team()) then
		return false
	end
end)

hook.Add("EntityKeyValue", "tf2_logic_auto_fix", function(ent, key, value)
    if (ent:GetClass() == "logic_auto" && (key == "OnMultiNewMap" || key == "OnMultiNewRound")) then
        ent:Fire("AddOutput", string.format("%s %s", "OnMapSpawn", value))
    end
end)
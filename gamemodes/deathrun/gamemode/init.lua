/* Send to client */
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

/* Network Strings */
util.AddNetworkString("DEATHRUN.PlaySound")
util.AddNetworkString("DEATHRUN.RoundEnd")

util.AddNetworkString("DEATHRUN.ShowAnnotation")
util.AddNetworkString("DEATHRUN.HideAnnotation")
util.AddNetworkString("DEATHRUN.ClearAnnotations")

/* Include Server Files */
include("shared.lua")
include("server/sv_entity.lua")
include("server/sv_player.lua")
include("server/sv_map.lua")
include("server/sv_spectator.lua")
include("server/sv_entry_point.lua")
include("server/round_manager/sv_round_manager.lua")
include("server/round_manager/sv_round_utils.lua")

/* Expose client sided lua and all resources */
util.IterateDirectory(AddCSLuaFile, "gamemodes/deathrun/gamemode/client", ".lua")
util.IterateDirectory(resource.AddSingleFile, "gamemodes/deathrun/content")

function GM:PlayerInitialSpawn(ply)
	ply.InitialSpawn = true
end

function GM:PlayerSpawn(ply)
	if (ply.InitialSpawn) then
		ply.InitialSpawn = nil

		if (DEATHRUN.RoundManager.GetState() != DEATHRUN.STATE.AWAIT) then
			ply:SetTeam( DEATHRUN.TeamRunner() )
			ply:KillSilent()

			return
		else
			player_manager.SetPlayerClass(ply, "deathrun_runner")
    		player_manager.RunClass(ply, "SetTeam")
		end
	end

	player_manager.OnPlayerSpawn(ply, false)
	player_manager.RunClass(ply, "SetTeam")
	player_manager.RunClass(ply, "Spawn")
	player_manager.RunClass(ply, "Loadout")
	player_manager.RunClass(ply, "SetModel")
end

function GM:PlayerDeathThink(ply)
	if (DEATHRUN.RoundManager.GetState() == DEATHRUN.STATE.AWAIT) then
		ply:Spawn()
		return
	end

	DEATHRUN.SpectatorThink(ply)
	return false
end

function GM:GetFallDamage(ply, speed)
    return (5 * ( speed / 300 ))
end

function GM:PlayerNoClip(ply)
    return ply:IsAdmin() || GetConVar("sv_cheats"):GetBool()
end

hook.Add("PlayerDeath", "PlayerDeath", function(ply)
	if (DEATHRUN.RoundManager.GetState() != DEATHRUN.STATE.ACTION) then return end
	if (ply:Team() != DEATHRUN.TeamRunner()) then return end

	local runnersRemaining = #DEATHRUN.RoundManager.GetRunners()

	if (!DEATHRUN.RoundManager.FirstBlood && runnersRemaining > 1) then
		DEATHRUN.RoundManager.FirstBlood = true
		
		PlaySound(string.format("vo/announcer_am_firstblood0%d.mp3", math.random(1, 6)))
	end

	if (!DEATHRUN.RoundManager.LastManAlive && runnersRemaining == 1) then
		DEATHRUN.RoundManager.LastManAlive = true
		
		PlaySound(string.format("vo/announcer_am_lastmanalive0%d.mp3", math.random(1, 4)))
	end
end)
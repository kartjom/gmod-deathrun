/* AddCSLuaFile */
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

/* Include Server Files */
include("shared.lua")

include("server/sv_utils.lua")
include("server/sv_spawns.lua")

include("server/sv_entity.lua")
include("server/sv_player.lua")

include("server/sv_round_manager.lua")
include("server/sv_spectator.lua")

util.AddNetworkString("SyncTeamCreation")

function GM:PlayerInitialSpawn(ply)
    net.Start("SyncTeamCreation")
        net.WriteInt(TEAM.RUNNER, 16)
        net.WriteInt(TEAM.ACTIVATOR, 16)
    net.Send(ply)
end

function GM:InitPostEntity()
    local mapver = self:GetMapVersion()

    if (mapver == MAPVER.CSS || mapver == MAPVER.OTHER) then
        TEAM.RUNNER = 3
        TEAM.ACTIVATOR = 2
    end

    if (mapver == MAPVER.TF2) then
        TEAM.RUNNER = 2
        TEAM.ACTIVATOR = 3
    end

    team.SetUp(TEAM.RUNNER, "Runners", Color(0, 100, 255))
    team.SetUp(TEAM.ACTIVATOR, "Activator", Color(255, 0, 0))
end

function GM:PlayerNoClip()
    return true
end

function GM:PlayerSpawnAsSpectator(ply)
    ply:SetSpectator()
end

function GM:PlayerDeath(ply)
    ply.NextRespawn = CurTime() + 3
end

function GM:PlayerDeathThink(ply)
    if (CurTime() > ply.NextRespawn) then
        ply:SetSpectator()
        return
    end

    return false
end

function GM:GetFallDamage(ply, speed)
    return (speed / 7)
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
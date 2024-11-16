AddCSLuaFile()
DEFINE_BASECLASS("deathrun_base")
 
local PLAYER = {}

PLAYER.JumpPower = 220
PLAYER.WalkSpeed = 360
PLAYER.RunSpeed = 360

function PLAYER:SetNetworkedVariables()
	self.Player:SetTFClass(DEATHRUN.TFCLASS.SCOUT)
end

function PLAYER:SetTeam()
	self.Player:SetTeam(DEATHRUN.TeamActivator())
end

player_manager.RegisterClass("deathrun_activator", PLAYER, "deathrun_base")
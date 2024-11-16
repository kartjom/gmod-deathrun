AddCSLuaFile()
DEFINE_BASECLASS("deathrun_base")
 
local PLAYER = {}

PLAYER.JumpPower = 180
PLAYER.WalkSpeed = 270
PLAYER.RunSpeed = 270

function PLAYER:SetNetworkedVariables()
	self.Player:SetTFClass( table.Random(DEATHRUN.TFCLASS) )
end

function PLAYER:SetTeam()
	self.Player:SetTeam(DEATHRUN.TeamRunner())
end

player_manager.RegisterClass("deathrun_runner", PLAYER, "deathrun_base")
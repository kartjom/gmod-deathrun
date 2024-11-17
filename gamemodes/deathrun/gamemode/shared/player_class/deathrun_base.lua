AddCSLuaFile()
DEFINE_BASECLASS("player_default")
 
local PLAYER = {}

PLAYER.TeammateNoCollide = true
 
-- gamemodes/base/player_class/player_default.lua
function PLAYER:SetupDataTables()
    self.Player:NetworkVar("Int", 0, "TFClass")
end

function PLAYER:SetNetworkedVariables() -- override this
end

function PLAYER:SetTeam() -- override this
end

function PLAYER:Spawn()
    self:SetNetworkedVariables()

	self.Player:UnSpectate()
    self.Player:SetPlayerColor( team.GetColor( self.Player:Team() ):ToVector() )
end

function PLAYER:SetModel()
	local modelname = string.format("models/player/group01/male_0%d.mdl", math.random(1, 9))
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
end

function PLAYER:Loadout()
	self.Player:StripWeapons()
	self.Player:RemoveAllAmmo()

	self.Player:Give("weapon_crowbar")
    self.Player:SelectWeapon("weapon_crowbar")
end

player_manager.RegisterClass("deathrun_base", PLAYER, "player_default")
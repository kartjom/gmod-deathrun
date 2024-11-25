AddCSLuaFile()
DEFINE_BASECLASS("player_default")
 
local PLAYER = {}

PLAYER.TeammateNoCollide = true
PLAYER.CrouchedWalkSpeed = 0.4
PLAYER.DuckSpeed = 0.4
 
-- gamemodes/base/player_class/player_default.lua
function PLAYER:SetupDataTables()
    self.Player:NetworkVar("Int", 0, "TFClass")
end

function PLAYER:SetNetworkedVariables() -- override this
    self.Player:SetTFClass(0)
end

function PLAYER:SetTeam() -- override this
end

function PLAYER:Spawn()
    self:SetNetworkedVariables()
	
	self.Player:UnSpectate()
    self.Player:SetPlayerColor( team.GetColor( self.Player:Team() ):ToVector() )

	self.Player:SetParent(NULL)
    self.Player:SetGravity(0)
    self.Player:Extinguish()
	self.Player:GodDisable()

    self.Player:StripWeapons()
    self.Player:RemoveAllAmmo()

    self.Player:SetNoDraw(false)
    self.Player:SetColor(Color(255, 255, 255, 255))
    self.Player:SetCustomCollisionCheck(false)
    self.Player:SetNoTarget(false)
    self.Player:AllowFlashlight(true)
    self.Player:SetCanZoom(true)
    self.Player:Freeze(false)
    self.Player:SetMoveType(MOVETYPE_WALK)
end

function PLAYER:Death()
    self.Player:SetParent(NULL)
    self.Player:SetGravity(0)
    self.Player:Extinguish()
	self.Player:GodDisable()
end

function PLAYER:SetModel()
	local modelname = string.format("models/player/group01/male_0%d.mdl", math.random(1, 9))
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
	self.Player:SetupHands()
end

function PLAYER:Loadout()
	self.Player:Give("weapon_crowbar")
    self.Player:SelectWeapon("weapon_crowbar")
end

player_manager.RegisterClass("deathrun_base", PLAYER, "player_default")
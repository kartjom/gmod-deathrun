local ply = FindMetaTable("Player")

hook.Add("KeyPress", "Spectating", function(ply, key)
	if (!ply:IsSpectator()) then return end

	if (key == IN_ATTACK && ply:GetObserverMode() != OBS_MODE_ROAMING) then
		ply:SpectateNext()
	elseif (key == IN_ATTACK2 && ply:GetObserverMode() != OBS_MODE_ROAMING) then
		ply:SpectatePrevious()
	elseif (key == IN_RELOAD) then
		ply:ChangeSpecMode()
	end
end)

function ply:IsSpectator()
    return self:Alive() && self:Team() == TEAM.SPECTATOR
end

function ply:SetSpectator()
	self:ResetData()
    self.Initialized = true

	self:SetTeam(TEAM.SPECTATOR)
	self:Spawn()
	self:Spectate(OBS_MODE_ROAMING)
	self.SpecPly = 1

	self:StripWeapons()
	self:RemoveAllAmmo()
	self:CrosshairDisable()
	self:SetNoDraw(true)
	self:SetNoCollideWithTeammates(true)
	self:SetNoTarget(true)
	self:AllowFlashlight(false)
	self:GodEnable()
end

function ply:StopSpectating()
    self:UnSpectate()
    self:ResetData()

    self:Spawn()
end

function ply:SpectateNext()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetPlayers(false)
	if (#players < 1) then return end
	
	if (self.SpecPly + 1 > #players) then self.SpecPly = 1 else self.SpecPly = self.SpecPly + 1 end
	self:SpectateEntity(players[self.SpecPly])
end

function ply:SpectatePrevious()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetPlayers(false)
	if (#players < 1) then return end
	
	if (self.SpecPly - 1 < 1) then self.SpecPly = #players else self.SpecPly = self.SpecPly - 1 end
	self:SpectateEntity(players[self.SpecPly])
end

function ply:ChangeSpecMode()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetPlayers(false)
	local mode = self:GetObserverMode()

	if (#players < 1) then self:SetObserverMode(OBS_MODE_ROAMING) return end

	if (mode == OBS_MODE_ROAMING) then
		if (#players < 1) then return end
		if (self:GetObserverTarget() == NULL) then 
			if ( IsValid(players[self.SpecPly]) ) then
				if ( !players[self.SpecPly]:IsSpectator() ) then
					self:SpectateEntity(players[self.SpecPly])
				else self:SpectateNext() end
			else self:SpectateNext() end
		end
		self:SetObserverMode(OBS_MODE_IN_EYE) -- First person
	elseif (mode == OBS_MODE_IN_EYE) then
		self:SetObserverMode(OBS_MODE_CHASE) -- Third person
	elseif (mode == OBS_MODE_CHASE) then
		self:SetObserverMode(OBS_MODE_ROAMING) -- Free roam
	end
end
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

function ply:SetSpectator()
	self:StripWeapons()
	self:RemoveAllAmmo()
	
	self:SetTeam(TEAM.SPECTATOR)
	self:Spectate(OBS_MODE_ROAMING)
	self.SpecPly = 1
end

function ply:SpectateNext()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetAlive()
	if (#players < 1) then return end
	
	if (self.SpecPly + 1 > #players) then self.SpecPly = 1 else self.SpecPly = self.SpecPly + 1 end
	self:SpectateEntity(players[self.SpecPly])
end

function ply:SpectatePrevious()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetAlive()
	if (#players < 1) then return end
	
	if (self.SpecPly - 1 < 1) then self.SpecPly = #players else self.SpecPly = self.SpecPly - 1 end
	self:SpectateEntity(players[self.SpecPly])
end

function ply:ChangeSpecMode()
	if (!self:IsSpectator()) then return end

	local players = RoundManager.GetAlive()
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

		self:ChatPrint("First person mode")
		self:SetObserverMode(OBS_MODE_IN_EYE)
	elseif (mode == OBS_MODE_IN_EYE) then
		self:ChatPrint("Third person mode")
		self:SetObserverMode(OBS_MODE_CHASE)
	elseif (mode == OBS_MODE_CHASE) then
		self:ChatPrint("Free roam mode")
		self:SetObserverMode(OBS_MODE_ROAMING)
	end
end
function DEATHRUN.SpectatorThink(ply)
	local mode = ply:GetObserverMode()
	if (mode != OBS_MODE_ROAMING && mode != OBS_MODE_IN_EYE && mode != OBS_MODE_CHASE) then
		ply:UnSpectate()
		ply:Spectate(OBS_MODE_ROAMING)
	elseif ((mode == OBS_MODE_IN_EYE || mode == OBS_MODE_CHASE) && ( !IsValid(ply:GetObserverTarget()) )) then
		ply:UnSpectate()
		ply:Spectate(OBS_MODE_ROAMING)
	end
end

hook.Add("KeyPress", "DEATHRUN.Spectator", function(ply, key)
	local currentMode = ply:GetObserverMode()
	local currentTarget = ply:GetObserverTarget()
	
	if (!ply:IsSpectator()) then return end

	if (key == IN_ATTACK) then
		ply:SpectateNext(currentTarget)
	elseif (key == IN_ATTACK2) then
		ply:SpectatePrevious(currentTarget)
	elseif (key == IN_RELOAD) then
		ply:ChangeSpecMode(currentMode, currentTarget)
	end
end)

local ply = FindMetaTable("Player")

function ply:SpectateNext(currentTarget)
	local nextTarget = util.GetNextAlivePlayer(currentTarget)
	if ( !IsValid(nextTarget) || currentTarget == nextTarget ) then
		-- self:ChatPrint("SpectateNext: No valid target")
		return
	end

	if (IsValid(nextTarget)) then
		self:SpectateEntity(nextTarget)
		self:SetPos(nextTarget:GetPos() + Vector(0, 0, 64))
		self:SetupHands(nextTarget)
	end
end

function ply:SpectatePrevious(currentTarget)
	local previousTarget = util.GetPreviousAlivePlayer(currentTarget)
	if ( !IsValid(previousTarget) || currentTarget == previousTarget ) then
		-- self:ChatPrint("SpectatePrevious: No valid target")
		return
	end

	if (IsValid(previousTarget)) then
		self:SpectateEntity(previousTarget)
		self:SetPos(previousTarget:GetPos() + Vector(0, 0, 64))
		self:SetupHands(previousTarget)
	end
end

function ply:ChangeSpecMode(currentMode, currentTarget)
	local players = #util.GetAlivePlayers()

	if (players < 1) then -- no alive players
		if (IsValid(currentTarget)) then
			self:UnSpectate()
		end
		self:Spectate(OBS_MODE_ROAMING)

		return
	end

	if (currentMode == OBS_MODE_ROAMING) then
		self:Spectate(OBS_MODE_IN_EYE)
		--self:ChatPrint("First person mode")
	elseif (currentMode == OBS_MODE_IN_EYE) then
		self:Spectate(OBS_MODE_CHASE)
		--self:ChatPrint("Third person mode")
	elseif (currentMode == OBS_MODE_CHASE) then
		self:Spectate(OBS_MODE_ROAMING)
		--self:ChatPrint("Free roam mode")
	end
end
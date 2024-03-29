ENT.Base = "base_entity"
ENT.Type = "point"

ENT.AllowedInputs = {
    ["ForceRespawn"] = true,
    ["ForceRespawnSwitchTeams"] = true,
    ["ForceTeamRespawn"] = true
}

function ENT:KeyValue(key, value)
    if (string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (self.AllowedInputs[inputName]) then
        if (inputName == "ForceTeamRespawn" && data != nil) then
            self:ForceTeamRespawn(tonumber(data))
        else
            self:ForceRespawn()
        end

        self:TriggerOutput("OnForceRespawn")
    else
        --PrintMessage(HUD_PRINTTALK, "[DEV] Unhandled input: game_forcerespawn "..inputName..": "..tostring(data))
    end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

function ENT:ForceTeamRespawn(team)
    for k,v in pairs(player.GetAll()) do
        if (v:IsSpectator() || !v:Alive()) then
            v:SetRunner()
        end
    end
end

function ENT:ForceRespawn()
    for k,v in pairs(player.GetAll()) do
        if (v:IsActivator()) then
            v:SetActivator()
        elseif (v:IsRunner() || v:IsSpectator() || !v:Alive()) then
            v:SetRunner()
        end
    end
end
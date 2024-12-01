ENT.Base = "base_filter"
ENT.Type = "filter"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "SetTeam")) then self:SetTeam( tonumber(data) ) return end
end

function ENT:Initialize()
    self.TeamNum = self:GetStoredValue("TeamNum", "int", 0)
end

function ENT:PassesFilter(trigger, ent)
	local result = ent:IsPlayer() && !ent:IsSpectator() && ent:Team() == self.TeamNum
	return result
end

function ENT:SetTeam(num)
    self.TeamNum = num
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
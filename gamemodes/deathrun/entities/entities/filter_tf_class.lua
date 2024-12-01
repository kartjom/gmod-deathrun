ENT.Base = "base_filter"
ENT.Type = "filter"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:PassesFilter(trigger, ent)
	return ent:IsPlayer() && !ent:IsSpectator() && ent:GetTFClass() == self.tfclass
end

function ENT:Initialize()
    self.tfclass = self:GetStoredValue("tfclass", "int", 0)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end
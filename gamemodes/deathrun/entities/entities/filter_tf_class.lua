ENT.Base = "base_filter"
ENT.Type = "filter"

function ENT:KeyValue(key, value)
	self:StoreValue(key, value)
end

-- function ENT:AcceptInput(inputName, activator, caller, data)
--     PrintMessage(HUD_PRINTTALK, "[DEV] filter_tf_class "..inputName..": "..tostring(data))
-- end

function ENT:PassesFilter(trigger, ent)
	-- TODO: handle 'Negated' key value

	local tfclass = self:GetStoredValue("tfclass", "int")
	return ent:IsPlayer() && !ent:IsSpectator() && tfclass == TFCLASS.SCOUT -- only scout will trigger OnPass
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end
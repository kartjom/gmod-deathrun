ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    PrintMessage(HUD_PRINTTALK, "[DEV] tf_logic_arena "..inputName..": "..tostring(data))
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
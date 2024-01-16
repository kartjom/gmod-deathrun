ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:AcceptInput(inputName, activator, caller, data)
    PrintMessage(HUD_PRINTTALK, "[DEV] game_forcerespawn "..inputName..": "..tostring(data))
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
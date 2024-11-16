ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

-- function ENT:AcceptInput(inputName, activator, caller, data)
--     PrintMessage(HUD_PRINTTALK, "[DEV] tf_logic_arena "..inputName..": "..tostring(data))
-- end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end

function tf_logic_arena_OnArenaRoundStart()
    for k,v in pairs(ents.FindByClass("tf_logic_arena")) do
        v:TriggerOutput("OnArenaRoundStart")
    end
end
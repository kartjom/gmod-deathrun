ENT.Base = "base_entity"
ENT.Type = "brush"

ENT.Enabled = true

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:Initialize()
    self.Enabled = !self:GetStoredValue("startdisabled", "bool", false)
end

function ENT:StartTouch(entity)
    self:TriggerOutput("OnStartTouch")
end

function ENT:Touch(entity)
    if (!self.Enabled) then return end
    
    local duration = self:GetStoredValue("burn_duration", "int", 1)
    entity:Ignite(duration)

    self:TriggerOutput("OnTouching")
end

function ENT:EndTouch(entity)
    self:TriggerOutput("OnEndTouch")
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "enable")) then self.Enabled = true end
    if (string.iequals(inputName, "disable")) then self.Enabled = false end
    if (string.iequals(inputName, "toggle")) then self.Enabled = !self.Enabled end

    --PrintMessage(HUD_PRINTTALK, "[DEV] trigger_ignite "..inputName..": "..tostring(data))
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
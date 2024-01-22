ENT.Base = "base_entity"
ENT.Type = "brush"

ENT.Enabled = true

function ENT:KeyValue(key, value)
    if (string.Left(key, 2) == "On") then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:Initialize()
    local startDisabled = self:GetStoredValue("startdisabled")
    if (startDisabled) then
        self.Enabled = false
    end
end

function ENT:StartTouch(entity)
    self:TriggerOutput("OnStartTouch")
end

function ENT:Touch(entity)
    if (!self.Enabled) then return end
    
    local duration = self:GetStoredValue("burn_duration", "int") || 1
    entity:Ignite(duration)

    self:TriggerOutput("OnTouching")
end

function ENT:EndTouch(entity)
    self:TriggerOutput("OnEndTouch")
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.lower(inputName) == "enable") then self.Enabled = true end
    if (string.lower(inputName) == "disable") then self.Enabled = false end
    if (string.lower(inputName) == "toggle") then self.Enabled = !self.Enabled end

    PrintMessage(HUD_PRINTTALK, "[DEV] trigger_ignite "..inputName..": "..tostring(data))
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
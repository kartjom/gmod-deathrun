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
    
    if (entity:IsPlayer()) then
        entity:SetPos(self:GetPos() + self:GetStoredValue("teleportoffset", "Vector"))
    end

    self:TriggerOutput("OnTouching")
end

function ENT:EndTouch(entity)
    self:TriggerOutput("OnEndTouch")
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "enable")) then self.Enabled = true end
    if (string.iequals(inputName, "disable")) then self.Enabled = false end
    if (string.iequals(inputName, "toggle")) then self.Enabled = !self.Enabled end

    --PrintMessage(HUD_PRINTTALK, "[DEV] trigger_teleport_relative "..inputName..": "..tostring(data))
end

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end
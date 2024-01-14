AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "brush"

ENT.Enabled = true

function ENT:KeyValue(key, value)
    self:StoreValue(key, value)
end

function ENT:Initialize()
    local startDisabled = self:GetStoredValue("startdisabled")
    if (startDisabled) then
        self.Enabled = false
    end
end

function ENT:Touch(entity)
    if (!self.Enabled) then return end
    
    if (entity:IsPlayer()) then
        entity:SetPos(self:GetPos() + self:GetStoredValue("teleportoffset", "Vector"))
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.lower(inputName) == "enable") then self.Enabled = true end
    if (string.lower(inputName) == "disable") then self.Enabled = false end
    if (string.lower(inputName) == "toggle") then self.Enabled = !self.Enabled end
end
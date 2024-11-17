ENT.Base = "base_entity"
ENT.Type = "point"

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "Show")) then self:Show() end
    if (string.iequals(inputName, "Hide")) then self:Hide() return end
end

function ENT:Show()
    local text = self:GetStoredValue("display_text", "string", nil)
    if (text == nil) then return end -- don't continue if text is empty

    local lifetime = self:GetStoredValue("lifetime", "float", 0)
    local vertical_offset = self:GetStoredValue("offset", "float", 0)

    if (lifetime == 0) then lifetime = 1 end

    net.Start("DEATHRUN.ShowAnnotation")
        net.WriteUInt(self:EntIndex(), 13)
        net.WriteString(text)
        net.WriteVector(self:GetPos() + Vector(0, 0, vertical_offset))

        if (lifetime <= -1) then
            net.WriteInt(-1, 32)
        else
            net.WriteInt(CurTime() + lifetime, 32)
        end
    net.Broadcast()
end

function ENT:Hide()
    net.Start("DEATHRUN.HideAnnotation")
        net.WriteUInt(self:EntIndex(), 13)
    net.Broadcast()
end
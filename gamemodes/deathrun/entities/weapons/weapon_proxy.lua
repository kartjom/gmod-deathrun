if (CLIENT) then return end

SWEP.Target = "weapon_crowbar"

function SWEP:Initialize()
    local wep = ents.Create(self.Target)
    wep:SetPos(self:GetPos())
    wep:SetAngles(self:GetAngles())
    wep:Spawn()
    wep:GetPhysicsObject():Sleep()

    self:Remove()
end
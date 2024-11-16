AddCSLuaFile()
DEFINE_BASECLASS("tf_base_pickup")

ENT.Model = "models/items/medkit_large.mdl"
ENT.PickupSound = "HealthKit.Touch"

function ENT:OnPickup(other)
    local health = other:Health()
    local maxHealth = other:GetMaxHealth()

    if (health >= maxHealth) then return false end
    
    other:SetHealth( maxHealth )
    return true
end
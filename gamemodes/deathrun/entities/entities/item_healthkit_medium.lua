AddCSLuaFile()
DEFINE_BASECLASS("tf_base_pickup")

ENT.Model = "models/items/medkit_medium.mdl"
ENT.PickupSound = "HealthKit.Touch"

function ENT:OnPickup(other)
    local health = other:Health()
    local maxHealth = other:GetMaxHealth()

    if (health >= maxHealth) then return false end

    local afterHeal = health + (maxHealth * 0.50)
    other:SetHealth( math.min(afterHeal, maxHealth) )

    return true
end
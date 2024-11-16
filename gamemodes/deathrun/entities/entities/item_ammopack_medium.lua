AddCSLuaFile()
DEFINE_BASECLASS("tf_base_pickup")

ENT.Model = "models/items/ammopack_medium.mdl"
ENT.PickupSound = "BaseCombatCharacter.AmmoPickup"

function ENT:OnPickup(other)
    return true
end
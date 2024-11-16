AddCSLuaFile()
DEFINE_BASECLASS("tf_base_pickup")

ENT.Model = "models/items/ammopack_small.mdl"
ENT.PickupSound = "BaseCombatCharacter.AmmoPickup"

function ENT:OnPickup(other)
    return true
end
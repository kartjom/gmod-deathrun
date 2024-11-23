AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()
    self:DrawModel()
end

if (CLIENT) then return end

ENT.Damage = 100
ENT.SplashRadius = 170
ENT.Velocity = 1750

function ENT:Initialize()
    self:SetModel("models/buildables/sentry3_rockets.mdl")
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:DrawShadow(false)

    self:SetupCustomCollider()
    
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    phys:SetContents(CONTENTS_SOLID)
    phys:SetMass(1)
    phys:EnableGravity(false)

    self.RemoveAfter = CurTime() + 20
end

function ENT:Think()
    if (CurTime() >= self.RemoveAfter) then return self:Remove() end
    if (self.Hit == true) then return self:Explode() end

    self:GetPhysicsObject():SetVelocity(self:GetForward() * self.Velocity)

    self:NextThink(CurTime())
    return true
end

function ENT:PhysicsCollide(colData, collider)
    self.Hit = true
end

function ENT:Explode()
    local explode = ents.Create("env_explosion")
    explode:SetPos(self:GetPos())
    explode:Spawn()
    explode:Fire("Explode", 0, 0)

    util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, self:GetPos(), self.SplashRadius, self.Damage)
    
    self:Remove()
end
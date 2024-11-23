AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()
    self:DrawModel()
end

if (CLIENT) then return end

ENT.Damage = 75
ENT.SplashRadius = 170
ENT.Velocity = 1100

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_rocket.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)  
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()
    phys:SetMass(1)
    phys:EnableGravity(false)

    self.Trail = ents.Create("info_particle_system")
    self.Trail:SetKeyValue("effect_name", "rockettrail")
    self.Trail:SetParent(self)
    self.Trail:SetLocalPos(Vector(0, 0, 0))
    self.Trail:SetLocalAngles(Angle(180, 0, 0))
    self.Trail:Spawn()
    self.Trail:Activate()
    self.Trail:Fire("start", "", 0)

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

    local attacker = IsValid(self:GetOwner()) and self:GetOwner() or self
    util.BlastDamage(self, attacker, self:GetPos(), self.SplashRadius, self.Damage)
    
    self:Remove()
end

function ENT:OnRemove()
    if( IsValid(self.Trail) ) then self.Trail:Fire("kill", "", 0) end
end
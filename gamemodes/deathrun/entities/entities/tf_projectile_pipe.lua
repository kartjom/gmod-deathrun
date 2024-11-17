AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()
    self.Entity:DrawModel()
end

if (CLIENT) then return end

ENT.Damage = 75
ENT.SplashRadius = 150

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:DrawShadow(false)

    self.Trail = ents.Create("info_particle_system")
    self.Trail:SetKeyValue("effect_name", "pipebombtrail_red")
    self.Trail:SetParent(self)
    self.Trail:SetLocalPos(Vector(0, 0, 0))
    self.Trail:SetLocalAngles(Angle(0, 0, 0))
    self.Trail:Spawn()
    self.Trail:Activate()
    self.Trail:Fire("start", "", 0)

    self.ExplodeTimer = CurTime() + 3
end

function ENT:Think()
    if (self.Hit == true || CurTime() >= self.ExplodeTimer) then self:Explode() end

    self:NextThink(CurTime())
    return true
end

function ENT:PhysicsCollide(data)
    if (data.Speed > 50) then
        self:EmitSound("Grenade.ImpactHard")
    end

    if (data.HitEntity:IsNPC() || data.HitEntity:IsPlayer()) then
        self.Hit = true
    end
end

function ENT:Explode()
    local explode = ents.Create("env_explosion")
    explode:SetPos(self:GetPos())
    explode:Spawn()
    explode:Fire("Explode", 0, 0)

    util.BlastDamage(self, self:GetOwner(), self:GetPos(), self.SplashRadius, self.Damage)

    self:Remove()
end

function ENT:OnRemove()
    self.Trail:Fire("kill", "", 0)
end
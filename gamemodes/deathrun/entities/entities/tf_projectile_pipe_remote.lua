AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Draw()
    self:DrawModel()
end

if (CLIENT) then
    language.Add("tf_projectile_pipe_remote", "Sticky Bomb")
end

if (CLIENT) then return end

ENT.Damage = 75
ENT.SplashRadius = 150

function ENT:Initialize()
    self:SetModel("models/weapons/w_models/w_stickybomb.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:DrawShadow(false)

    self.Trail = ents.Create("info_particle_system")
    self.Trail:SetKeyValue("effect_name", "stickybombtrail_red")
    self.Trail:SetParent(self)
    self.Trail:SetLocalPos(Vector(0, 0, 0))
    self.Trail:SetLocalAngles(Angle(0, 0, 0))
    self.Trail:Spawn()
    self.Trail:Activate()
    self.Trail:Fire("start", "", 0)

    self.Hit = 0
    self.Activation = false
    self.ActivationTimer = CurTime() + 1
end

function ENT:Think()
    if (self.Hit == 1) then
        self.Hit = 2

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self:PhysicsInit(SOLID_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
    end

    if (!self.Activation && self.ActivationTimer <= CurTime()) then
        self.Pulse = ents.Create("info_particle_system")
        self.Pulse:SetKeyValue("effect_name", "stickybomb_pulse_red")
        self.Pulse:SetParent(self)
        self.Pulse:SetLocalPos(Vector(0, 0, 0))
        self.Pulse:SetLocalAngles(Angle(0, 0, 0))
        self.Pulse:Spawn()
        self.Pulse:Activate()
        self.Pulse:Fire("start", "", 0)

        self.Activation = true
    end

    self:NextThink(CurTime())
    return true
end

function ENT:PhysicsCollide()
    if (self.Hit == 0) then
        self.Hit = 1
    end
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
    if( IsValid(self.Pulse) ) then self.Pulse:Fire("kill", "", 0) end
end
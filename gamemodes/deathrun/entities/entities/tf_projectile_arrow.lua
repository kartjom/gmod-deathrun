AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"

function ENT:Draw()
	self:DrawModel()
end

if (CLIENT) then
    language.Add("tf_projectile_arrow", "Arrow")
end

if (CLIENT) then return end

ENT.Damage = 25

function ENT:Initialize()
	self:SetModel("models/weapons/w_models/w_arrow.mdl")
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
    self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
	self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    self:SetTrigger(true)
    self:SetNotSolid(true)
	self:DrawShadow(false)
    self:SetGravity(0.7)
	
    local size = 1
	self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size))

    util.SpriteTrail(self, 0, Color(255,255,255,255), false, 3, 1, 0.3, 1.0/(96.0 * 1.0), "effects/arrowtrail_red.vmt")

    self.Stuck = false
	self.RemoveAfter = CurTime() + 10
end

function ENT:Think()
	if (CurTime() >= self.RemoveAfter) then return self:Remove() end

	if (!self.Stuck) then
        self:SetAngles( self:GetVelocity():Angle() )
    end

	self:NextThink(CurTime())
    return true
end

function ENT:Touch(ent)
    local speed = self:GetVelocity():Length()

    if ent:IsWorld() then
        self.Stuck = true

        self:SetMoveType(MOVETYPE_NONE)
        self:PhysicsInit(SOLID_NONE)
        self:SetPos(self:GetPos() + self:GetForward())

        self:EmitSound("Weapon_Arrow.ImpactConcrete")
        ParticleEffect("impact_metal", self:GetPos(), Angle(), nil)

    elseif (ent:IsValid()) then

        local attacker = IsValid(self:GetOwner()) and self:GetOwner() or self
        ent:TakeDamage(self.Damage , attacker, self)
        
        local phy = ent:GetPhysicsObject()
        if (IsValid(phy)) then
            local physforce = speed * 4
            phy:ApplyForceCenter(self:GetForward() * physforce)
        end

        if (ent:IsPlayer() || ent:IsNPC()) then
            ent:EmitSound("Weapon_Arrow.ImpactConcrete")
            ParticleEffect("impact_metal", self:GetPos(), Angle(), nil)
        else
            self:PrecacheGibs()
	        self:GibBreakClient(Vector(math.random(-50, 50), math.random(-50, 50), math.random(50, 100)))

            self:Remove()
        end

        -- Should arrow dissapear?
        --self:Remove()
    end
end
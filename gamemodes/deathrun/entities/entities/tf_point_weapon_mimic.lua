AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "point"

if (CLIENT) then
    language.Add("tf_point_weapon_mimic", "World")
end

if (CLIENT) then return end

local WEAPON_STANDARD_ROCKET = 0
local WEAPON_STANDARD_GRENADE = 1
local WEAPON_STANDARD_ARROW = 2
local WEAPON_STICKY_GRENADE = 3

ENT.StickyBombs = {}

function ENT:UpdateTransmitState()	
	return TRANSMIT_NEVER
end

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "DetonateStickies")) then self:DetonateStickies() end
    if (string.iequals(inputName, "FireMultiple")) then self:FireMultiple( tonumber(data) ) return end
    if (string.iequals(inputName, "FireOnce")) then self:FireOnce() return end
end

function ENT:DetonateStickies()
    if (#self.StickyBombs <= 0) then return end

    self:EmitSound("Weapon_StickyBombLauncher.ModeSwitch")

    for k,v in ipairs(self.StickyBombs) do
        if (IsValid(v)) then
            v:Explode()
        end
    end

    self.StickyBombs = {}
end

function ENT:FireMultiple(count)
    self:PlayFireSound()
    self:PlayParticleEffect()
    
    for i=1, count do
        self:FireWeapon()
    end
end

function ENT:FireOnce()
    self:PlayFireSound()
    self:PlayParticleEffect()

    self:FireWeapon()
end

function ENT:FireWeapon()
    local weaponType = self:GetWeaponType()
    if (weaponType == WEAPON_STANDARD_ROCKET)   then    self:FireRocket()           end
    if (weaponType == WEAPON_STANDARD_GRENADE)  then    self:FireGrenade()          end
    if (weaponType == WEAPON_STANDARD_ARROW)    then    self:FireArrow()            end
    if (weaponType == WEAPON_STICKY_GRENADE)    then    self:FireStickyGrenade()    end
end

function ENT:FireRocket()
    local ent = ents.Create("tf_projectile_rocket")
    ent:Spawn()

    self:ApplyOverrides(ent, ent:GetPhysicsObject())
end

function ENT:FireGrenade()
    local ent = ents.Create("tf_projectile_pipe")
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    self:ApplyOverrides(ent, phys)

    phys:AddAngleVelocity(Vector( math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-500, 500) ))
end

function ENT:FireArrow()
    local ent = ents.Create("tf_projectile_arrow")
    ent:Spawn()

    self:ApplyOverrides(ent, ent)
end

function ENT:FireStickyGrenade()
    local ent = ents.Create( "tf_projectile_pipe_remote" )
    ent:Spawn()
    
    local phys = ent:GetPhysicsObject()
    self:ApplyOverrides(ent, phys)

    phys:AddAngleVelocity(Vector( math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-500, 500) ))

    table.insert(self.StickyBombs, ent)
end

-- Getters

function ENT:GetWeaponType()
    return self:GetStoredValue("WeaponType", "int", nil)
end

function ENT:PlayFireSound()
    local snd = self:GetStoredValue("FireSound", "string", nil)
    if (snd != nil) then self:EmitSound(snd) end
end

function ENT:PlayParticleEffect()
    local effect = self:GetStoredValue("ParticleEffect", "string", nil)
    if (effect != nil) then ParticleEffect(effect, self:GetPos(), Angle(), nil) end
end

function ENT:GetModelOverride()
    return self:GetStoredValue("ModelOverride", "string", nil)
end

function ENT:GetModelScale()
    return self:GetStoredValue("ModelScale", "int", nil)
end

function ENT:GetSpeed()
    return math.random(self:GetStoredValue("SpeedMin", "int", 0), self:GetStoredValue("SpeedMax", "int", 100))
end

function ENT:GetDamage()
    return self:GetStoredValue("Damage", "int", nil)
end

function ENT:GetSplashRadius()
    return self:GetStoredValue("SplashRadius", "int", nil)
end

function ENT:GetSpreadAngle()
    return self:GetStoredValue("SpreadAngle", "int", nil)
end

function ENT:IsCrit()
    return self:GetStoredValue("Crits", "bool", false)
end

function ENT:ApplyOverrides(ent, velocityTarget)
    ent:SetPos(self:GetPos())
    ent:SetAngles(self:GetAngles())
    ent:SetOwner(self)

    local model = self:GetModelOverride()
    if (model != nil) then ent:SetModel(model) end

    local scale = self:GetModelScale()
    if (scale != nil) then ent:SetModelScale(scale, 0.000001) end

    local spread = self:GetSpreadAngle()
    if (spread == nil) then
        velocityTarget:SetVelocity(ent:GetForward() * self:GetSpeed())
    else
        local spreadRadians = math.rad(spread)
        local offset = VectorRand() * math.tan(spreadRadians)
        local direction = (ent:GetForward() + offset):GetNormalized()

        velocityTarget:SetVelocity(direction * self:GetSpeed())
    end

    ent.Damage = self:GetDamage() || ent.Damage
    ent.SplashRadius = self:GetSplashRadius() || ent.SplashRadius
    ent.Velocity = self:GetSpeed()
end
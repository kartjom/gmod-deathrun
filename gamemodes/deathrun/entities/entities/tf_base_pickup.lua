AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.Model = nil
ENT.PickupSound = nil

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Int", 0, "NextSpawn")

    if (SERVER) then
        self:SetNextSpawn(0)
    end
end

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
        self:StoreOutput(key, value)
    else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "enable")) then self:SetEnabled(true) end
    if (string.iequals(inputName, "disable")) then self:SetEnabled(false) end 
    if (string.iequals(inputName, "toggle")) then self:SetEnabled( self:GetEnabled() ) end
end

function ENT:StartTouch(other)
    if ( !self:IsActive() ) then return end

    if (IsValid(other) && other:IsPlayer() && other:Alive()) then
        self:TriggerOutput("OnPlayerTouch", other)

        local used = self:OnPickup(other)
        if (!used) then return end

        if (self.PickupSound != nil) then
            other:PlaySound( Sound(self.PickupSound) )
        end
        
        if ( self:GetStoredValue("automaterialize", "bool", false) ) then
            self:SetNextSpawn(CurTime() + 10)
        else
            self:Remove()
        end
    end
end

function ENT:OnPickup(other) -- override, return true if used
    return true
end

function ENT:Initialize()
    if (CLIENT) then return end
    
    self:SetEnabled( !self:GetStoredValue("startdisabled", "bool", false) )

    self:SetModel(self.Model)
    self:DrawShadow(false)
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    
    self:SetTrigger(true)
end

function ENT:Draw()
    if ( !self:IsActive() ) then return end

    local angle = (CurTime() * 180) % 360
    self:SetAngles(Angle(0, angle, 0))

    self:DrawModel()
end

function ENT:IsActive()
    return self:GetEnabled() && CurTime() >= self:GetNextSpawn()
end
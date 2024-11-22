hook.Add("EntityKeyValue", "DEATHRUN.tf2_logic_auto_fix", function(ent, key, value)
    if (ent:GetClass() == "logic_auto" && (key == "OnMultiNewMap" || key == "OnMultiNewRound")) then
        ent:Fire("AddOutput", string.format("OnMapSpawn %s", value))
    end
end)

local ent = FindMetaTable("Entity")

function ent:StoreValue(key, value)
    if (self.KeyValues == nil) then
        self.KeyValues = {}
    end
    
    self.KeyValues[string.lower(key)] = value
end

function ent:GetStoredValue(key, desiredType, default)
    if (self.KeyValues == nil) then
        return nil
    end

    local val = self.KeyValues[string.lower(key)]

    if (val != nil && desiredType != nil) then
        return util.StringToType(val, desiredType)
    elseif (val == nil && default != nil) then
        return default
    else
        return val
    end
end

function ent:SetupCustomCollider()
    local mins, maxs = self:GetModelBounds()

    local x0 = mins.x
    local y0 = mins.y
    local z0 = mins.z

    local x1 = maxs.x
    local y1 = maxs.y
    local z1 = maxs.z

    self:PhysicsInitConvex({
        Vector(x0, y0, z0),
        Vector(x0, y0, z1),
        Vector(x0, y1, z0),
        Vector(x0, y1, z1),
        Vector(x1, y0, z0),
        Vector(x1, y0, z1),
        Vector(x1, y1, z0),
        Vector(x1, y1, z1),
    })

    self:EnableCustomCollisions(true)
    self:GetPhysicsObject():SetContents(CONTENTS_SOLID)
end
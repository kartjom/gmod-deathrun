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
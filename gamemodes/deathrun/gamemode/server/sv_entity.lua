local ent = FindMetaTable("Entity")

function ent:StoreValue(key, value)
    if (self.KeyValues == nil) then
        self.KeyValues = {}
    end
    
    self.KeyValues[string.lower(key)] = value
end

function ent:GetStoredValue(key, desiredType)
    if (self.KeyValues == nil) then
        return nil
    end

    if (desiredType != nil) then
        return util.StringToType(self.KeyValues[string.lower(key)], "Vector")
    else
        return self.KeyValues[string.lower(key)]
    end
end
function GM:GetMapVersion()
    if (!self.MapVer) then
        local tfSpawns = ents.FindByClass("info_player_teamspawn")
        local cssSpawns = ents.FindByClass("info_player_*terrorist")

        if (#tfSpawns > 0) then
            self.MapVer = MAPVER.TF2
        elseif (#cssSpawns > 0) then
            self.MapVer = MAPVER.CSS 
        else
            self.MapVer = MAPVER.OTHER
        end
    end

    return self.MapVer
end
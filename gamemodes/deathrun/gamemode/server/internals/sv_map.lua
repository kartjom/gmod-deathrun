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

function GM:SetupTeams()
    local mapver = self:GetMapVersion()

    if (mapver == MAPVER.CSS || mapver == MAPVER.OTHER) then
        TEAM.RUNNER = 3
        TEAM.ACTIVATOR = 2
    end

    if (mapver == MAPVER.TF2) then
        TEAM.RUNNER = 2
        TEAM.ACTIVATOR = 3
    end

    team.SetUp(TEAM.RUNNER, "Runners", Color(0, 100, 255))
    team.SetUp(TEAM.ACTIVATOR, "Activator", Color(255, 0, 0))
end
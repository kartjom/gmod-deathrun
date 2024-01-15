function GM:InitPostEntity()
    self:SetupTeams()
    self:Main()
end

function GM:Main()
	timer.RemoveAllManaged()

    RoundManager.AwaitPlayers()  
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
AddCSLuaFile()
function DEATHRUN.TeamRunner()
    return GetGlobal2Int("DEATHRUN.Team.Runner", 2)
end

function DEATHRUN.TeamActivator()
    return GetGlobal2Int("DEATHRUN.Team.Activator", 3)
end

function DEATHRUN.TeamNone()
    return 0
end

hook.Add("InitPostEntity", "DEATHRUN.InitPostEntity", function()
    if (SERVER) then
        DEATHRUN.SetupTeams()
    else
        team.SetUp(DEATHRUN.TeamRunner(), "Runners", Color(0, 100, 255))
        team.SetUp(DEATHRUN.TeamActivator(), "Activator", Color(255, 0, 0))
    end
end)
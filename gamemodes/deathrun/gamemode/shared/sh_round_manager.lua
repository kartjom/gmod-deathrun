AddCSLuaFile()
DEATHRUN.RoundManager = {}

function DEATHRUN.RoundManager.GetEndTime()
    return GetGlobal2Int("DEATHRUN.RoundEndTime")
end

function DEATHRUN.RoundManager.GetState()
    return GetGlobal2Int("DEATHRUN.RoundState")
end

function DEATHRUN.RoundManager.GetTimeLeft()
    local endTime = DEATHRUN.RoundManager.GetEndTime()
    return math.max(0, endTime - CurTime())
end

function DEATHRUN.RoundManager.GetRunners(includeDead)
    local players = {}
    for k,v in player.Iterator() do
        if ( !v:Alive() && !includeDead ) then continue end
        if ( v:Team() == DEATHRUN.TeamRunner() ) then
            table.insert(players, v)
        end
    end

    return players
end

function DEATHRUN.RoundManager.GetActivators(includeDead)
    local players = {}
    for k,v in player.Iterator() do
        if ( !v:Alive() && !includeDead ) then continue end
        if ( v:Team() == DEATHRUN.TeamActivator() ) then
            table.insert(players, v)
        end
    end

    return players
end

function DEATHRUN.RoundManager.GetSpectators()
    local players = {}
    for k,v in player.Iterator() do
        if (v:IsSpectator()) then
            table.insert(players, v)
        end
    end

    return players   
end
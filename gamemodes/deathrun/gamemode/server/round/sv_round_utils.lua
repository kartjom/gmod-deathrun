concommand.Add("dr_set_time", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end
    if ( args[1] == nil ) then return end

    local newTime = tonumber(args[1])
    if (newTime == nil) then return end

    RoundManager.SetCurrentTime(newTime)
end)

concommand.Add("dr_round_restart", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    RoundManager.RoundRestart()
end)

function RoundManager.GetTeamPlayers(includeDead)
    local teams = {}

    for k,v in pairs(player.GetAll()) do
        if ( (v:IsSpectator() || !v:Alive()) && !includeDead ) then continue end

        if( teams[v:Team()] == nil ) then
            teams[v:Team()] = {}
        end

        table.insert(teams[v:Team()], v)
    end

    local result = {
        [TEAM.RUNNER] = teams[TEAM.RUNNER] || {},
        [TEAM.ACTIVATOR] = teams[TEAM.ACTIVATOR] || {},
        [TEAM.SPECTATOR] = teams[TEAM.SPECTATOR] || {}
    }

    return result
end

function RoundManager.GetPlayers(includeDead)
    local result = {}

    for k,v in pairs(player.GetAll()) do
        if ( v:IsSpectator() && !includeDead ) then continue end

        table.insert(result, v)
    end

    return result
end

function RoundManager.GetRunners()
    local result = RoundManager.GetTeamPlayers(false)
    return result[TEAM.RUNNER]
end

function RoundManager.GetActivators()
    local result = RoundManager.GetTeamPlayers(false)
    return result[TEAM.ACTIVATOR]
end

function RoundManager.GetSpectators()
    local result = {}

    for k,v in pairs(player.GetAll()) do
        if (v:IsSpectator() || !v:Alive()) then
            table.insert(result, v)
        end
    end

    return result   
end

function RoundManager.CheckForRoundEnd()
    if (RoundManager.GameState != STATE.ACTION) then return end

    local AliveTeamPlayers = RoundManager.GetTeamPlayers(false)
    local AlivePlayersCount = #RoundManager.GetPlayers(false)

    if (player.GetCount() < 2) then
        RoundManager.RoundEnd(TEAM.NONE, "Not enough players!")
        return
    end

    local RUNNERS = #AliveTeamPlayers[TEAM.RUNNER]
    local ACTIVATORS = #AliveTeamPlayers[TEAM.ACTIVATOR]

    --WIN RUNNERS
    if (RUNNERS > 0 && ACTIVATORS == 0) then
        RoundManager.RoundEnd(TEAM.RUNNER, "Runners win!")
        return
    end

    --WIN ACTIVATORS
    if (ACTIVATORS > 0 && RUNNERS == 0) then
        RoundManager.RoundEnd(TEAM.ACTIVATOR, "Activators win!")
        return
    end

    if (AlivePlayersCount == 0) then
        RoundManager.RoundEnd(TEAM.ACTIVATOR, "Activators win!")
        return
    end
end

function RoundManager.RandomizeTeams()
    local Players = player.GetAll()
    table.Shuffle(Players)

    -- pick random player that hasn't been activator yet
    local activator = nil
    for k,v in ipairs(Players) do
        if (!v.WasActivator) then
            activator = v
            break
        end
    end

    -- reset queue if everyone was activator
    if (activator == nil) then
        for k,v in ipairs(Players) do
            v.WasActivator = false
        end

        activator = Players[1]
    end

    -- Activator
    activator:SetActivator()
    activator.WasActivator = true

    table.RemoveByValue(Players, activator)

    -- Runners
    for k,v in ipairs(Players) do
        v:SetRunner()
    end
end
concommand.Add("dr_set_time", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end
    if ( args[1] == nil ) then return end

    local newTime = tonumber(args[1])
    if (newTime == nil) then return end

    DEATHRUN.RoundManager.SetTime(newTime)
end)

concommand.Add("dr_round_restart", function(ply, cmd, args)
    if ( !ply:IsAdmin() ) then return end

    DEATHRUN.RoundManager.RestartRound()
end)

function DEATHRUN.RoundManager.CheckForRoundEnd()
    if (DEATHRUN.RoundManager.GetState() != DEATHRUN.STATE.ACTION) then return end

    if (player.GetCount() < 2) then
        return DEATHRUN.RoundManager.EndRound(DEATHRUN.TeamNone(), "Not enough players!")
    end

    local RUNNERS = #DEATHRUN.RoundManager.GetRunners()
    local ACTIVATORS = #DEATHRUN.RoundManager.GetActivators()

    --WIN RUNNERS
    if (RUNNERS > 0 && ACTIVATORS == 0) then
        return DEATHRUN.RoundManager.EndRound(DEATHRUN.TeamRunner(), "Runners win!")
    end

    --WIN ACTIVATORS
    if (ACTIVATORS > 0 && RUNNERS == 0) then
        return DEATHRUN.RoundManager.EndRound(DEATHRUN.TeamActivator(), "Activators win!")
    end

    if (AlivePlayersCount == 0) then
        return DEATHRUN.RoundManager.EndRound(DEATHRUN.TeamActivator(), "Activators win!")
    end
end

function DEATHRUN.RoundManager.RandomizeTeams()
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

function DEATHRUN.RoundManager.BroadcastRoundEnd(winnerTeam)
    net.Start("DEATHRUN.RoundEnd")
        net.WriteUInt(winnerTeam, 3)
    net.Broadcast()
end
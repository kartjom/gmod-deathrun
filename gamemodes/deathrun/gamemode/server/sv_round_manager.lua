util.AddNetworkString("RoundTimeUpdate")
util.AddNetworkString("GameStateUpdate")

CreateConVar("dr_round_time", 900, FCVAR_ARCHIVE, "Round time in seconds", 300, 3600)

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

RoundManager = {}
RoundManager.CurrentTime = 0
RoundManager.GameState = STATE.AWAIT

function RoundManager.BroadcastRoundTime()
    net.Start("RoundTimeUpdate")
        net.WriteInt(RoundManager.CurrentTime, 32)
    net.Broadcast()
end

function RoundManager.BroadcastGameState()
    net.Start("GameStateUpdate")
        net.WriteInt(RoundManager.GameState, 8)
    net.Broadcast()
end

function RoundManager.SetCurrentTime(time)
    RoundManager.CurrentTime = time
    RoundManager.BroadcastRoundTime()
end

function RoundManager.SetGameState(state)
    RoundManager.GameState = state
    RoundManager.BroadcastGameState()
end

function RoundManager.AwaitPlayers()
    RoundManager.SetGameState(STATE.AWAIT)

    timer.CreateManaged("AwaitPlayers", 5, 0, function()
        if (player.GetCount() >= 2) then
            timer.RemoveManaged("AwaitPlayers");

            PrintMessage(HUD_PRINTTALK, "Starting game in 5 seconds...")
            timer.CreateManaged("GameStart", 5, 1, function()
                RoundManager.RoundRestart()
            end)
        end
    end)
end

function RoundManager.PrepareStart()
    timer.RemoveAllManaged()

    RoundManager.SetCurrentTime(5)
    RoundManager.SetGameState(STATE.PREPARE)
    RoundManager.RandomizeTeams()

    for k,v in pairs(RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_NONE)
    end

    timer.CreateManaged("PrepareCountdown", 1, 0, function()
        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)
        if(RoundManager.CurrentTime <= 0) then
            PrintMessage(HUD_PRINTCENTER, "GAME STARTED")
            RoundManager.RoundStart()
        end
    end)
end

function RoundManager.RoundStart()
    timer.RemoveManaged("PrepareCountdown")

    RoundManager.SetCurrentTime( GetConVar("dr_round_time"):GetInt() )
    RoundManager.SetGameState(STATE.ACTION)

    for k,v in pairs(RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_WALK)
    end

    timer.CreateManaged("RoundCountdown", 1, 0, function ()
        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)

        if(RoundManager.CurrentTime <= 0) then
            RoundManager.RoundEnd("Time Limit Reached")
            return
        end

        RoundManager.CheckForRoundEnd()
    end)
end

function RoundManager.RoundEnd(result)
    timer.RemoveManaged("RoundCountdown")

    RoundManager.SetCurrentTime(15)
    RoundManager.SetGameState(STATE.END)

    PrintMessage(HUD_PRINTCENTER, result)

    timer.CreateManaged("RestartCountdown", 1, 0, function ()
        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)
        if(RoundManager.CurrentTime <= 0) then
            RoundManager.RoundRestart()
        end
    end)
end

function RoundManager.RoundRestart()
    timer.RemoveManaged("PrepareCountdown")
    timer.RemoveManaged("RoundCountdown")
    timer.RemoveManaged("RestartCountdown")

    PrintMessage(HUD_PRINTCENTER, "Restarting")
    game.CleanUpMap()

    if (player.GetCount() < 2) then
        RoundManager.AwaitPlayers()
        
        for k,v in pairs(player.GetAll()) do
	        v:ResetData()
            v:SetRunner()
        end
        
        return
    end

    for k,v in pairs(player.GetAll()) do
        v:Spawn()
    end
    
    RoundManager.PrepareStart()
end

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
        RoundManager.RoundEnd("Not enough players!")
        return
    end

    local RUNNERS = #AliveTeamPlayers[TEAM.RUNNER]
    local ACTIVATORS = #AliveTeamPlayers[TEAM.ACTIVATOR]

    --WIN RUNNERS
    if (RUNNERS > 0 && ACTIVATORS == 0) then
        RoundManager.RoundEnd("Runners win!")
        return
    end

    --WIN ACTIVATORS
    if (ACTIVATORS > 0 && RUNNERS == 0) then
        RoundManager.RoundEnd("Activators win!")
        return
    end

    if (AlivePlayersCount == 0) then
        RoundManager.RoundEnd("Tie")
        return
    end
end

function RoundManager.RandomizeTeams()
    math.randomseed(os.time() * math.random(1, 9))
    local Players = player.GetAll()

    -- Activator
    local randomPlayerIndex = math.random(1, #Players)
    local randomPlayer = Players[randomPlayerIndex]

    randomPlayer:SetActivator()
    table.remove(Players, randomPlayerIndex)

    -- Runners
    for k,v in ipairs(Players) do
        v:SetRunner()
    end
end
util.AddNetworkString("RoundTimeUpdate")
util.AddNetworkString("GameStateUpdate")

local cvar_round_time = CreateConVar("dr_round_time", 900, FCVAR_ARCHIVE, "Round time in seconds", 300, 3600)
local cvar_restart_time = CreateConVar("dr_restart_time", 10, FCVAR_ARCHIVE, "Time in seconds for match to restart", 5, 15)

local prepareCountdownAllowedNumbers = {
    [10] = true,
    [5] = true,
    [4] = true,
    [3] = true,
    [2] = true,
    [1] = true,
}

local endCountdownAllowedNumbers = {
    [60] = true,
    [30] = true,
    [20] = true,
    [10] = true,
    --[9] = true,
    --[8] = true,
    [7] = true,
    [6] = true,
    [5] = true,
    [4] = true,
    [3] = true,
    [2] = true,
    [1] = true,
}

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
RoundManager.FirstBlood = false
RoundManager.LastManAlive = false

function RoundManager.BroadcastRoundTime()
    net.Start("RoundTimeUpdate")
        net.WriteUInt(RoundManager.CurrentTime, 16)
    net.Broadcast()
end

function RoundManager.BroadcastGameState()
    net.Start("GameStateUpdate")
        net.WriteInt(RoundManager.GameState, 4)
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

    timer.CreateManaged("AwaitPlayers", 1, 0, function()
        if (player.GetCount() >= 2) then
            timer.RemoveAllManaged()

            PrintMessage(HUD_PRINTTALK, "Starting game in 5 seconds...")
            timer.CreateManaged("GameStart", 5, 1, function()
                RoundManager.RoundRestart()
            end)
        end
    end)
end

function RoundManager.PrepareStart()
    timer.RemoveAllManaged()

    RoundManager.SetCurrentTime(11)
    RoundManager.SetGameState(STATE.PREPARE)
    RoundManager.RandomizeTeams()

    for k,v in pairs(RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_NONE)
    end

    team_round_timer_OnSetupStart()

    timer.CreateManaged("PrepareCountdown", 1, 0, function()       
        if (prepareCountdownAllowedNumbers[RoundManager.CurrentTime - 1]) then
            PlaySound(string.format("vo/announcer_begins_%dsec.mp3", RoundManager.CurrentTime - 1))
        end

        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)

        if(RoundManager.CurrentTime < 0) then
            PrintMessage(HUD_PRINTCENTER, "GAME STARTED")
            RoundManager.RoundStart()

            local startSnd = math.random(1, 4)
            if (startSnd == 2) then startSnd = 1 end
            PlaySound(string.format("vo/announcer_am_roundstart0%d.mp3", startSnd))
        end
    end)
end

function RoundManager.RoundStart()
    timer.RemoveAllManaged()

    RoundManager.SetCurrentTime(cvar_round_time:GetInt())
    RoundManager.SetGameState(STATE.ACTION)

    for k,v in pairs(RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_WALK)
    end

    team_round_timer_OnSetupFinished()
    tf_logic_arena_OnArenaRoundStart()

    timer.CreateManaged("RoundCountdown", 1, 0, function ()
        if (endCountdownAllowedNumbers[RoundManager.CurrentTime - 1]) then
            PlaySound(string.format("vo/announcer_ends_%dsec.mp3", RoundManager.CurrentTime - 1))
        end

        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)

        if(RoundManager.CurrentTime < 0) then
            RoundManager.RoundEnd(TEAM.ACTIVATOR, "Time Limit Reached")
            return
        end

        RoundManager.CheckForRoundEnd()
    end)
end

function RoundManager.RoundEnd(winnerTeam, result)
    timer.RemoveAllManaged()

    net.Start("RoundEnd")
        net.WriteUInt(winnerTeam, 3)
    net.Broadcast()

    tf_gamerules_handleRoundEnd(winnerTeam)

    RoundManager.SetCurrentTime(cvar_restart_time:GetInt())
    RoundManager.SetGameState(STATE.END)

    for k,v in pairs(player.GetAll()) do
        if (v:Alive() && v:Team() != winnerTeam) then
            v:StripWeapons()
        end
    end

    PrintMessage(HUD_PRINTCENTER, result)

    timer.CreateManaged("RestartCountdown", 1, 0, function ()
        RoundManager.SetCurrentTime(RoundManager.CurrentTime - 1)
        if(RoundManager.CurrentTime < 0) then
            RoundManager.RoundRestart()
        end
    end)
end

function RoundManager.RoundRestart()
    timer.RemoveAllManaged()

    PrintMessage(HUD_PRINTCENTER, "Restarting")

    math.randomseed(os.time() + os.clock() + tonumber(tostring({}):sub(8)) + math.floor(math.random() * 1000000))
    game.CleanUpMap()

    RoundManager.FirstBlood = false
    RoundManager.LastManAlive = false

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
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
            PlaySound("ambient/siren.wav")
        end
    end)
end

function RoundManager.RoundStart()
    timer.RemoveAllManaged()

    RoundManager.SetCurrentTime(RoundManager.CvarRoundTime:GetInt())
    RoundManager.SetGameState(STATE.ACTION)

    for k,v in pairs(RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_WALK)
    end

    team_round_timer_OnSetupFinished()
    tf_logic_arena_OnArenaRoundStart()

    timer.CreateManaged("RoundCountdown", 1, 0, function()
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
    if (RoundManager.GameState == STATE.END) then return end

    timer.RemoveAllManaged()

    RoundManager.BroadcastRoundEnd(winnerTeam)
    tf_gamerules_handleRoundEnd(winnerTeam)

    RoundManager.SetCurrentTime(RoundManager.CvarRestartTime:GetInt())
    RoundManager.SetGameState(STATE.END)

    for k,v in pairs(player.GetAll()) do
        if (v:Alive() && v:Team() != winnerTeam) then
            v:StripWeapons()
        end
    end

    PrintMessage(HUD_PRINTCENTER, result)

    timer.CreateManaged("RestartCountdown", 1, 0, function()
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

    for k,v in pairs(ents.FindByClass("func_door")) do
        if (v:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR) then
            v:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end

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
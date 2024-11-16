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

function DEATHRUN.RoundManager.ActionOnEnter()
    DEATHRUN.RoundManager.SetTime(DEATHRUN.CVAR.ActionTime:GetInt())

    for k,v in pairs(DEATHRUN.RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_WALK)
    end

    team_round_timer_OnSetupFinished()
    tf_logic_arena_OnArenaRoundStart()
end

function DEATHRUN.RoundManager.ActionTimeEvent(time)
    if (endCountdownAllowedNumbers[time - 1]) then
        PlaySound(string.format("vo/announcer_ends_%dsec.mp3", time - 1))
    end

    DEATHRUN.RoundManager.CheckForRoundEnd()
end

function DEATHRUN.RoundManager.ActionOnTimeOut()
    DEATHRUN.RoundManager.EndRound(DEATHRUN.TeamActivator(), "Time Limit Reached")
end
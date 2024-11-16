local prepareCountdownAllowedNumbers = {
    [10] = true,
    [5] = true,
    [4] = true,
    [3] = true,
    [2] = true,
    [1] = true,
}

local roundStartNumbers = { 1, 3, 4 }

function DEATHRUN.RoundManager.PrepareOnEnter()
    DEATHRUN.RoundManager.SetTime(DEATHRUN.CVAR.PrepareTime:GetInt())
    
    DEATHRUN.RoundManager.RandomizeTeams()

    for k,v in pairs(DEATHRUN.RoundManager.GetRunners()) do
        v:SetMoveType(MOVETYPE_NONE)
    end

    team_round_timer_OnSetupStart()
end

function DEATHRUN.RoundManager.PrepareTimeEvent(time)
    if (prepareCountdownAllowedNumbers[time - 1]) then
        PlaySound(string.format("vo/announcer_begins_%dsec.mp3", time - 1))
    end
end

function DEATHRUN.RoundManager.PrepareOnTimeOut()
    PlaySound(string.format("vo/announcer_am_roundstart0%d.mp3", roundStartNumbers[math.random(#roundStartNumbers)]))
    PlaySound("ambient/siren.wav")

    DEATHRUN.RoundManager.SetState(DEATHRUN.STATE.ACTION)
end
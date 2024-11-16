function DEATHRUN.RoundManager.EndOnEnter()
    DEATHRUN.RoundManager.SetTime(DEATHRUN.CVAR.EndTime:GetInt())
end

function DEATHRUN.RoundManager.EndTimeEvent(time)

end

function DEATHRUN.RoundManager.EndOnTimeOut()
    DEATHRUN.RoundManager.RestartRound()
end
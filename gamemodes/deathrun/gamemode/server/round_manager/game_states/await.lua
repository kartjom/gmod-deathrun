function DEATHRUN.RoundManager.AwaitOnEnter()

end

function DEATHRUN.RoundManager.AwaitTimeEvent(time)

end

function DEATHRUN.RoundManager.AwaitOnTimeOut()
    if (player.GetCount() >= 2) then
        DEATHRUN.RoundManager.RestartRound()
    end
end
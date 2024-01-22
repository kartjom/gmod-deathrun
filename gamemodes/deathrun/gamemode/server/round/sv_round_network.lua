util.AddNetworkString("RoundTimeUpdate")
util.AddNetworkString("GameStateUpdate")
util.AddNetworkString("RoundEnd")

function RoundManager.BroadcastRoundTime()
    net.Start("RoundTimeUpdate")
        net.WriteUInt(RoundManager.CurrentTime, 16)
    net.Broadcast()
end

function RoundManager.BroadcastGameState()
    net.Start("GameStateUpdate")
        net.WriteUInt(RoundManager.GameState, 4)
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

function RoundManager.BroadcastRoundEnd(winnerTeam)
    net.Start("RoundEnd")
        net.WriteUInt(winnerTeam, 3)
    net.Broadcast()
end
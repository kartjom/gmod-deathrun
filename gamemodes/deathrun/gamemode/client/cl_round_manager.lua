CurrentTime = 0;
GameState = STATE.AWAIT;

net.Receive('RoundTimeUpdate', function()
    CurrentTime = net.ReadInt(16)
end)

net.Receive('GameStateUpdate', function()
    GameState = net.ReadInt(4)
end)
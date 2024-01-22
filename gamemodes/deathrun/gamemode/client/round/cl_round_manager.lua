RoundManager = {}

RoundManager.CurrentTime = 0;
RoundManager.GameState = STATE.AWAIT;

net.Receive("RoundTimeUpdate", function()
    RoundManager.CurrentTime = net.ReadUInt(16)
end)

net.Receive("GameStateUpdate", function()
    RoundManager.GameState = net.ReadUInt(4)
end)

net.Receive("RoundEnd", function()
    local winnerTeam = net.ReadUInt(3)
    local plyTeam = LocalPlayer():Team()

    if (winnerTeam == TEAM.NONE) then
        surface.PlaySound("vo/announcer_stalemate.mp3")
        return
    end

    if (plyTeam == winnerTeam || (plyTeam == TEAM.SPECTATOR && winnerTeam == TEAM.RUNNER)) then
        surface.PlaySound("ui/mm_match_end_win_music_casual.wav")
    else
        surface.PlaySound("ui/mm_match_end_lose_music_casual.wav")
    end
end)
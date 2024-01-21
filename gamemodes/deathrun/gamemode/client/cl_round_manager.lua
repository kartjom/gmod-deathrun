CurrentTime = 0;
GameState = STATE.AWAIT;

net.Receive("RoundTimeUpdate", function()
    CurrentTime = net.ReadUInt(16)
end)

net.Receive("GameStateUpdate", function()
    GameState = net.ReadUInt(4)
end)

net.Receive("RoundEnd", function()
    local winnerTeam = net.ReadUInt(3)

    if (winnerTeam == TEAM.NONE) then
        surface.PlaySound("vo/announcer_stalemate.mp3")
        return
    end

    if (LocalPlayer():Team() == winnerTeam) then
        surface.PlaySound("ui/mm_match_end_win_music_casual.wav")
    else
        surface.PlaySound("ui/mm_match_end_lose_music_casual.wav")
    end
end)
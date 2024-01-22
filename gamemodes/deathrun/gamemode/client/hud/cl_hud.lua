hook.Add("HUDPaint", "HUD_DrawRoundTime", function()
    local text = ""
    local align = TEXT_ALIGN_CENTER

    local x = 50
    local y = ScrH() - 200

    if(RoundManager.GameState == STATE.AWAIT) then
        text = "Waiting for players..."
        align = TEXT_ALIGN_LEFT
    end

    if(RoundManager.CurrentTime >= 0 && RoundManager.GameState == STATE.PREPARE) then
        text = "Starting in " .. string.FormattedTime(RoundManager.CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    if(RoundManager.CurrentTime >= 0 && RoundManager.GameState == STATE.ACTION) then
        text = string.FormattedTime(RoundManager.CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end
    
    if(RoundManager.CurrentTime >= 0 && RoundManager.GameState == STATE.END) then
        text = "Restarting in " .. string.FormattedTime(RoundManager.CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    draw.DrawText(text, "Trebuchet24", x, y, Color(255, 255, 255, 255), align);
end)

hook.Add("HUDPaint", "HUD_SpectatorHints", function()
    if (LocalPlayer():Team() == TEAM.SPECTATOR) then
        draw.DrawText("- Press [Left Mouse] to follow next player", "Trebuchet24", (ScrW()/2) - 200, ScrH() - 80, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
        draw.DrawText("- Press [Right Mouse] to follow previous player", "Trebuchet24", (ScrW()/2) - 200, ScrH() - 60, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
        draw.DrawText("- Press [R] to change camera mode", "Trebuchet24", (ScrW()/2) - 200, ScrH() - 40, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
    end
end)
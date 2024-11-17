AddCSLuaFile()

hook.Add("HUDPaint", "DEATHRUN.DrawRoundTime", function()
    local text = ""
    local align = TEXT_ALIGN_CENTER

    local x = 50
    local y = ScrH() - 200

    local roundState = DEATHRUN.RoundManager.GetState()
    local timeLeft = DEATHRUN.RoundManager.GetTimeLeft()

    if (roundState == DEATHRUN.STATE.AWAIT) then
        text = "Waiting for players..."
        align = TEXT_ALIGN_LEFT
    end

    if (timeLeft >= 0 && roundState == DEATHRUN.STATE.PREPARE) then
        text = "Starting in " .. string.FormattedTime(timeLeft, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    if (timeLeft >= 0 && roundState == DEATHRUN.STATE.ACTION) then
        text = string.FormattedTime(timeLeft, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end
    
    if (timeLeft >= 0 && roundState == DEATHRUN.STATE.END) then
        text = "Restarting in " .. string.FormattedTime(timeLeft, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    draw.DrawText(text, "Trebuchet24", x, y, Color(255, 255, 255, 255), align);
end)

hook.Add("HUDPaint", "DEATHRUN.SpectatorHints", function()
    if (LocalPlayer():IsSpectator()) then
        local mode = LocalPlayer():GetObserverMode()

        if (mode == OBS_MODE_IN_EYE || mode == OBS_MODE_CHASE) then
            draw.DrawText("- Press [Left/Right Mouse] to change player", "Trebuchet24", (ScrW()/2) - 200, ScrH() - 60, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
        end

        draw.DrawText("- Press [R] to change camera mode", "Trebuchet24", (ScrW()/2) - 200, ScrH() - 40, Color(255, 255, 255, 128), TEXT_ALIGN_LEFT)
    end
end)
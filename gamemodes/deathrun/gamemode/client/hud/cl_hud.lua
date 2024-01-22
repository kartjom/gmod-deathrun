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
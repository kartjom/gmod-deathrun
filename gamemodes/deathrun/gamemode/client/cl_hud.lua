hook.Add("HUDPaint", "HUD_DrawRoundTime", function()
    local text = ""
    local align = TEXT_ALIGN_CENTER

    local x = 50
    local y = ScrH() - 150

    if(GameState == STATE.AWAIT) then
        text = "Waiting for players..."
        align = TEXT_ALIGN_LEFT
    end

    if(CurrentTime >= 0 && GameState == STATE.PREPARE) then
        text = "Starting in " .. string.FormattedTime(CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    if(CurrentTime >= 0 && GameState == STATE.ACTION) then
        text = string.FormattedTime(CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end
    
    if(CurrentTime >= 0 && GameState == STATE.END) then
        text = "Restarting in " .. string.FormattedTime(CurrentTime, "%02i:%02i")
        align = TEXT_ALIGN_LEFT
    end

    draw.DrawText(text, "Trebuchet24", x, y, Color(255, 255, 255, 255), align);
end)
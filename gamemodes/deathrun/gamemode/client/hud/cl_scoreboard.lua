hook.Add("Think", "ScoreboardControls", function()
    if (IsValid(Scoreboard) && IsValid(Scrollbar) && input.IsMouseDown(MOUSE_RIGHT)) then
        gui.EnableScreenClicker(true)
    end
end)

function GM:ScoreboardShow()
    -- Main panel
	Scoreboard = vgui.Create("DFrame")
    Scoreboard:SetTitle("")
    Scoreboard:SetSize(ScrW() / 4, ScrH() / 2)
    Scoreboard:Center()
    Scoreboard:ShowCloseButton(false)
    Scoreboard:SetDraggable(false)

    Scoreboard.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 240))    
    end

    -- Scroll bar
    local DScrollPanel = vgui.Create("DScrollPanel", Scoreboard)
    DScrollPanel:Dock(FILL)
    DScrollPanel:DockMargin(0, -15, 0, 8)
    Scrollbar = DScrollPanel:GetVBar()
    Scrollbar:SetHideButtons(true)

    Scrollbar.Paint = function(self, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    Scrollbar.btnGrip.Paint = function(self, w, h)
        if (self:IsHovered()) then
            draw.RoundedBox(16, 0, 0, w, h - 4, Color(80, 80, 80, 180))
        else
            draw.RoundedBox(16, 0, 0, w, h - 4, Color(80, 80, 80, 120))
        end
    end

    -- Players
    local players = player.GetAll()
    table.sort(players, function(a, b)
        local teamPriority = {
            [TEAM.ACTIVATOR] = 1,
            [TEAM.RUNNER] = 2,
            [TEAM.SPECTATOR] = 3,
        }

        return (teamPriority[a:Team()] || 69) < (teamPriority[b:Team()] || 69)
    end)

    for k,v in ipairs(players) do
        local item = DScrollPanel:Add("DFrame")
        item:SetTitle("")
        item:SetSize(Scoreboard:GetWide(), 40)
        item:ShowCloseButton(false)
        item:SetDraggable(false)
        item:Dock(TOP)
        item:DockMargin(5, 0, 5, 7)

        local teamColor = team.GetColor(v:Team())
        teamColor.a = v:Alive() and 100 or 20

        item.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, teamColor)

            draw.DrawText(v:GetName(), "Trebuchet24", 46, 8, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
            draw.DrawText(v:Ping(), "Trebuchet24", w - 46, 8, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
        end

        local Avatar = vgui.Create("AvatarImage", item)
        Avatar:SetSize(32, 32)
        Avatar:SetPos(4, (item:GetTall() - Avatar:GetTall()) / 2)
        Avatar:SetPlayer(v, Avatar:GetTall())
    end
end

function GM:ScoreboardHide()
    gui.EnableScreenClicker(false)
	Scoreboard:Remove()
end
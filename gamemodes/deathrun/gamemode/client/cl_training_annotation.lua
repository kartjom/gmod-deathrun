AddCSLuaFile()

local annotations = {}

net.Receive("DEATHRUN.ShowAnnotation", function()
    local new = {
        id = net.ReadUInt(13),
        text = net.ReadString(),
        position = net.ReadVector(),
        end_t = net.ReadInt(32),
    }

    annotations[new.id] = new
end)

net.Receive("DEATHRUN.HideAnnotation", function()
    local id = net.ReadUInt(13)
    annotations[new.id] = nil
end)

net.Receive("DEATHRUN.ClearAnnotations", function()
    annotations = {}
end)

local function DrawTrainingAnnotation(text, x, y, min_width)
    local color_blue = Color(88, 133, 162, 255)
    local color_border = Color(247, 231, 198, 255)
    local color_triangle = Color(55, 51, 49, 255)
    local color_text = Color(255, 255, 255, 255)

    surface.SetFont("tf2_font")
    local w, h = surface.GetTextSize(text)

    width = math.max(w + 60, min_width or 0)
    height = 90

    -- vertical offset, triangle will be pointing correctly
    y = y - height

    local centerX = x
    local centerY = y

    x = x - width / 2
    y = y - height / 2

    -- Border
    draw.RoundedBox(16, x, y, width, height, color_border)
    
    -- Background
    draw.RoundedBox(14, x+4, y+4, width-8, height-8, color_blue)

    -- Text
    draw.DrawText(text, "tf2_font", centerX, centerY - 20, color_text, TEXT_ALIGN_CENTER)

    -- Triangle
    local tw = 74
    local th = 30
    local th_off = 4
    local triangle = {
        { x = centerX - tw/2, y = th_off + y + height },
        { x = centerX + tw/2, y = th_off + y + height },
        { x = centerX, y = th_off + y + height + th }
    }

    surface.SetDrawColor(color_border)
	draw.NoTexture()
    surface.DrawPoly(triangle)

    -- Triangle background
    local smaller = 3
    triangle = {
        { x = centerX - tw/2 + smaller*3, y = th_off + y + height + smaller },
        { x = centerX + tw/2 - smaller*3, y = th_off + y + height + smaller },
        { x = centerX, y = th_off + y + height + th - smaller*1.25 }
    }

    surface.SetDrawColor(color_triangle)
	surface.DrawPoly(triangle)
end

hook.Add("HUDPaint", "DEATHRUN.TrainingAnnotation", function()
    for id,v in pairs(annotations) do
        local screen = v.position:ToScreen()
        DrawTrainingAnnotation(v.text, screen.x, screen.y)

        if (v.end_t != -1 && CurTime() >= v.end_t) then
            annotations[id] = nil
        end
    end
end)
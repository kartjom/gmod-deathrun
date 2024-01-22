include("shared.lua")

/* Include Client Files (see init.lua) */
include("client/round/cl_round_manager.lua")
include("client/hud/cl_hud.lua")

net.Receive("SyncTeamCreation", function()
    TEAM.RUNNER = net.ReadUInt(4)
    TEAM.ACTIVATOR = net.ReadUInt(4)

    team.SetUp(TEAM.RUNNER, "Runners", Color(0, 100, 255))
    team.SetUp(TEAM.ACTIVATOR, "Activator", Color(255, 0, 0))
end)

net.Receive("PlaySound", function()
    local snd = net.ReadString()
    surface.PlaySound(snd)
end)
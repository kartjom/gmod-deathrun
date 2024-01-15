include("shared.lua")

/* Include Client Files (see init.lua) */
include("client/cl_round_manager.lua")
include("client/cl_hud.lua")

net.Receive("SyncTeamCreation", function()
    TEAM.RUNNER = net.ReadInt(16)
    TEAM.ACTIVATOR = net.ReadInt(16)

    team.SetUp(TEAM.RUNNER, "Runners", Color(0, 100, 255))
    team.SetUp(TEAM.ACTIVATOR, "Activator", Color(255, 0, 0))
end)
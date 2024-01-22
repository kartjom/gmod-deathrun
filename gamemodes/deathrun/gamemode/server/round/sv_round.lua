RoundManager = {}

RoundManager.CurrentTime = 0
RoundManager.GameState = STATE.AWAIT

RoundManager.FirstBlood = false
RoundManager.LastManAlive = false

RoundManager.CvarRoundTime = CreateConVar("dr_round_time", 900, FCVAR_ARCHIVE, "Round time in seconds", 300, 3600)
RoundManager.CvarRestartTime = CreateConVar("dr_restart_time", 10, FCVAR_ARCHIVE, "Time in seconds for match to restart", 5, 15)

include("sv_round_network.lua")
include("sv_round_utils.lua")
include("sv_round_manager.lua")
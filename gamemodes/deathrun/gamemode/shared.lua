AddCSLuaFile()

DeriveGamemode("base")

DEATHRUN = {
    STATE = {
        AWAIT = 0,
        PREPARE = 1,
        ACTION = 2,
        END = 3,
    },
    GAME = {
        OTHER = 0,
        TF2 = 1,
        CSS = 2,
    },
    TFCLASS = {
        SCOUT = 1,
        SNIPER = 2,
        SOLDIER = 3,
        DEMOMAN = 4,
        MEDIC = 5,
        HEAVY = 6,
        PYRO = 7,
        SPY = 8,
        ENGINEER = 9,
    },
}

include("shared/sh_tf2_particles.lua")

include("shared/player_class/deathrun_base.lua")
include("shared/player_class/deathrun_runner.lua")
include("shared/player_class/deathrun_activator.lua")
include("shared/sh_teams.lua")
include("shared/sh_utils.lua")
include("shared/sh_player.lua")
include("shared/sh_round_manager.lua")
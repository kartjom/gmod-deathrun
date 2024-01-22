DeriveGamemode("base")

STATE = {
	AWAIT = 0,
	PREPARE = 1,
	ACTION = 2,
	END = 3,
}

TEAM = {
    NONE = 1,
    UNASSIGNED = 1001,
    SPECTATOR = 1002,
}

MAPVER = {
    OTHER = 0,
    TF2 = 1,
    CSS = 2,
}

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
}

team.SetUp(TEAM.SPECTATOR, "Spectator", Color(128, 128, 128))
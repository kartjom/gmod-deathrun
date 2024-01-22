DeriveGamemode("base")

STATE = {
	AWAIT = 0,
	PREPARE = 1,
	ACTION = 2,
	END = 3
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
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.AutomaticFrameAdvance = true

function ENT:Draw()
    self:DrawModel()
end

if (CLIENT) then
    language.Add("obj_sentrygun", "Sentry")
end

if (CLIENT) then return end

local SENTRY_MODEL_PLACEMENT = "models/buildables/sentry1_blueprint.mdl"
local SENTRY_MODEL_LEVEL_1 = "models/buildables/sentry1.mdl"
local SENTRY_MODEL_LEVEL_1_UPGRADE = "models/buildables/sentry1_heavy.mdl"
local SENTRY_MODEL_LEVEL_2 = "models/buildables/sentry2.mdl"
local SENTRY_MODEL_LEVEL_2_UPGRADE = "models/buildables/sentry2_heavy.mdl"
local SENTRY_MODEL_LEVEL_3 = "models/buildables/sentry3.mdl"
local SENTRY_MODEL_LEVEL_3_UPGRADE = "models/buildables/sentry3_heavy.mdl"

local SENTRY_ROCKET_MODEL = "models/buildables/sentry3_rockets.mdl"

local TF_TEAM_RED = 2
local TF_TEAM_BLUE = 3

local SENTRYGUN_MINS = Vector(-20, -20, 0)
local SENTRYGUN_MAXS = Vector(20, 20, 66)

local SENTRYGUN_MAX_HEALTH = 150
local SENTRYGUN_MINI_MAX_HEALTH	= 100
local UPGRADE_LEVEL_HEALTH_MULTIPLIER = 1.2

local SENTRYGUN_EYE_OFFSET_LEVEL_1 = Vector(0, 0, 32)
local SENTRYGUN_EYE_OFFSET_LEVEL_2 = Vector(0, 0, 40)
local SENTRYGUN_EYE_OFFSET_LEVEL_3 = Vector(0, 0, 46)

local VIEW_FIELD_FULL = -1.0 			// +-180 degrees
local VIEW_FIELD_WIDE = -0.7 			// +-135 degrees 0.1 // +-85 degrees, used for full FOV checks 
local VIEW_FIELD_NARROW = 0.7 			// +-45 degrees, more narrow check used to set up ranged attacks
local VIEW_FIELD_ULTRA_NARROW = 0.9 	// +-25 degrees, more narrow check used to set up ranged attacks

local SENTRYGUN_MAX_SHELLS_1 = 150
local SENTRYGUN_MAX_SHELLS_2 = 200
local SENTRYGUN_MAX_SHELLS_3 = 200
local SENTRYGUN_MAX_ROCKETS = 20

local SENTRYGUN_MINIGUN_RESIST_LVL_1 = 0.0
local SENTRYGUN_MINIGUN_RESIST_LVL_2 = 0.15
local SENTRYGUN_MINIGUN_RESIST_LVL_3 = 0.20

local SENTRY_THINK_DELAY = 0.05
local SENTRY_MAX_RANGE = 1100

local SENTRY_STATE_INACTIVE = 0
local SENTRY_STATE_SEARCHING = 1
local SENTRY_STATE_ATTACKING = 2
local SENTRY_STATE_UPGRADING = 3

local SENTRYGUN_ATTACHMENT_MUZZLE = 0
local SENTRYGUN_ATTACHMENT_MUZZLE_ALT = 1
local SENTRYGUN_ATTACHMENT_ROCKET = 2

local SHIELD_NONE = 0
local SHIELD_NORMAL = 1
local SHIELD_MAX = 2

function ENT:KeyValue(key, value)
    if (string.StartsWith(key, "On")) then
		self:StoreOutput(key, value)
	else
        self:StoreValue(key, value)
    end
end

function ENT:AcceptInput(inputName, activator, caller, data)
    if (string.iequals(inputName, "SetHealth")) then self:Input_SetHealth(data) end
    if (string.iequals(inputName, "AddHealth")) then self:Input_AddHealth(data) end
    if (string.iequals(inputName, "RemoveHealth")) then self:Input_RemoveHealth(data) end
    if (string.iequals(inputName, "SetSolidToPlayer")) then self:Input_SetSolidToPlayer(data) end
    if (string.iequals(inputName, "SetTeam")) then self:Input_SetTeam(data) end
    if (string.iequals(inputName, "Skin")) then self:Input_Skin(data) end
    if (string.iequals(inputName, "SetBuilder")) then self:Input_SetBuilder(activator) end
    if (string.iequals(inputName, "Show")) then self:Input_Show() end
    if (string.iequals(inputName, "Hide")) then self:Input_Hide() end
    if (string.iequals(inputName, "Enable")) then self:Input_Enable() end
    if (string.iequals(inputName, "Disable")) then self:Input_Disable() end
end

function ENT:Initialize()
	self.Enabled = true

	self.m_iUpgradeLevel = 0
	self.m_iTeamNumber = self:GetStoredValue("TeamNum", "int", 3) -- 2: Red, 3: Blue
	self.m_nDefaultUpgradeLevel = self:GetStoredValue("defaultupgrade", "int", 0) -- 0, 1, 2
    self.m_iHighestUpgradeLevel = 3

	-- Spawn()
	self.m_iPitchPoseParameter = -1
	self.m_iYawPoseParameter = -1

	// Rotate Details
	self.m_iRightBound = 45
	self.m_iLeftBound = 315
	self.m_iBaseTurnRate = 6
	self.m_flFieldOfView = VIEW_FIELD_NARROW

	// Give the Gun some ammo
	self.m_iAmmoShells = 50
	self.m_iAmmoRockets = 8

	self.m_iMaxAmmoShells = SENTRYGUN_MAX_SHELLS_1
	self.m_iMaxAmmoRockets = SENTRYGUN_MAX_ROCKETS

	self.m_flFireRate = 1
	self.m_flSentryRange = SENTRY_MAX_RANGE
    self.m_flNextAttack = 0
    self.m_flNextRocketAttack = 0
    self.m_iLastMuzzleAttachmentFired = 0

	// Start searching for enemies
	self.m_hEnemy = nil

	self.m_flHeavyBulletResist = SENTRYGUN_MINIGUN_RESIST_LVL_1
	
	self.m_nShieldLevel = SHIELD_NONE -- todo: implement
	self.m_flScaledSentry = 1 -- mini sentry is just scaled down normal sentry with light bodygroup on top, todo: implement

	self.m_vecCurAngles = Vector()
    self.m_vecGoalAngles = Vector()

    self.m_flTurnRate = 0
    self.m_bTurningRight = false

	local iHealth = ternary(self:IsMiniBuilding(), SENTRYGUN_MINI_MAX_HEALTH, SENTRYGUN_MAX_HEALTH)
	self:SetMaxHealth(iHealth)
	self:SetSentryHealth(iHealth)
	
	self:SetSentryModel(SENTRY_MODEL_PLACEMENT)

	local shouldBeSolid = self:GetStoredValue("SolidToPlayer", "bool", true)
	self:SetCollisionGroup( ternary(shouldBeSolid, COLLISION_GROUP_NONE, COLLISION_GROUP_PASSABLE_DOOR) )

	self.m_iState = SENTRY_STATE_INACTIVE
	-- Spawn() end

	self:OnGoActive() -- triggered by input
end

function ENT:OnGoActive()
	self:SetSentryModel(SENTRY_MODEL_LEVEL_1)

	if (self:IsMiniBuilding()) then
		self:SetBodygroup( self:FindBodygroupByName("mini_sentry_light"), 1 )
	end

	self.m_iState = SENTRY_STATE_SEARCHING

	// Orient it
	local angles = self:GetAngles()

	self.m_vecCurAngles.y = math.NormalizeAngle(angles.y)
	self.m_iRightBound = math.NormalizeAngle(angles.y - 50)
	self.m_iLeftBound = math.NormalizeAngle(angles.y + 50)

	if (self.m_iRightBound > self.m_iLeftBound) then
		self.m_iRightBound = self.m_iLeftBound
		self.m_iLeftBound = math.NormalizeAngle(angles.y - 50)
	end

	// Start it rotating
	self.m_vecGoalAngles.y = self.m_iRightBound
	self.m_vecCurAngles.x = 0
	self.m_vecGoalAngles.x = 0
	self.m_bTurningRight = true

	self:EmitSound("Building_Sentrygun.Built")

	self.m_iAmmoShells = self.m_iMaxAmmoShells
	self.m_iAmmoRockets = self.m_iMaxAmmoRockets

	while (self.m_nDefaultUpgradeLevel + 1 > self.m_iUpgradeLevel) do
		self:Upgrade()
	end

	// Switch to the on state
	local index = self:FindBodygroupByName("powertoggle")
	if (index >= 0) then
		self:SetBodygroup(index, 1)
	end
end

function ENT:Think()
	if (!self.Enabled) then return end

    if (self.m_iState == SENTRY_STATE_SEARCHING) then self:SentryRotate() end
    if (self.m_iState == SENTRY_STATE_ATTACKING) then self:Attack() end

    self:NextThink(CurTime() + SENTRY_THINK_DELAY)
    return true
end

function ENT:SentryRotate()
	// if we're playing a fire gesture, stop it
	if ( self:IsPlayingGesture( ACT_RANGE_ATTACK1 ) ) then
		self:RemoveGesture( ACT_RANGE_ATTACK1 )
    end

	if ( self:IsPlayingGesture( ACT_RANGE_ATTACK1_LOW ) ) then
		self:RemoveGesture( ACT_RANGE_ATTACK1_LOW )
    end

	// animate
	self:FrameAdvance()

	// Look for a target
	if ( self:FindTarget() ) then return end
	
	// Rotate
	if ( !self:MoveTurret() ) then
		// Change direction
		if ( self:IsDisabled() || self.m_nShieldLevel == SHIELD_NORMAL ) then
			self:EmitSound( "Building_Sentrygun.Disabled" )
			self.m_vecGoalAngles.x = 30
		else
            if (self.m_iUpgradeLevel == 1) then self:EmitSound("Building_Sentrygun.Idle") end
            if (self.m_iUpgradeLevel == 2) then self:EmitSound("Building_Sentrygun.Idle2") end
            if (self.m_iUpgradeLevel >= 3) then self:EmitSound("Building_Sentrygun.Idle3") end

			// Switch rotation direction
			if ( self.m_bTurningRight ) then
				self.m_bTurningRight = false
				self.m_vecGoalAngles.y = self.m_iLeftBound
			else
				self.m_bTurningRight = true
				self.m_vecGoalAngles.y = self.m_iRightBound
            end

			// Randomly look up and down a bit
			if (math.random() < 0.3) then
				self.m_vecGoalAngles.x = math.random() + math.random(-10, 10)
            end
		end
	end
end

function ENT:FindTarget()
	// Sapper, etc.
	if ( self:IsDisabled() ) then return false end

	// Loop through players within SENTRY_MAX_RANGE units (sentry range).
	local vecSentryOrigin = self:GetFiringPos()

	// If we have an enemy get his minimum distance to check against.
	local vecSegment = nil
	local vecTargetCenter = nil
	local flMinDist2 = self.m_flSentryRange * self.m_flSentryRange
	local pTargetCurrent = nil
	local pTargetOld = self.m_hEnemy
	local flOldTargetDist2 = math.huge

	// Don't auto track to targets while under the effects of the player shield.
	// The shield fades 3 seconds after we disengage from player control.
	if ( self.m_nShieldLevel == SHIELD_NORMAL ) then return false end
		
	// Sentries will try to target players first, then objects.  However, if the enemy held was an object it will continue
	// to try and attack it first.

	local teamPlayers = team.GetPlayers( self:GetEnemyTeamNumber() )
	local nTeamCount = #teamPlayers

	for _, pTargetPlayer in ipairs(teamPlayers) do
		if ( !IsValid(pTargetPlayer) ) then continue end

		// Make sure the player is alive.
		if ( !pTargetPlayer:Alive() ) then continue end

		if ( pTargetPlayer:IsFlagSet(FL_NOTARGET) ) then continue end

		vecTargetCenter = pTargetPlayer:GetPos()
		vecTargetCenter = vecTargetCenter + pTargetPlayer:GetViewOffset()
		vecSegment = vecTargetCenter - vecSentryOrigin
		local flDist2 = vecSegment:LengthSqr()

		// Check to see if the target is closer than the already validated target.
		if ( flDist2 > flMinDist2 ) then continue end

		// Check if player is not behind walls or props
		if ( !self:IsTargetVisible(pTargetPlayer) ) then continue end

		flMinDist2 = flDist2
		pTargetCurrent = pTargetPlayer

		// Store the current target distance if we come across it
		if ( pTargetPlayer == pTargetOld ) then
			flOldTargetDist2 = flDist2
		end
	end

	// We have a target.
	if ( IsValid(pTargetCurrent) && self:IsTargetVisible(pTargetCurrent) ) then
		if ( pTargetCurrent != pTargetOld ) then
			// flMinDist2 is the new target's distance
			// flOldTargetDist2 is the old target's distance
			// Don't switch unless the new target is closer by some percentage
			if ( flMinDist2 < (flOldTargetDist2 * 0.75) ) then
				self:FoundTarget(pTargetCurrent, vecSentryOrigin, false)
            end
		end

		return true
	end

	return false
end

function ENT:FoundTarget( pTarget, vecSoundCenter, bNoSound )
	self.m_hEnemy = pTarget

	if ( ( self.m_iAmmoShells > 0 ) || ( self.m_iAmmoRockets > 0 && self.m_iUpgradeLevel >= 3 ) ) then
		// Play one sound to everyone but the target.
		local filter = RecipientFilter()
        filter:AddPVS(vecSoundCenter)

		if ( pTarget:IsPlayer() ) then
			// Play a specific sound just to the target and remove it from the general recipient list.
			if ( !bNoSound ) then
				local singleFilter = RecipientFilter()
                singleFilter:AddPlayer( pTarget )

				self:EmitSound( "Building_Sentrygun.AlertTarget", 75, 100, 1, CHAN_AUTO, 0, 0, singleFilter )
				filter:RemovePlayer( pTarget )
            end
		end

		if ( !bNoSound ) then
			self:EmitSound( "Building_Sentrygun.Alert", 75, 100, 1, CHAN_AUTO, 0, 0, filter )
        end
	end

	// Update timers, we are attacking now!
	self.m_iState = SENTRY_STATE_ATTACKING
	self.m_flNextAttack = CurTime() + SENTRY_THINK_DELAY
	if ( self.m_flNextRocketAttack < CurTime() ) then
		self.m_flNextRocketAttack = CurTime() // + 0.5
    end
end

function ENT:IsTargetVisible(target)
	if ( !IsValid(target) ) then return end
	if ( !target:IsPlayer() ) then return end
	if ( !target:Alive() ) then return end

	local vecSrc = self:GetFiringPos()
	local vecEnemyPos = self:GetEnemyAimPosition(target)
	local vecAimDir = vecEnemyPos - vecSrc
	vecAimDir:Normalize()

	local tr_data = {
		start = vecSrc,
		endpos = vecEnemyPos,
		filter = self,
		collisiongroup = COLLISION_GROUP_NONE,
		mask = MASK_SOLID,
	}
	local tr = util.TraceLine(tr_data)

	return tr.Entity == target
end

function ENT:Attack()
    self:FrameAdvance()

	if ( !self:FindTarget() ) then
		self.m_iState = SENTRY_STATE_SEARCHING
		self.m_hEnemy = nil
		return
    end

    local vecMid = self:GetFiringPos()
	local vecMidEnemy = self.m_hEnemy:EyePos()
	local vecDirToEnemy = vecMidEnemy - vecMid

    local angToTarget = vecDirToEnemy:Angle()

	angToTarget.y = math.NormalizeAngle(angToTarget.y)

	if (angToTarget.x < -180) then
		angToTarget.x = angToTarget.x + 360
    end

	if (angToTarget.x > 180) then
		angToTarget.x = angToTarget.x - 360
    end

	// now all numbers should be in [1...360]
	// pin to turret limitations to [-50...50]
	if (angToTarget.x > 50) then
		angToTarget.x = 50
	elseif (angToTarget.x < -50) then
		angToTarget.x = -50
    end

	self.m_vecGoalAngles.y = angToTarget.y
	self.m_vecGoalAngles.x = angToTarget.x

    self:MoveTurret()

    // Fire on the target if it's within 10 units of being aimed right at it
	if ( self.m_flNextAttack <= CurTime() && (self.m_vecGoalAngles - self.m_vecCurAngles):Length() <= 10 ) then
		self:SentryFire()

		self.m_flFireRate = 1		
		if ( self:IsMiniBuilding() && !self:IsDisposableBuilding() ) then
			self.m_flFireRate = self.m_flFireRate * 0.75
        end

		if ( self.m_iUpgradeLevel == 1 ) then
			// Level 1 sentries fire slower
			self.m_flNextAttack = CurTime() + (0.2 * self.m_flFireRate)
		else
			self.m_flNextAttack = CurTime() + (0.1 * self.m_flFireRate)
        end
	end
end

function ENT:FireRocket()
	if ( self.m_flNextRocketAttack >= CurTime() || self.m_iAmmoRockets <= 0 ) then return false end

	if ( !IsValid(self.m_hEnemy) ) then return false end

	local tbl = self:GetAttachment( self:GetSentryAttachment(SENTRYGUN_ATTACHMENT_ROCKET) )
	local vecSrc = tbl.Pos

	local vecEnemyPos = self:GetEnemyAimPosition(self.m_hEnemy)
	local vecAimDir = vecEnemyPos - vecSrc
	vecAimDir:Normalize()

	// If we cannot see their WorldSpaceCenter ( possible, as we do our target finding based
	// on the eye position of the target ) then fire at the eye position
	local tr_data = {
		start = vecSrc,
		endpos = vecEnemyPos,
		filter = self,
		collisiongroup = COLLISION_GROUP_NONE,
		mask = MASK_SOLID,
	}
	local tr = util.TraceLine(tr_data)

	if ( IsValid(tr.Entity) && !tr.Entity:IsWorld() ) then
		self:EmitSound( "Building_Sentrygun.FireRocket" )

		local angAimDir = vecAimDir:Angle()
		local pProjectile = ents.Create("tf_projectile_sentryrocket")
		pProjectile:Spawn()
		pProjectile:SetOwner(self)
		pProjectile:SetPos(vecSrc)
		pProjectile:SetAngles(angAimDir)

		pProjectile.Damage = 100

		// Setup next rocket shot
		self:AddGesture(ACT_RANGE_ATTACK2)
		self.m_flNextRocketAttack = CurTime() + 3

		if ( !self:HasInfiniteAmmo() ) then
			self.m_iAmmoRockets = self.m_iAmmoRockets - 1
		end
	end

	return true
end

function ENT:SentryFire()
	local vecAimDir = Vector()

	// Level 3 Turrets fire rockets every 3 seconds
	if ( self.m_iUpgradeLevel >= 3 && (self.m_iAmmoRockets > 0 || self:HasInfiniteAmmo()) && self.m_flNextRocketAttack < CurTime() ) then
		self:FireRocket()
    end

	// All turrets fire shells
	if ( self.m_iAmmoShells > 0 || self:HasInfiniteAmmo() ) then
		if ( !self:IsPlayingGesture( ACT_RANGE_ATTACK1 ) ) then
			self:RemoveGesture( ACT_RANGE_ATTACK1_LOW )
			self:AddGesture( ACT_RANGE_ATTACK1 )
        end

		if ( !IsValid(self.m_hEnemy) ) then return false end
        
		local iAttachment = self:GetFireAttachment()
		local tbl = self:GetAttachment( iAttachment )
		local vecSrc = tbl.Pos
		local vecAng = tbl.Ang

		local vecMidEnemy = self:GetEnemyAimPosition( self.m_hEnemy )

		// If we cannot see their WorldSpaceCenter ( possible, as we do our target finding based
		// on the eye position of the target ) then fire at the eye position
		local tr_data = {
            start = vecSrc,
            endpos = vecMidEnemy,
            filter = self,
            collisiongroup = COLLISION_GROUP_NONE,
            mask = MASK_SOLID,
        }

		local tr = util.TraceLine(tr_data)

		if ( !IsValid(tr.Entity) || tr.Entity:IsWorld() ) then
			// Hack it lower a little bit..
			// The eye position is not always within the hitboxes for a standing TF Player
			vecMidEnemy = self.m_hEnemy:EyePos() + Vector(0, 0, -5)
        end

		vecAimDir = vecMidEnemy - vecSrc
		local flDistToTarget = vecAimDir:Length()
		vecAimDir:Normalize()

		local info = {}
		info.Src = vecSrc
		info.Dir = vecAimDir
		info.Tracer = 1
		info.Num = 1
		info.Attacker = self:GetOwner()
        info.Attacker = self
		info.Distance = flDistToTarget + 100
		--info.AmmoType = m_iAmmoType
		if ( self:IsMiniBuilding() ) then
			info.Damage = 8
			info.Force = 0.0
		else
			info.Damage = 16
        end

		self:FireBullets(info)

		local data = EffectData()
		data:SetEntIndex( self:EntIndex() )
		data:SetAttachment( iAttachment )
		data:SetFlags( self.m_iUpgradeLevel )
		data:SetOrigin( vecSrc )
		util.Effect("AirboatMuzzleFlash", data)

		if ( self:IsMiniBuilding() ) then
			self:EmitSound( "Building_MiniSentrygun.Fire" )
		else
			if (self.m_iUpgradeLevel == 1) then self:EmitSound( "Building_Sentrygun.Fire" ) end
			if (self.m_iUpgradeLevel == 2) then self:EmitSound( "Building_Sentrygun.Fire2" ) end
			if (self.m_iUpgradeLevel >= 3) then self:EmitSound( "Building_Sentrygun.Fire3" ) end
		end

		if ( !self:HasInfiniteAmmo() ) then
			self.m_iAmmoShells = self.m_iAmmoShells - 1
        end
	else
		if ( self.m_iUpgradeLevel > 1 ) then
			if ( !self:IsPlayingGesture( ACT_RANGE_ATTACK1_LOW ) ) then
				self:RemoveGesture( ACT_RANGE_ATTACK1 )
				self:AddGesture( ACT_RANGE_ATTACK1_LOW )
            end
		end

		// Out of ammo, play a click
		self:EmitSound( "Building_Sentrygun.Empty" )

		// Disposable sentries blow up when their ammo runs out
		if ( self:IsDisposableBuilding() ) then
			self:DetonateObject()
        end

		self.m_flNextAttack = CurTime() + 0.2
	end

	return true
end

function ENT:GetEnemyAimPosition( pEnemy )
	// Default to pointing to the origin
	local vecPos = pEnemy:GetPos()
	local bone = nil

	bone = pEnemy:LookupBone("ValveBiped.Bip01_Neck1")
    if (bone != nil) then return pEnemy:GetBonePosition(bone) end

	bone = pEnemy:LookupBone("ValveBiped.Bip01_Spine2")
    if (bone != nil) then return pEnemy:GetBonePosition(bone) end

	return vecPos
end

function ENT:MoveTurret()
    local bMoved = false

	local iBaseTurnRate = self:GetBaseTurnRate() * FrameTime()

	if ( self:IsMiniBuilding() ) then
		iBaseTurnRate = iBaseTurnRate * 1.35
    end

	// any x movement?
	if ( self.m_vecCurAngles.x != self.m_vecGoalAngles.x ) then
        
        local flDir = ternary(self.m_vecGoalAngles.x > self.m_vecCurAngles.x, 1, -1)
		self.m_vecCurAngles.x = self.m_vecCurAngles.x + SENTRY_THINK_DELAY * ( iBaseTurnRate * 5 ) * flDir

		// if we started below the goal, and now we're past, peg to goal
		if ( flDir == 1 ) then
			if (self.m_vecCurAngles.x > self.m_vecGoalAngles.x) then
				self.m_vecCurAngles.x = self.m_vecGoalAngles.x
            end
		else
			if (self.m_vecCurAngles.x < self.m_vecGoalAngles.x) then
				self.m_vecCurAngles.x = self.m_vecGoalAngles.x
            end
        end

		self:SetPoseParameter( self.m_iPitchPoseParameter, -self.m_vecCurAngles.x )

		bMoved = true
	end

	if ( self.m_vecCurAngles.y != self.m_vecGoalAngles.y ) then
        local flDir = ternary(self.m_vecGoalAngles.y > self.m_vecCurAngles.y, 1, -1)
		local flDist = math.abs( self.m_vecGoalAngles.y - self.m_vecCurAngles.y )
		local bReversed = false

		if ( flDist > 180 ) then
			flDist = 360 - flDist
			flDir = -flDir
			bReversed = true
        end

		if ( !IsValid(self.m_hEnemy) ) then
			if ( flDist > 30 ) then
				if ( self.m_flTurnRate < iBaseTurnRate * 10 ) then
					self.m_flTurnRate = self.m_flTurnRate + iBaseTurnRate
                end
			else
				// Slow down
				if ( self.m_flTurnRate > (iBaseTurnRate * 5) ) then
					self.m_flTurnRate = self.m_flTurnRate - iBaseTurnRate
                end
            end
		else
			// When tracking enemies, move faster and don't slow
			if ( flDist > 30 ) then
				if (self.m_flTurnRate < iBaseTurnRate * 30) then
					self.m_flTurnRate = self.m_flTurnRate + iBaseTurnRate * 3
                end
			end
		end

		self.m_vecCurAngles.y = self.m_vecCurAngles.y + SENTRY_THINK_DELAY * self.m_flTurnRate * flDir

		// if we passed over the goal, peg right to it now
		if (flDir == -1) then
			if ( (bReversed == false && self.m_vecGoalAngles.y > self.m_vecCurAngles.y) || (bReversed == true && self.m_vecGoalAngles.y < self.m_vecCurAngles.y) ) then
				self.m_vecCurAngles.y = self.m_vecGoalAngles.y
            end
		else
			if ( (bReversed == false && self.m_vecGoalAngles.y < self.m_vecCurAngles.y) || (bReversed == true && self.m_vecGoalAngles.y > self.m_vecCurAngles.y) ) then
				self.m_vecCurAngles.y = self.m_vecGoalAngles.y
            end
		end

		if ( self.m_vecCurAngles.y < 0 ) then
			self.m_vecCurAngles.y = self.m_vecCurAngles.y + 360
		elseif ( self.m_vecCurAngles.y >= 360 ) then
			self.m_vecCurAngles.y = self.m_vecCurAngles.y - 360
        end

		if ( flDist < ( SENTRY_THINK_DELAY * 0.5 * iBaseTurnRate ) ) then
			self.m_vecCurAngles.y = self.m_vecGoalAngles.y
        end

		local angles = self:GetAngles()
		local flYaw = self.m_vecCurAngles.y - angles.y

		self:SetPoseParameter( self.m_iYawPoseParameter, -flYaw )

		bMoved = true
	end

	if ( !bMoved || self.m_flTurnRate <= 0 ) then
		self.m_flTurnRate = iBaseTurnRate * 5
    end

	return bMoved
end

function ENT:GetBaseTurnRate()
	if (self.m_iState == SENTRY_STATE_SEARCHING) then
		return self.m_iBaseTurnRate * 40
	end

	if (self.m_iState == SENTRY_STATE_ATTACKING) then
		return self.m_iBaseTurnRate * 100
	end

	return self.m_iBaseTurnRate
end

function ENT:GetFireAttachment()
	local iAttachment = 0

	if ( self.m_iUpgradeLevel > 1 && self.m_iLastMuzzleAttachmentFired == self:GetSentryAttachment(SENTRYGUN_ATTACHMENT_MUZZLE) ) then
		// level 2 and 3 turrets alternate muzzles each time they fizzy fizzy fire.
		iAttachment = self:GetSentryAttachment(SENTRYGUN_ATTACHMENT_MUZZLE_ALT)
	else
		iAttachment = self:GetSentryAttachment(SENTRYGUN_ATTACHMENT_MUZZLE)
    end
	self.m_iLastMuzzleAttachmentFired = iAttachment

	return iAttachment
end

function ENT:Upgrade()
	// Increase level
	self.m_iUpgradeLevel = self.m_iUpgradeLevel + 1

	if (self.m_iHighestUpgradeLevel < self.m_iUpgradeLevel) then
		self.m_iHighestUpgradeLevel = self.m_iUpgradeLevel
    end

	// more health
	local iMaxHealth = ternary(self:IsMiniBuilding(), SENTRYGUN_MINI_MAX_HEALTH, SENTRYGUN_MAX_HEALTH)
	local flMultiplier = math.pow( UPGRADE_LEVEL_HEALTH_MULTIPLIER, self.m_iUpgradeLevel - 1 )
	iMaxHealth = iMaxHealth * flMultiplier

	self:SetMaxHealth(iMaxHealth)
	self:SetSentryHealth(iMaxHealth)

    self:EmitSound("Building_Sentrygun.Built")
	self:RemoveAllGestures()

    if (self.m_iUpgradeLevel == 2) then
        self:SetSentryModel(SENTRY_MODEL_LEVEL_2)
		self.m_flHeavyBulletResist = SENTRYGUN_MINIGUN_RESIST_LVL_2
		self.m_iMaxAmmoShells = SENTRYGUN_MAX_SHELLS_2
    end

    if (self.m_iUpgradeLevel >= 3) then
        self:SetSentryModel(SENTRY_MODEL_LEVEL_3)
		self.m_flHeavyBulletResist = SENTRYGUN_MINIGUN_RESIST_LVL_3
		self.m_iMaxAmmoShells = SENTRYGUN_MAX_SHELLS_3
		self.m_iAmmoRockets = SENTRYGUN_MAX_ROCKETS
    end

	// more ammo capability
	self.m_iAmmoShells = self.m_iMaxAmmoShells

	self.m_iState = SENTRY_STATE_SEARCHING
	self.m_hEnemy = nil
end

function ENT:IsMiniBuilding()
    return false -- placeholder
end

function ENT:IsDisposableBuilding()
    return false -- placeholder
end

-- sapper, etc
function ENT:IsDisabled()
    return false -- placeholder
end

function ENT:GetTeamNumber()
	return self.m_iTeamNumber
end

function ENT:GetEnemyTeamNumber()
	return ternary(self.m_iTeamNumber == TF_TEAM_RED, TF_TEAM_BLUE, TF_TEAM_RED)
end

function ENT:GetFiringPos()
    return self:GetBonePosition( self:LookupBone("upper_telescope_01") )
end

function ENT:GetSentryAttachment(att)
	if (self.m_iUpgradeLevel == 1) then
        if (att == SENTRYGUN_ATTACHMENT_MUZZLE) then return self:LookupAttachment( "muzzle" ) end
        if (att == SENTRYGUN_ATTACHMENT_MUZZLE_ALT) then return 0 end
        if (att == SENTRYGUN_ATTACHMENT_ROCKET) then return 0 end
    end

	if (self.m_iUpgradeLevel >= 2) then
        if (att == SENTRYGUN_ATTACHMENT_MUZZLE) then return self:LookupAttachment( "muzzle_l" ) end
        if (att == SENTRYGUN_ATTACHMENT_MUZZLE_ALT) then return self:LookupAttachment( "muzzle_r" ) end
        if (att == SENTRYGUN_ATTACHMENT_ROCKET) then return self:LookupAttachment( "rocket_l" ) end
    end

	return 0
end

function ENT:SetSentryModel(pModel)
	local flPoseParam0 = 0
	local flPoseParam1 = 0

	// Save pose parameters across model change
	if ( self.m_iPitchPoseParameter >= 0 ) then
		flPoseParam0 = self:GetPoseParameter(self.m_iPitchPoseParameter)
	end

	if ( self.m_iYawPoseParameter >= 0 ) then
		flPoseParam1 = self:GetPoseParameter(self.m_iYawPoseParameter)
	end

	self:SetModel(pModel)

	// Reset this after model change
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(SENTRYGUN_MINS, SENTRYGUN_MAXS)

	// Restore pose parameters
	self.m_iPitchPoseParameter = self:LookupPoseParameter("aim_pitch")
	self.m_iYawPoseParameter = self:LookupPoseParameter("aim_yaw")

	self:SetPoseParameter(self.m_iPitchPoseParameter, flPoseParam0)
	self:SetPoseParameter(self.m_iYawPoseParameter, flPoseParam1)
end

function ENT:SetSentryHealth(value)
	self:TriggerOutput("OnObjectHealthChanged", self, value)
	self:SetHealth(value)
end

function ENT:OnTakeDamage(dmginfo)
	self:TriggerOutput("OnDamaged", dmginfo:GetAttacker())
	
	if ( !self:IsInvulnerable() ) then
		self:SetSentryHealth( self:Health() - dmginfo:GetDamage() )
		if ( self:Health() <= 0 ) then self:DetonateObject() end
	end
end

function ENT:DetonateObject()
	self:TriggerOutput("OnDestroyed", self)

	self:EmitSound("Building_Sentry.Explode")
    ParticleEffect("ExplosionCore_MidAir", self:GetPos(), Angle())

	self:PrecacheGibs()
	self:GibBreakClient(Vector(math.random(-50, 50), math.random(-50, 50), math.random(50, 100)))

	self:Remove()
	
	print("DetonateObject()")
end

-- Flags
function ENT:IsInvulnerable()
	return self:HasSpawnFlags(2)
end

function ENT:IsUpgradable()
	return self:HasSpawnFlags(4)
end

function ENT:HasInfiniteAmmo()
	return self:HasSpawnFlags(8)
end
-- Flags End

-- Inputs
function ENT:Input_SetHealth(data)
	self:SetSentryHealth(tonumber(data))
	self:SetMaxHealth(tonumber(data))
end

function ENT:Input_AddHealth(data)
	local newHealth = self:Health() + tonumber(data)
	self:SetSentryHealth( math.Clamp(newHealth, 0, self:GetMaxHealth()) )
end

function ENT:Input_RemoveHealth(data)
	local newHealth = self:Health() - tonumber(data)
	self:SetSentryHealth(newHealth)

	if (newHealth <= 0) then self:DetonateObject() end
end

function ENT:Input_SetSolidToPlayer(data)
	local shouldBeSolid = tobool(data)
	self:SetCollisionGroup( ternary(shouldBeSolid, COLLISION_GROUP_NONE, COLLISION_GROUP_PASSABLE_DOOR) )
end

function ENT:Input_SetTeam(data)
	self.m_iTeamNumber = tonumber(data)
end

function ENT:Input_Skin(data)
	self:SetSkin( tonumber(data) )
end

function ENT:Input_SetBuilder(activator)
	self:SetOwner(activator)
end

function ENT:Input_Show()
	self:TriggerOutput("OnReenabled", self)
	self.Enabled = true
	self:SetNoDraw(false)
end

function ENT:Input_Hide()
	self:TriggerOutput("OnDisabled", self)
	self.Enabled = false
	self:SetNoDraw(true)
end

function ENT:Input_Enable()
	self:TriggerOutput("OnReenabled", self)
	self.Enabled = true
end

function ENT:Input_Disable()
	self:TriggerOutput("OnDisabled", self)
	self.Enabled = false
end
-- Inputs End
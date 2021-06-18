SWEP.PrintName = "Scripted Weapon"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.HoldType = ""
SWEP.BothFireMode = true -- Have the weapon both fire mode
SWEP.Primary.ClipSize = 8 -- Size of a clip
SWEP.Primary.DefaultClip = 32 -- Default number of bullets in a clip
SWEP.Primary.Automatic = false -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""
SWEP.Primary.RPM = 150
SWEP.Primary.Sound = Sound("")
SWEP.Secondary.Ammo = ""
SWEP.NextFireSelect = 0
SWEP.FirstTime = 0
SWEP.ConeSpread = 0.05
SWEP.IronTime = 0.15
-- Adjust these variables to move the viewmodel's position
SWEP.IronSightsPos = Vector(-2.8, -8, 1)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.Kick = 0.5
SWEP.HorizontalKick = 0.125

--[[---------------------------------------------------------
	Name: GetViewModelPosition
	Desc: Allows you to re-position the view model
-----------------------------------------------------------]]
function SWEP:SetIronsights(b)
    if (b ~= self:GetIronsights()) then
        self:SetIronsightsPredicted(b)
        self:SetIronsightsTime(CurTime())

        if CLIENT then
            self:CalcViewModel()
        end
    end
end

function SWEP:GetIronsights()
    return self:GetIronsightsPredicted()
end

function SWEP:CalcViewModel()
    if (not CLIENT) or (not IsFirstTimePredicted()) then return end
    self.bIron = self:GetIronsights()
    self.fIronTime = self:GetIronsightsTime()
    self.fCurrentTime = CurTime()
    self.fCurrentSysTime = SysTime()
end

--- Dummy functions that will be replaced when SetupDataTables runs. These are
--- here for when that does not happen (due to e.g. stacking base classes)
function SWEP:GetIronsightsTime() return -1 end
function SWEP:SetIronsightsTime() end
function SWEP:GetIronsightsPredicted() return false end
function SWEP:SetIronsightsPredicted() end

local host_timescale = GetConVar("host_timescale")
local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition(pos, ang)
    if (not self.IronSightsPos) then return pos, ang end
    if self:GetOwner():KeyDown(IN_SPEED) then return pos, ang end

    local mul = 1.0

    if (self.bIron == nil) then return pos, ang end

    local bIron = self.bIron
    local time = self.fCurrentTime + (SysTime() - self.fCurrentSysTime) * game.GetTimeScale() * host_timescale:GetFloat()

    if bIron then
        self.SwayScale = 0.3
        self.BobScale = 0.1
        self.ConeSpread = 0.01
    else
        self.SwayScale = 1.0
        self.BobScale = 1.0
        self.ConeSpread = 0.05
    end

    local fIronTime = self.fIronTime
    if not bIron and fIronTime < time - IRONSIGHT_TIME then return pos, ang end

    if fIronTime > time - IRONSIGHT_TIME then
        mul = math.Clamp((time - fIronTime) / IRONSIGHT_TIME, 0, 1)

        if not bIron then
            mul = 1 - mul
        end
    end

    local Offset = self.IronSightsPos

    if (self.IronSightsAng) then
        ang = ang * 1
        ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * mul)
        ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * mul)
        ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * mul)
    end

    local Right = ang:Right()
    local Up = ang:Up()
    local Forward = ang:Forward()
    pos = pos + Offset.x * Right * mul
    pos = pos + Offset.y * Forward * mul
    pos = pos + Offset.z * Up * mul

    return pos, ang
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IronsightsPredicted")
    self:NetworkVar("Bool", 1, "Lowering")
    self:NetworkVar("Bool", 2, "Lowered")
    self:NetworkVar("Bool", 3, "Reloading")
    self:NetworkVar("Bool", 4, "HaveToBeSwitchedAuto")
    self:NetworkVar("Bool", 5, "Deployed")
    self:NetworkVar("Bool", 6, "IronSights")
    self:NetworkVar("Bool", 7, "SelectingFireMode")
    self:NetworkVar("Float", 0, "IronsightsTime")
    self:NetworkVar("String", 0, "FireMode")
end

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.DrawCrosshair = false
    self:SetDeployed(false)
    self:SetFireMode("semi")
end

--[[---------------------------------------------------------
	Name: SWEP:PrimaryAttack()
	Desc: +attack1 has been pressed
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if (not self:CanPrimaryAttack()) then return end
    -- Play shoot sound
    self:EmitSound(self.Primary.Sound)
    -- Shoot 9 bullets, 150 damage, 0.75 aimcone
    self:ShootBullet(150, 1, self.ConeSpread, self.Primary.Ammo)
    local kickangle = Angle(-math.random(self.Kick,self.Kick + 1),math.random(-self.HorizontalKick,self.HorizontalKick),0)
    self:GetOwner():ViewPunch(kickangle)
    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + kickangle)
    -- Remove 1 bullet from our clip
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self:GetReloading() then return end
    self:SetIronsights(not self:GetIronsights())
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
    if not self:GetOwner():KeyDown(IN_SPEED) and not self:GetOwner():KeyDown(IN_USE) and not self:GetSelectingFireMode() then
        if self.FirstTime == 0 then
            self.FirstTime = CurTime()
        end

        timer.Simple(0.1, function()
            if not self:GetOwner():KeyDown(IN_RELOAD) then
                if (CurTime() - self.FirstTime) < 0.3 then
                    self.FirstTime = 0

                    if self:Clip1() <= 0 then
                        self:SetReloading(true)
                        self:DefaultReload(ACT_VM_RELOAD_EMPTY)
                        self:GetOwner():SetAnimation(PLAYER_RELOAD)

                        if self:GetHaveToBeSwitchedAuto() then
                            self.Primary.Automatic = true
                        end
                    else
                        if self:Clip1() < self.Primary.ClipSize then
                            self:SetReloading(true)
                            self:DefaultReload(ACT_VM_RELOAD)
                            self:GetOwner():SetAnimation(PLAYER_RELOAD)
                        end
                    end
                else
                    self.FirstTime = 0
                end
            end
        end)
    end
end

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]
function SWEP:Think()
    self:CalcViewModel()

    if self:GetDeployed() then
        if not self:GetLowering() and self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) then
            self:SetLowering(true)
            self:SetLowered(not self:GetLowered())
        end

        if not self:GetOwner():KeyDown(IN_RELOAD) then
            if self:GetLowering() then
                self:SetLowering(false)
            end

            if self:GetReloading() then
                self:SetReloading(false)
            end

            if not self:GetOwner():KeyDown(IN_USE) and self:GetSelectingFireMode() then
                self:SetSelectingFireMode(false)
            end
        end

        if self:GetLowered() then
            self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            self:SetHoldType("passive")
            self:SetFireMode("safe")
        else
            self:SendWeaponAnim(ACT_VM_IDLE)
            self:SetHoldType(self.HoldType)
            if self.Primary.Automatic then
                self:SetFireMode("auto")
            else
                self:SetFireMode("semi")
            end
        end

        if not self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) and self.BothFireMode and self.NextFireSelect < CurTime() then
            self.NextFireSelect = CurTime() + 1
            self:EmitSound("Weapon_AR2.Empty")
            self:SetSelectingFireMode(true)

            if self:GetHaveToBeSwitchedAuto() then
                self:SetHaveToBeSwitchedAuto(false)
            end

            if self.Primary.Automatic then
                self.Primary.Automatic = false
                self:SetFireMode("semi")
            else
                self.Primary.Automatic = true
                self:SetFireMode("auto")
            end
        end

        if self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_FORWARD) then
            self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            self:SetHoldType("passive")

            if self:GetIronsights() then
                self:SetIronsights(false)
            end

            timer.Simple(0.1, function()
                if not self:GetOwner():KeyDown(IN_SPEED) and not self:GetLowered() and self:GetOwner():Alive() and not self:GetReloading() then
                    self:SendWeaponAnim(ACT_VM_IDLE)
                    self:SetHoldType(self.HoldType)
                end
            end)
        end
    end
end

--[[---------------------------------------------------------
	Name: SWEP:Holster( weapon_to_swap_to )
	Desc: Weapon wants to holster
	RetV: Return true to allow the weapon to holster
-----------------------------------------------------------]]
function SWEP:Holster(wep)
    return true
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()
    self:SetIronSights(false)

    if not self:GetDeployed() and self:GetOwner():IsPlayer() then
        self:SendWeaponAnim(ACT_VM_DEPLOY)

        timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(), function()
            if IsValid(self:GetOwner()) and self:GetOwner():Alive() and self:GetOwner():IsPlayer() and self:GetOwner():GetActiveWeapon() == self then
                self:SetDeployed(true)
            end
        end)
    else
        self:SendWeaponAnim(ACT_VM_DRAW)
    end

    return true
end

--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to create shoot effects
-----------------------------------------------------------]]
function SWEP:ShootEffects()
    local L = {ACT_VM_RECOIL1, ACT_VM_RECOIL2, ACT_VM_RECOIL3}

    self:SendWeaponAnim(L[math.random(1, 3)]) -- View model animation
    self:GetOwner():MuzzleFlash() -- Crappy muzzle light
    self:GetOwner():SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: A convenience function to shoot bullets
-----------------------------------------------------------]]
function SWEP:ShootBullet(damage, num_bullets, aimcone, ammo_type, force, tracer)
    local bullet = {}
    bullet.Num = num_bullets
    bullet.Src = self:GetOwner():GetShootPos() -- Source
    bullet.Dir = self:GetOwner():GetAimVector() -- Dir of bullet
    bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
    bullet.Tracer = tracer or 5 -- Show a tracer on every x bullets
    bullet.Force = force or 1 -- Amount of force to give to phys objects
    bullet.Damage = damage
    bullet.AmmoType = ammo_type or self.Primary.Ammo
    self:SetLowered(false)
    self:SetHoldType(self.HoldType)
    self:GetOwner():FireBullets(bullet)
    self:ShootEffects()
end

--[[---------------------------------------------------------
	Name: SWEP:TakePrimaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo(num)
    -- Doesn't use clips
    if (self:Clip1() <= 0) then
        if (self:Ammo1() <= 0) then return end
        self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())

        return
    end

    self:SetClip1(self:Clip1() - num)
end

--[[---------------------------------------------------------
	Name: SWEP:TakeSecondaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo(num)
end

--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_SPEED) or self:GetSelectingFireMode() or self:GetReloading() or not self:GetDeployed() or self:GetLowering() or self:GetLowered() then return false end

    if (self:Clip1() <= 0) then
        self:EmitSound("Weapon_Pistol.Empty")
        self:SendWeaponAnim(ACT_VM_DRYFIRE)

        if self.Primary.Automatic then
            self.Primary.Automatic = false
            self:SetHaveToBeSwitchedAuto(true)
        end

        self.Primary.Automatic = false

        return false
    end

    return true
end

--[[---------------------------------------------------------
	Name: SWEP:CanSecondaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
end

--[[---------------------------------------------------------
	Name: OnRemove
	Desc: Called just before entity is deleted
-----------------------------------------------------------]]
function SWEP:OnRemove()
end

--[[---------------------------------------------------------
	Name: OwnerChanged
	Desc: When weapon is dropped or picked up by a new player
-----------------------------------------------------------]]
function SWEP:OwnerChanged()
end

--[[---------------------------------------------------------
	Name: Ammo1
	Desc: Returns how much of ammo1 the player has
-----------------------------------------------------------]]
function SWEP:Ammo1()
    return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
end

--[[---------------------------------------------------------
	Name: Ammo2
	Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
    return self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType())
end

--[[---------------------------------------------------------
	Name: SetDeploySpeed
	Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
-----------------------------------------------------------]]
function SWEP:SetDeploySpeed(speed)
    self.m_WeaponDeploySpeed = tonumber(speed)
end

--[[---------------------------------------------------------
	Name: DoImpactEffect
	Desc: Callback so the weapon can override the impact effects it makes
		 return true to not do the default thing - which is to call UTIL_ImpactTrace in c++
-----------------------------------------------------------]]
function SWEP:DoImpactEffect(tr, nDamageType)
    return false
end
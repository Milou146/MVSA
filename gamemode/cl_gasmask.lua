include( "sh_gasmask.lua" )
CreateClientConVar("g4p_gasmask_sndtype", "1", true, false)
local meta = FindMetaTable("Player")

local GASMASK_DelayedFunc_ON = {
    [1] = {time = 0.3, name_sound = "GASMASK_Foley", anim = "put_on"},
    [2] = {time = 0.6, name_sound = "GASMASK_Inhale", anim = nil},
    [3] = {time = 1.2, name_sound = "GASMASK_OnOff", anim = nil},
    [4] = {time = 1.79, name_sound = nil, anim = "idle_on"}
}

local GASMASK_DelayedFunc_OFF = {
    [1] = {time = 0.3, name_sound = "GASMASK_Foley", anim = nil},
    [2] = {time = 0.45, name_sound = "GASMASK_Exhale", anim = nil},
    [3] = {time = 1.2, name_sound = "GASMASK_DrawHolster", anim = nil},
    [4] = {time = 1.25, name_sound = nil, anim = "holster"}
}

function meta:GASMASK_PlayAnim(anim)
    local mask = self.GASMASK_HudModel

    if mask and IsValid(mask) then
        mask:ResetSequence(anim)
        mask:SetCycle(0)
        mask:SetPlaybackRate(1)
    end
end

function meta:GASMASK_DelayedFunc(time, func)
    timer.Simple(time, function()
        if not IsValid(self) or not self:Alive() then return end
        func(self)
    end)
end

net.Receive("GASMASK_RequestToggle", function()
    local ply = LocalPlayer()
    local state = net.ReadBool()

    if state then
        if InventoryPanel and InventoryPanel:IsValid() then
            GasMask:SetAlpha(255)
            PlayerModel.Entity:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[2])
        end

        ply:GASMASK_PlayAnim("draw")
        ply:EmitSound("GASMASK_DrawHolster")

        for _, v in ipairs(GASMASK_DelayedFunc_ON) do
            ply:GASMASK_DelayedFunc(v.time, function()
                ply:GASMASK_PlayAnim(v.anim)
                ply:EmitSound(v.name_sound)
            end)
        end
    else
        if InventoryPanel and InventoryPanel:IsValid() then
            GasMask:SetAlpha(100)
            PlayerModel.Entity:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[3])
        end
        ply:GASMASK_PlayAnim("take_off")
        ply:EmitSound("GASMASK_OnOff")
        
        for _, v in ipairs(GASMASK_DelayedFunc_OFF) do
            ply:GASMASK_DelayedFunc(v.time, function()
                ply:GASMASK_PlayAnim(v.anim)
                ply:EmitSound(v.name_sound)
            end)
        end
    end
end)

-- calculates the camera FOV depending on viewmodel FOV
local function GASMASK_CalcHorizontalFromVerticalFOV(num)
    local r = ScrW() / ScrH() -- our resolution
    r = r / (4 / 3) -- 4/3 is base Source resolution, so we have do divide our resolution by that
    local tan, atan, deg, rad = math.tan, math.atan, math.deg, math.rad
    local vFoV = rad(num)
    local hFoV = deg(2 * atan(tan(vFoV / 2) * r)) -- this was a bitch

    return hFoV
end

local function GASMASK_GetPlayerColor()
    local owner = LocalPlayer()
    if owner:IsValid() and owner:IsPlayer() and owner.GetPlayerColor then return owner:GetPlayerColor() end

    return Vector(1, 1, 1)
end

local function GASMASK_CopyBodyGroups(source, target)
    for num, _ in pairs(source:GetBodyGroups()) do
        target:SetBodygroup(num - 1, source:GetBodygroup(num - 1))
        target:SetSkin(source:GetSkin())
    end
end

local function GASMASK_DrawInHud()
    local ply = LocalPlayer()

    if not ply.GASMASK_HudModel or not IsValid(ply.GASMASK_HudModel) then
        ply.GASMASK_HudModel = ClientsideModel("models/gmod4phun/c_contagion_gasmask.mdl", RENDERGROUP_BOTH)
        ply.GASMASK_HudModel:SetNoDraw(true)
        ply:GASMASK_PlayAnim("idle_holstered")
    end

    local mask = ply.GASMASK_HudModel
    if not IsValid(mask) then return end

    if not ply.GASMASK_HandsModel or not IsValid(ply.GASMASK_HandsModel) then
        local gmhands = ply:GetHands()

        if IsValid(gmhands) then
            ply.GASMASK_HandsModel = ClientsideModel(gmhands:GetModel(), RENDERGROUP_BOTH)
            ply.GASMASK_HandsModel:SetNoDraw(true)
            ply.GASMASK_HandsModel:SetParent(mask)
            ply.GASMASK_HandsModel:AddEffects(EF_BONEMERGE)
            GASMASK_CopyBodyGroups(gmhands, ply.GASMASK_HandsModel)
            ply.GASMASK_HandsModel.GetPlayerColor = GASMASK_GetPlayerColor
        end
    end

    local hands = ply.GASMASK_HandsModel

    if not ply:Alive() then
        ply:GASMASK_PlayAnim("idle_holstered")
    end

    local pos, ang = EyePos(), EyeAngles()
    local maskwep = weapons.GetStored("weapon_gasmask")
    local camFOV = GASMASK_CalcHorizontalFromVerticalFOV(maskwep.ViewModelFOV)
    local scrw, scrh = ScrW(), ScrH()
    local FT = FrameTime()
    cam.Start3D(pos, ang, camFOV, 0, 0, scrw, scrh, 1, 100)
    cam.IgnoreZ(false)
    render.SuppressEngineLighting(false)
    mask:SetPos(pos)
    mask:SetAngles(ang)
    mask:FrameAdvance(FT)
    mask:SetupBones()

    if ply:GetViewEntity() == ply then
        -- first draw hands, then mask
        if IsValid(hands) then
            hands:DrawModel()
        end

        mask:DrawModel()
    end

    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()
end

hook.Add("HUDPaint", "GASMASK_HUDPaintDrawing", function()
    GASMASK_DrawInHud()
end)

local maskbreathsounds = {
    [1] = "GASMASK_BreathingLoop",
    [2] = "GASMASK_BreathingLoop2",
    [3] = "GASMASK_BreathingMetroLight",
    [4] = "GASMASK_BreathingMetroMiddle",
    [5] = "GASMASK_BreathingMetroHard",
}

local function GASMASK_BreathThink()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local sndtype = GetConVar("g4p_gasmask_sndtype"):GetInt()
    local mask = ply.GASMASK_HudModel
    if not IsValid(mask) then return end

    if not ply.GASMASK_BreathSound and sndtype > 0 then
        ply.GASMASK_BreathSound = CreateSound(ply, maskbreathsounds[sndtype])
    end

    local shouldplay = mask:GetSequenceName(mask:GetSequence()) == "idle_on" and sndtype > 0
    local snd = ply.GASMASK_BreathSound

    if snd then
        snd:ChangePitch(snd:GetPitch() + 0.01) -- fix for stopsound
        snd:ChangePitch(math.Clamp(game.GetTimeScale() * 100, 75, 120))
        snd:ChangeVolume(shouldplay and 1 or 0, 0.5)

        if not snd:IsPlaying() and shouldplay then
            snd:Play()
        end
    end
end

hook.Add("Think", "GASMASK_BreathSoundThink", function()
    GASMASK_BreathThink()
end)

-- equipped gas mask model on face
hook.Add("PostDrawTranslucentRenderables", "GASMASK_ThirdPersonMaskThink", function()
    for _, ply in pairs(player.GetHumans()) do
        if not ply.GASMASK_FaceModel or not IsValid(ply.GASMASK_FaceModel) then
            ply.GASMASK_FaceModel = ClientsideModel("models/gmod4phun/w_contagion_gasmask_equipped.mdl", RENDERGROUP_BOTH)
            ply.GASMASK_FaceModel:SetNoDraw(true)
            ply.GASMASK_FaceModel:SetParent(ply)
            ply.GASMASK_FaceModel:AddEffects(EF_BONEMERGE)
        end

        local mask = ply.GASMASK_FaceModel
        if not IsValid(mask) then return end

        if ply:Alive() then
            mask:DrawModel()
        end
    end
end)

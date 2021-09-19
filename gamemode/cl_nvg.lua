local NV_Status = false
local NV_Vector = 0
local NV_TimeToVector = 0
local ISIBIntensity = 1
local reg = debug.getregistry()
local Length = reg.Vector.Length

CreateClientConVar("nv_toggspeed", 0.09, true, false)
CreateClientConVar("nv_illum_area", 512, true, false)
CreateClientConVar("nv_illum_bright", 1, true, false)
CreateClientConVar("nv_aim_status", 0, true, false)
CreateClientConVar("nv_aim_range", 200, true, false)

CreateClientConVar("nv_etisd_sensitivity_range", 200, true, false)
CreateClientConVar("nv_etisd_status", 0, true, false)

CreateClientConVar("nv_id_sens_darkness", 0.25, true, false)
CreateClientConVar("nv_id_status", 0, true, false)
CreateClientConVar("nv_id_reaction_time", 1, true, false)

CreateClientConVar("nv_isib_sensitivity", 5, true, false)
CreateClientConVar("nv_isib_status", 0, true, false)

CreateClientConVar("nv_fx_alphapass", 5, true, false)
CreateClientConVar("nv_fx_blur_status", 1, true, false)
CreateClientConVar("nv_fx_distort_status", 1, true, false)
CreateClientConVar("nv_fx_colormod_status", 1, true, false)
CreateClientConVar("nv_fx_blur_intensity", 1, true, false)
CreateClientConVar("nv_fx_goggle_overlay_status", 1, true, false)
CreateClientConVar("nv_fx_bloom_status", 0, true, false)
CreateClientConVar("nv_fx_goggle_status", 0, true, false)
CreateClientConVar("nv_fx_noise_status", 0, true, false)
CreateClientConVar("nv_fx_noise_variety", 20, true, false)
CreateClientConVar("nv_type", 1, true, false)
local IsBrighter = false
local IsMade = false
local ply, Brightness, IlluminationArea, ISIBSensitivity, dlight, trace, x, y, size, amt, BlurIntensity, GenInProgress
local tr = {}

local Color_Brightness		= 0.8
local Color_Contrast 		= 1.1
local Color_AddGreen		= -0.35
local Color_MultiplyGreen 	= 0.028

local C_B = -0.32

local Bloom_Darken = 0.75
local Bloom_Multiply = 1

local Color_Tab = 
{
	[ "$pp_colour_addr" ] 		= -1,
	[ "$pp_colour_addg" ] 		= Color_AddGreen,
	[ "$pp_colour_addb" ] 		= -1,
	[ "$pp_colour_brightness" ] = Color_Brightness,
	[ "$pp_colour_contrast" ]	= Color_Contrast,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= Color_MultiplyGreen,
	[ "$pp_colour_mulb" ] 		= 0
}

local Clr_FLIR = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = -0.65,
	[ "$pp_colour_contrast" ]	= 2.2,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

local Clr_FLIR_Ents = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0.6,
	[ "$pp_colour_contrast" ]	= 1,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

local CurScale = 0
local sndOn = Sound( "items/nvg/on.wav" )
local sndOff = Sound( "items/nvg/off.wav" )

local surface, math, render, util = surface, math, render, util

local BloomStrength = 0
local OverlayTexture = surface.GetTextureID("effects/nv_overlaytex.vmt")
local Grain = surface.GetTextureID("effects/grain.vmt")
local GrainMat = Material("effects/grain")
local Line = surface.GetTextureID("effects/nvline.vmt")
local LineMat = Material("effects/nvline")
local utrace, rcolor, rect, trect, text, CLR, rand = util.TraceLine, render.GetLightColor, surface.DrawRect, surface.DrawTexturedRect, surface.SetTexture, surface.SetDrawColor, math.random
local clr, CT, Output, w, h, FT, OldRT, FT
local AlphaPass = surface.GetTextureID("effects/nightvision.vmt")
local GrainTable = {}
local SetViewPort, Clear, SetRenderTarget, Start2D, End2D = render.SetViewPort, render.Clear, render.SetRenderTarget, cam.Start2D, cam.End2D

function NV_GenerateGrainTextures()
	CT = SysTime()
	GrainTable = {cur = 1, wait = 0}
	
	MsgN("NVScript: Generating grain textures...")
	
	OldRT = render.GetRenderTarget()
	w, h = ScrW(), ScrH()
	
	for i = 1, GetConVarNumber("nv_fx_noise_variety") do
		Output = GetRenderTarget("Grain" .. i, w / 4, h / 4, true)

		SetRenderTarget(Output)
		SetViewPort(0, 0, w / 4, h / 4)
		Clear(0, 0, 0, 0)

		Start2D()
			for i = 1, h / 4 do
				for i2 = 1, 40 do -- 40 grains per every Y pixel
					SetViewPort(rand(0, w / 4), i * 2, 1, 1)
					Clear(0, 0, 0, rand(100, 150))
				end
			end
		End2D()

		Output = GetRenderTarget("Grain" .. i, w / 4, h / 4, true)
		GrainTable[i] = Output
		GrainTable.last = i
	end
	
	SetViewPort(0, 0, w, h)
	SetRenderTarget(OldRT)
	
	MsgN("NVScript: Generation finished! Time taken: " .. math.Round(SysTime() - CT, 2) .. " second(s).")
end

function NV_GenerateLineTexture()
	CT = SysTime()
	
	MsgN("NVScript: Generating night-vision line texture...")
	
		OldRT = render.GetRenderTarget()
		w, h = ScrW(), ScrH()
		
		Output = GetRenderTarget("NVLine", w, h, true)

		SetRenderTarget(Output)
			Clear(0, 0, 0, 0)
			SetViewPort(0, 0, w, h)

			Start2D()
				for i = 1, h / 4 do
					SetViewPort(0, i * 4, w, 2)
					Clear(255, 255, 255, 200)
				end
			End2D()
			
			SetViewPort(0, 0, w, h)
		SetRenderTarget(OldRT)

		Output = GetRenderTarget("NVLine", w, h, true)
		LineMat:SetTexture("$basetexture", Output)
	
	MsgN("NVScript: Generation finished! Time taken: " .. math.Round(SysTime() - CT, 2) .. " second(s).")
end

local function NV_InitPostEntity()
	timer.Simple(2, function()
		NV_GenerateGrainTextures()
		NV_GenerateLineTexture()
	end)
end

hook.Add("InitPostEntity", "NV_InitPostEntity", NV_InitPostEntity)

local function NV_FX()
	ply = LocalPlayer()
	
	if ply:Alive() and NV_Status == true then
		w, h = ScrW(), ScrH()
		FT = FrameTime()
		
		CurScale = Lerp(FT * (30 * GetConVarNumber("nv_toggspeed")), CurScale, 1)
		
		if GetConVarNumber("nv_type") <= 1 then
			if GetConVarNumber("nv_fx_bloom_status") > 0 then
				Bloom_Multiply = Lerp(0.025, Bloom_Multiply, 3)
				Bloom_Darken = Lerp(0.1, Bloom_Darken, 0.75 - BloomStrength)
				
				DrawBloom(Bloom_Darken, Bloom_Multiply, 9, 9, 1, 1, 1, 1, 1)
			end
				
			CLR(255, 255, 255, 255)
			text(AlphaPass)
				
			for i = 1, GetConVarNumber("nv_fx_alphapass") do
				trect(0, 0, w, h)
			end
			
			text(Line)
			CLR(25, 50, 25, 255)
			trect(0, 0, w, h)
					
			if GetConVarNumber("nv_fx_noise_status") > 0 then
				GrainMat:SetTexture("$basetexture", GrainTable[GrainTable.cur])
				text(Grain)
				CLR(0, 0, 0, 255)
				trect(0, 0, w, h)
						
				CT = SysTime()
						
				if CT > GrainTable.wait then
					if GrainTable.cur == GrainTable.last then
						GrainTable.cur = 1
						GrainTable.wait = CT + FT * 2
					else
						GrainTable.cur = GrainTable.cur + 1
						GrainTable.wait = CT + FT * 2
					end
				end
			end
			
			if GetConVarNumber("nv_fx_distort_status") > 0 then
				DrawMaterialOverlay("models/shadertest/shader3.vmt", 0.0001)
			end
					
			if GetConVarNumber("nv_fx_goggle_status") > 0 then
				DrawMaterialOverlay("models/props_c17/fisheyelens.vmt", -0.03)
			end
			
			BlurIntensity = GetConVarNumber("nv_fx_blur_intensity")
					
			if GetConVarNumber("nv_fx_blur_status") > 0 then
				DrawMotionBlur(0.05 * BlurIntensity, 0.2 * BlurIntensity, 0.023 * BlurIntensity)
			end
			
			if GetConVarNumber("nv_fx_colormod_status") > 0 then
				Color_Tab[ "$pp_colour_brightness" ] = CurScale * Color_Brightness
				Color_Tab[ "$pp_colour_contrast" ] = CurScale * Color_Contrast
				
				DrawColorModify( Color_Tab )
			end
		else
			DrawColorModify(Clr_FLIR)
		end
	elseif not ply:Alive() then
		surface.PlaySound( sndOff )
		NV_Status = false
		hook.Remove("RenderScreenspaceEffects", "NV_FX")
		hook.Remove("PostDrawViewModel", "NV_PostDrawViewModel")
	end
end

local function NV_ToggleNightVision(ply)
	if not ply:Alive() then
		return
	end
	
	if NV_Status == true then
		NV_Status = false
		net.Start("NVGPutOff")
        net.SendToServer()
        if InventoryPanel and InventoryPanel:IsValid() then
            PlayerModel.Entity:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[2])
        end
		
		surface.PlaySound( sndOff )
		hook.Remove("RenderScreenspaceEffects", "NV_FX")
		hook.Remove("PostDrawViewModel", "NV_PostDrawViewModel")
    elseif NV_Status == false and ply:GetNWInt("NVG") > 1 then
		NV_Status = true
		net.Start("NVGPutOn")
        if InventoryPanel and InventoryPanel:IsValid() then
            PlayerModel.Entity:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].nvg_bodygroup[3])
        end
        net.SendToServer()
		CurScale = 0.2
		surface.PlaySound( sndOn )
		hook.Add("RenderScreenspaceEffects", "NV_FX", NV_FX)
		hook.Add("PostDrawViewModel", "NV_PostDrawViewModel", NV_PostDrawViewModel)
	end
end

concommand.Add("nvg_toggle", NV_ToggleNightVision)

local function NV_RegenerateGrainTextures(ply)
	if GenInProgress then
		return
	end
	
	notification.AddLegacy("NVScript: Grain texture generation starting in 2 seconds...", NOTIFY_GENERIC, 7)
	GenInProgress = true
	
	timer.Simple(2, function()
		NV_GenerateGrainTextures()
		notification.AddLegacy("NVScript: Grain texture generation finished. Check console for details.", NOTIFY_HINT, 7)
		GenInProgress = false
	end)
end

concommand.Add("nv_generate_noise_textures", NV_RegenerateGrainTextures)

hook.Add("PostDrawOpaqueRenderables", "FLIRFX", function()	
	if GetConVarNumber("nv_type") < 2 or not NV_Status then
		return
	end
	
	render.ClearStencil()
	render.SetStencilEnable(true)
			
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilReferenceValue(1)
			
	render.SuppressEngineLighting(true)
	
	FT = FrameTime()
	
	for _, ent in pairs(ents.GetAll()) do
		if ent:IsNPC() or ent:IsPlayer() then
			if not ent:IsEffectActive(EF_NODRAW) then -- since there is no proper way to check if the NPC is dead, we just check if the NPC has a nodraw effect on him
				render.SuppressEngineLighting(true)
				ent:DrawModel()
				render.SuppressEngineLighting(false)
			end
		elseif ent:GetClass() == "class C_ClientRagdoll" then
			if not ent.Int then
				ent.Int = 1
			else
				ent.Int = math.Clamp(ent.Int - FT * 0.015, 0, 1)
			end
			
			render.SetColorModulation(ent.Int, ent.Int, ent.Int)
				render.SuppressEngineLighting(true)
					ent:DrawModel()
				render.SuppressEngineLighting(false)
			render.SetColorModulation(1, 1, 1)
		end
	end
	
	render.SuppressEngineLighting(false)
	 
	render.SetStencilReferenceValue(2)
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue(1)
	DrawColorModify(Clr_FLIR_Ents)

	render.SetStencilEnable( false )
end)

local function NV_ResetEverything()

	-- Effects
	RunConsoleCommand("nv_fx_blur_status", "1")
	RunConsoleCommand("nv_fx_distort_status", "0")
	RunConsoleCommand("nv_fx_colormod_status", "1")
	RunConsoleCommand("nv_fx_goggle_overlay_status", "1")
	RunConsoleCommand("nv_fx_goggle_status", "0")
	RunConsoleCommand("nv_fx_noise_status", "1")
	RunConsoleCommand("nv_fx_noise_variety", "20")
	RunConsoleCommand("nv_fx_bloom_status", "0")
	RunConsoleCommand("nv_fx_blur_intensity", "1.0")
	RunConsoleCommand("nv_fx_alphapass", "5")
	
	-- Various features/etc
	RunConsoleCommand("nv_id_status", "0")
	RunConsoleCommand("nv_id_sens_darkness", "0.25")
	RunConsoleCommand("nv_id_reaction_time", "1")
	RunConsoleCommand("nv_etisd_status", "0")
	RunConsoleCommand("nv_etisd_sensitivity_range", "200")
	RunConsoleCommand("nv_isib_status", "0")
	RunConsoleCommand("nv_isib_sensitivity", "5")
	
	if NV_Status == true then
		surface.PlaySound( sndOff )
		NV_Status = false
	end
	
	hook.Remove("RenderScreenspaceEffects", "NV_FX")
	hook.Remove("PostDrawViewModel", "NV_PostDrawViewModel")
	hook.Remove("Think", "Think")
	RunConsoleCommand("nv_toggspeed", "0.2")
	RunConsoleCommand("nv_illum_area", "512")
	RunConsoleCommand("nv_illum_bright", "1")
	RunConsoleCommand("nv_aim_status", "1")
	RunConsoleCommand("nv_aim_range", "200")
	RunConsoleCommand("nv_type", "1")
	LocalPlayer():ChatPrint([[Everything has been reset to default:

-/ FX \-
Color mod - ON
Blur - ON
Blur Intensity - 1.0
Distort - OFF
Green Overlay - ON
Goggle Overlay - ON
Goggle Effect - OFF
Noise - ON
Noise texture variety - 20 textures
Bloom Effect - OFF
Alpha pass - 5 times

-/ Features \-
Illumination-Detection - OFF
Eye Trace Illumination-Sensitive Detection - OFF
Illumination-Smart Intensity Balancing - OFF
ID Darkness sensitivity - 0.25
ID Reaction Time - 1 second
ETISD sensitivity Range - 200
ISIB sensitivity - 5.00

-/ Miscellaneous \-
Illuminated Area - 512 units
Illumination Brightness - 100%
Toggle Speed -  20%
AIM - ON
AIM range - 200
Vision Type - Night Vision]])
end

concommand.Add("nv_reset_everything", NV_ResetEverything)

local trtone, Vec001 = {}, Vector(0, 0, -1)
local EP, EA, aim

local function NV_MonitorIllumination()
	ply = LocalPlayer()

	if ply:Alive() then
		EP, EA = ply:EyePos(), ply:EyeAngles():Forward()
		CT = CurTime()
		
		clr = Length((render.ComputeLighting(EP, Vec001) - render.ComputeDynamicLighting(EP, Vec001))) * 33
		
		if NV_Status then	
			Brightness = GetConVarNumber("nv_illum_bright")
			IlluminationArea = GetConVarNumber("nv_illum_area")
			ISIBSensitivity = GetConVarNumber("nv_isib_sensitivity")		
			dlight = DynamicLight(ply:EntIndex())
			
			if dlight then
				FT = FrameTime()
				aim = GetConVarNumber("nv_aim_status")
				
				if aim > 0 then
					tr.start = EP
					tr.endpos = tr.start + EA * GetConVarNumber("nv_aim_range")
					tr.filter = ply
					
					trace = utrace(tr)

					if not trace.Hit then
						if CT > NV_TimeToVector then
							NV_Vector = math.Clamp(NV_Vector + 1, 0, 20)
							NV_TimeToVector = CT + 0.005
						end
						
						dlight.Pos = trace.HitPos + Vector(0, 0, NV_Vector)
					else
					
						if CT > NV_TimeToVector then
							NV_Vector = math.Clamp(NV_Vector - 1, 0, 20)
							NV_TimeToVector = CT + 0.005
						end
						
						dlight.Pos = trace.HitPos + Vector(0, 0, NV_Vector)
					end
					
				else
					dlight.Pos = ply:GetShootPos()
				end
				
				dlight.r = 125 * Brightness
				dlight.g = 255 * Brightness
				dlight.b = 125 * Brightness
				dlight.Brightness = 1
				
				if GetConVarNumber("nv_isib_status") < 1 then
					dlight.Size = IlluminationArea * CurScale
					dlight.Decay = IlluminationArea * CurScale
				else
					if aim > 0 then
						clr = Length((render.ComputeLighting(trace.HitPos, Vec001) - render.ComputeDynamicLighting(trace.HitPos, Vec001))) * 33
						ISIBIntensity = Lerp(FT * 10, ISIBIntensity, clr * ISIBSensitivity)
					else
						ISIBIntensity = Lerp(FT * 10, ISIBIntensity, clr * ISIBSensitivity)
					end
					
					dlight.Size = math.Clamp((IlluminationArea * CurScale) / ISIBIntensity, 0, IlluminationArea)
					dlight.Decay = math.Clamp((IlluminationArea * CurScale) / ISIBIntensity, 0, IlluminationArea)
				end
				
				dlight.DieTime = CT + FT * 3
			end
		end
	
		if GetConVarNumber("nv_id_status") > 0 then
			if not IsBrighter then
			
				if clr < GetConVarNumber("nv_id_sens_darkness") then
					if not IsMade then
						timer.Create("MonitorIllumTimer", GetConVarNumber("nv_id_reaction_time"), 1, function()
								if clr < GetConVarNumber("nv_id_sens_darkness") then
									if not NV_Status then
										RunConsoleCommand("nvg_toggle")
									end
								else
									if NV_Status then
										RunConsoleCommand("nvg_toggle")
									end
								end
								
							IsMade = false
						end)
						
						IsMade = true
					end
				else
					timer.Start("MonitorIllumMeter")
				end
			end
			
			if GetConVarNumber("nv_etisd_status") > 0 then
				tr.start = EP
				tr.endpos = tr.start + EA * GetConVarNumber("nv_etisd_sensitivity_range")
				tr.filter = ply
				trace = utrace(tr)
				
				clr = Length((render.ComputeLighting(trace.HitPos, Vec001) - render.ComputeDynamicLighting(trace.HitPos, Vec001))) * 33
				if clr > GetConVarNumber("nv_id_sens_darkness") then -- If we're looking from darkness into somewhere bright
					if not IsBrighter then
						if NV_Status then
							RunConsoleCommand("nvg_toggle") -- turn off our night vision
						end
						
						IsBrighter = true
						timer.Stop("MonitorIllumTimer")
					else
						timer.Start("MonitorIllumTimer")
					end
				else
					IsBrighter = false
				end
			end
		end
	end
end

hook.Add("Think", "NV_MonitorIllumination", NV_MonitorIllumination)

local function NV_HUDPaint()
	ply = LocalPlayer()
	
	if ply:Alive() then
		if NV_Status then
			if GetConVarNumber("nv_fx_goggle_overlay_status") > 0 then
				CLR(255, 255, 255, 255)
				text(OverlayTexture)
				trect(0, 0, ScrW(), ScrH())
			end
		end
	end
end

hook.Add("HUDPaint", "NV_HUDPaint", NV_HUDPaint)
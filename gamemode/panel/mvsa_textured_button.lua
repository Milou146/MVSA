local PANEL = {}

function PANEL:Init()
end

function PANEL:Paint( w, h )
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetTexture(surface.GetTextureID(PANEL.texture))
    surface.DrawTexturedRect(PANEL.xpos, PANEL.ypos, PANEL.width, PANEL.height)
end

function PANEL:OnMouseReleased(keyCode)
    if keyCode == 107 then
        PANEL:DoClick()
    end
end

vgui.Register( "MVSATexturedButton", PANEL, "Panel" )
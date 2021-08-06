local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color(77,77,77, 240) )
    surface.SetDrawColor( 0, 0, 0, 255)
    surface.DrawRect( 0, 0, ScrW(), ScrH() / 10 )
end

vgui.Register( "MVSAPanel", PANEL, "EditablePanel" )
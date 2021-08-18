concommand.Add( "cl_mvsa_set_gasmask", function( ply, cmd, args )
    if InventoryPanel ~= nil then
        if args[1] == "1" then
            UpdateClientMask(true)
        elseif args[1] == "0" then
            UpdateClientMask(false)
        end
    end
end)
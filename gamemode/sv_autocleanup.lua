CleanupDelay = 0
local StartingIndex = 0

function AutoCleanup()
    if CurTime() > CleanupDelay then
        CleanupDelay = CurTime() + 500
        local TempTable = ents.GetAll()
        if StartingIndex == 0 then
            StartingIndex = #TempTable
        end
        for k = StartingIndex, #TempTable do
            TempTable[k]:RemoveAllDecals()
            if TempTable[k]:IsRagdoll() then
                TempTable[k]:Remove()
            end
        end
    end
end
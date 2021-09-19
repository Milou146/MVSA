local SpawnDelay = 0
local MinSpawnDistance = 3000
local MaxSpawnDistance = 20000
LootCount = 0
local LootLimit = 30

function LootSpawnSystem()
    if SpawnDelay < CurTime() and LootCount < LootLimit then
        SpawnDelay = CurTime() + 20
        for k, v in pairs( player.GetAll() ) do
            local PlayerPos = v:GetPos()
            for i, j in pairs( ents.FindByClass( "info_loot_spawn" ) ) do
                if not j.ent or not j.ent:IsValid() then
                    local EntPos = j:GetPos()
                    local distance = PlayerPos:Distance( EntPos )
                    if distance > MinSpawnDistance and distance < MaxSpawnDistance then
                        j.ent = ents.Create( table.Random(LootList) )
                        j.ent:SetPos(EntPos)
                        j.ent:Spawn()
                    end
                end
            end
        end
    end
end
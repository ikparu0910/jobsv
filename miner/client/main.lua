MP = {}
MP.__index = MP

local cy = coroutine.yield
local firstSpawn = false
local blip3, blip4, blip5



Citizen.CreateThread(function()
    MP:Init()

    loadModel("csb_trafficwarden")
    local pedhash = GetHashKey("csb_trafficwarden")


    loadModel("csb_trafficwarden")
    local pedhash2 = GetHashKey("csb_trafficwarden")

    if firstSpawn == false then
        local pedClaimPos = Config.ClaimJob.Pos
        local npc = CreatePed(6, pedhash, pedClaimPos.x,  pedClaimPos.y,  pedClaimPos.z- 0.99, Config.pedHeading, false, false)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetPedDiesWhenInjured(npc, false)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanRagdoll(npc, false)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityDynamic(npc, true)

        local pedSellPos = Config.SellMetal.Pos
        local npc1 = CreatePed(6, pedhash2, pedSellPos.x, pedSellPos.y, pedSellPos.z - 0.99, Config.sellpedHeading, false, false)
        SetEntityInvincible(npc1, true)
        FreezeEntityPosition(npc1, true)
        SetPedDiesWhenInjured(npc1, false)
        SetPedCanRagdollFromPlayerImpact(npc1, false)
        SetPedCanRagdoll(npc1, false)
        SetEntityAsMissionEntity(npc1, true, true)
        SetEntityDynamic(npc1, true)
    end

end)

function MP:Init()
    local o = {}
    setmetatable(o, MP)
    o.PlayerData = {}
    o.Ped = PlayerPedId()
    o.PlyerId = PlayerId()
    o.ServerId = GetPlayerServerId()
    o.InJob = false
    o.hasBlip = false
    o.PlayerProps = {}
    o.PlayerHasProp = false
    o:BlipThread()
    o:ClaimJobThread()
    o:MineThread()
    o:WashThread()
    o:SmeltThread()
    o:SellThread()
    return o
end

function MP:BlipThread()
    Citizen.CreateThread(function()
            
            local zoneClaimJob = Config.ClaimJob
            local blip1 = AddBlipForCoord(zoneClaimJob.Pos)
            SetBlipSprite(blip1, zoneClaimJob.Sprite)
            SetBlipDisplay              (blip1, 2)
            SetBlipScale                (blip1, zoneClaimJob.Scale )
            SetBlipColour               (blip1, zoneClaimJob.Colour)
            SetBlipAsShortRange         (blip1, true)
            SetBlipHighDetail           (blip1, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_claimjob'))
            EndTextCommandSetBlipName   (blip1)

            local zoneSellMetal = Config.SellMetal
                local blip2 = AddBlipForCoord(zoneSellMetal.Pos)
                SetBlipSprite(blip2, zoneSellMetal.Sprite)
                SetBlipDisplay              (blip2, 2)
                SetBlipScale                (blip2, zoneSellMetal.Scale )
                SetBlipColour               (blip2, zoneSellMetal.Colour)
                SetBlipAsShortRange         (blip2, true)
                SetBlipHighDetail           (blip2, true)
                BeginTextCommandSetBlipName ("STRING")
                AddTextComponentString      (TranslateCap('blip_sellmetal'))
                EndTextCommandSetBlipName   (blip2)
    end)
end

function MP:ClaimJobThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            local claimJobPos = Config.ClaimJob.Pos
            local x, y, z = claimJobPos.x, claimJobPos.y, claimJobPos.z
            local zone = Config.ZoneMiner
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            local distance2 = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
            if distance2 <= 2.0 then 
                if distance2 <= 1 then
                    ESX.ShowHelpNotification(TranslateCap('press_open_menu'))
                    if IsControlJustPressed(0, 38) then
                        self:OpenMenuClaimJob()
                    end
                end
            else
                Wait(1500)
            end
        end
    end)
end

function MP:SellThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            local sellPos = Config.SellMetal.Pos
            local x, y, z = sellPos.x, sellPos.y, sellPos.z
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            local distance2 = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
            if distance2 <= 3.0 then 
                if distance2 <= 1 then
                    ESX.ShowHelpNotification(TranslateCap('press_open_menu'))
                    if IsControlJustPressed(0, 38) then
                        OpenMenuSell()
                    end
                end
            else
                Wait(1500)
            end
            
        end
    end)
end



function MP:AddBlipJob()
    Citizen.CreateThread(function()
        if not self.hasBlip  then
            self.hasBlip = true
            if self.InJob then
                local zoneMinePoint = Config.MinePoint
                blip3 = AddBlipForCoord(zoneMinePoint.Pos)
                    SetBlipSprite(blip3, zoneMinePoint.Sprite)
                    SetBlipDisplay              (blip3, 2)
                    SetBlipScale                (blip3, zoneMinePoint.Scale )
                    SetBlipColour               (blip3, zoneMinePoint.Colour)
                    SetBlipAsShortRange         (blip3, true)
                    SetBlipHighDetail           (blip3, true)
                    BeginTextCommandSetBlipName ("STRING")
                    AddTextComponentString      (TranslateCap('blip_minepoint'))
                    EndTextCommandSetBlipName   (blip3)
                
                local zoneWashStone = Config.WashStone
                blip4 = AddBlipForCoord(zoneWashStone.Pos)
                    SetBlipSprite(blip4, zoneWashStone.Sprite)
                    SetBlipDisplay              (blip4, 2)
                    SetBlipScale                (blip4, zoneWashStone.Scale )
                    SetBlipColour               (blip4, zoneWashStone.Colour)
                    SetBlipAsShortRange         (blip4, true)
                    SetBlipHighDetail           (blip4, true)
                    BeginTextCommandSetBlipName ("STRING")
                    AddTextComponentString      (TranslateCap('blip_washstone'))
                    EndTextCommandSetBlipName   (blip4)
                
                local zoneSmeltOre = Config.SmeltOre
                blip5 = AddBlipForCoord(zoneSmeltOre.Pos)
                    SetBlipSprite(blip5, zoneSmeltOre.Sprite)
                    SetBlipDisplay              (blip5, 2)
                    SetBlipScale                (blip5, zoneSmeltOre.Scale )
                    SetBlipColour               (blip5, zoneSmeltOre.Colour)
                    SetBlipAsShortRange         (blip5, true)
                    SetBlipHighDetail           (blip5, true)
                    BeginTextCommandSetBlipName ("STRING")
                    AddTextComponentString      (TranslateCap('blip_smeltore'))
                    EndTextCommandSetBlipName   (blip5)
            end
        end
    end)
end

function MP:MineThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.MineLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.MineLocations[i].x, Config.MineLocations[i].y, Config.MineLocations[i].z, true) < 25 and self.InJob == false then
                        DrawMarker(20, Config.MineLocations[i].x, Config.MineLocations[i].y, Config.MineLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.MineLocations[i].x, Config.MineLocations[i].y, Config.MineLocations[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_mine"))
                                if IsControlJustReleased(1, 51) then
                                    local PropName = "prop_tool_pickaxe"
                                    local PropBone = 28422
                                    local PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(Config.PropMapPlacement)
                                    self:AddPropToPlayer( PropName , PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "mp_miner",
                                        duration = Config.mineDuration,
                                        label = "Đang đào quặng",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "melee@large_wpn@streamed_core",
                                            anim = "ground_attack_on_spot",
                                        },
                                    }, function(status)
                                        if not status then
                                            print("aaaa")
                                            TriggerServerEvent("miner:mine")
                                            self:DestroyAllProps()

                                        else
                                            self:DestroyAllProps()
                                            self.isBusy = false
                                        end
                                        p:resolve(status)
                                    end)
                                    Citizen.Await(p)
                                end
                    end
                end
            end
        end
    end)
end

function MP:WashThread()
    Citizen.CreateThread(function ()
        while true do 
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.WashLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.WashLocations[i].x, Config.WashLocations[i].y, Config.WashLocations[i].z, true) < 25 and self.InJob == true then
                        DrawMarker(20, Config.WashLocations[i].x, Config.WashLocations[i].y, Config.WashLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.WashLocations[i].x, Config.WashLocations[i].y, Config.WashLocations[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_wash"))
                                if IsControlJustReleased(1, 51) then
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "miner",
                                        duration = Config.washDuration,
                                        label = "Đang rửa đá",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "amb@prop_human_bum_bin@idle_a",
                                            anim = "idle_a",
                                        },
                                    }, function(status)
                                        if not status then
                                            TriggerServerEvent("miner:wash", Config.TradeWash)
                                        else
                                            self.isBusy = false
                                        end
                                        p:resolve(status)
                                    end)
                                    Citizen.Await(p)
                                end
                        end
                end
            end
        end
    end)
end   

function MP:SmeltThread()
    Citizen.CreateThread(function()
        while true do 
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            local smeltPos = Config.SmeltOre.Pos
            local x, y, z = smeltPos.x, smeltPos.y, smeltPos.z
            distance = GetDistanceBetweenCoords(pedCoords, x, y, z)
            if distance < 30 and self.InJob == true then
                if distance < 20 then
                DrawMarker(20, x, y, z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                    if distance <= 1 then
                        ESX.ShowHelpNotification(TranslateCap("action_smelt"))
                        if IsControlJustReleased(1, 51) then
                            self.isBusy = true
                            local p = promise.new()
                            ClearPedTasksImmediately(GetPlayerPed( -1))
                            ResetPedMovementClipset(PlayerPedId())
                            TriggerEvent("mythic_progbar:client:progress", {
                                name = "miner",
                                duration = Config.smeltDuration,
                                label = "Đang nung đá",
                                useWhileDead = false,
                                canCancel = true,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                },
                                animation = {
                                    animDict = "amb@prop_human_bum_bin@idle_a",
                                    anim = "idle_a",
                                },
                                }, function(status)
                                    if not status then
                                        local rd = math.random(0, 100)
                                        if rd <= Config.LEGEND.percent then
                                            
                                            TriggerServerEvent("miner:smelt", Config.TradeSmelt, Config.LEGEND.item)
                                        elseif rd > Config.LEGEND.percent and  rd <= Config.EPIC.percent  then
                                            
                                            TriggerServerEvent("miner:smelt", Config.TradeSmelt, Config.EPIC.item)
                                        elseif rd > Config.EPIC.percent and rd <= Config.RARE.percent then
                                            
                                            TriggerServerEvent("miner:smelt", Config.TradeSmelt, Config.RARE.item)
                                        elseif rd > Config.RARE.percent then
                                            
                                            TriggerServerEvent("miner:smelt", Config.TradeSmelt, Config.UNCOMMON.item)
                                        end
                                        -- TriggerServerEvent("miner:wash", Config.TradeWash)
                                    else
                                        self.isBusy = false
                                    end
                                    p:resolve(status)
                                end)
                            Citizen.Await(p)
                        end
                    end
                end
            else
                Wait(2000)
            end
        end
    end)
end

function MP:OpenMenuClaimJob()
    local elements = {
        {unselectable = true, icon = "fas fa-gem", title = TranslateCap("menu_claim")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-check",
		title = TranslateCap("accept"),
		value = "claimjob",
		type = "claimjob"
    }

    elements[#elements + 1] = {
        icon = "fas fa-window-close",
		title = TranslateCap("cancel"),
		value = "canceljob",
		type = "canceljob"
    }

    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "claimjob" then
            self.InJob = true
            self:AddBlipJob()
            ESX.CloseContext()
        elseif elements.value == "canceljob" then
            ESX.CloseContext()
            self.InJob = false
            RemoveBlip(blip3)
            RemoveBlip(blip4)
            RemoveBlip(blip5)
        end

    end)
end

function OpenMenuSell()
    local elements = {
        {unselectable = true, icon = "fas fa-gem", title = TranslateCap("menu_sell")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_diamond"),
		value = "sell_diamond",
		type = "sell_diamond"
    }

    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_gold"),
		value = "sell_gold",
		type = "sell_gold"
    }

    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_iron"),
		value = "sell_iron",
		type = "sell_iron"
    }

    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_copper"),
		value = "sell_copper",
		type = "sell_copper"
    }

    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "sell_diamond" then
            TriggerServerEvent("miner:sell", Config.LEGEND.item, Config.LEGEND.price)
        elseif elements.value == "sell_gold" then
            TriggerServerEvent("miner:sell", Config.EPIC.item, Config.EPIC.price)
        elseif elements.value == "sell_iron" then
            TriggerServerEvent("miner:sell", Config.RARE.item, Config.RARE.price)
        elseif elements.value == "sell_copper" then
            TriggerServerEvent("miner:sell", Config.UNCOMMON.item, Config.UNCOMMON.price)
        end

    end)
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function MP:DestroyAllProps()
    for _, v in ipairs(self.PlayerProps) do
        DeleteEntity(v)
    end
    self.PlayerHasProp = false
end

function MP:AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(Player))
  
    if not HasModelLoaded(prop1) then
      LoadPropDict(prop1)
    end
  
    prop = CreateObject(  GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(  prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(self.PlayerProps, prop)
    self.PlayerHasProp = true
    SetModelAsNoLongerNeeded(prop1)
    
end


function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

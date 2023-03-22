MP = {}
MP.__index = MP

local cy = coroutine.yield
local firstSpawn = false
local blip2, blip3, blip4
local spawnedChikens = 0
local objChickens = {}


Citizen.CreateThread(function()
    MP:Init()

    loadModel("s_m_y_chef_01")
    local pedhash = GetHashKey("s_m_y_chef_01")


    loadModel("a_m_m_hasjew_01")
    local pedhash2 = GetHashKey("a_m_m_hasjew_01")

    loadModel("a_c_hen")


    if firstSpawn == false then
        local pedClaimPos = Config.ClaimJob.Pos
        local npc = CreatePed(6, pedhash, pedClaimPos.x,  pedClaimPos.y,  pedClaimPos.z- 0.99, Config.ClaimJob.pedHeading, false, false)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetPedDiesWhenInjured(npc, false)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanRagdoll(npc, false)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityDynamic(npc, true)

        local pedSellPos = Config.SellPackingChicken.Pos
        local npc1 = CreatePed(6, pedhash2, pedSellPos.x,  pedSellPos.y,  pedSellPos.z- 0.99, Config.SellPackingChicken.pedHeading, false, false)
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
    o.isBusy =false
    o:BlipThread()
    o:ClaimJobThread()
    o:SpawnChickens()
    o:CatchChicken()
    o:ChoppingChicken()
    o:ChickenPacking()
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
    end)
end

function MP:SellThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            local sellPos = Config.SellPackingChicken.Pos
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
        if self.InJob then
            ESX.ShowNotification(TranslateCap('claimJob_success'))
            local zoneHenhouse = Config.Henhouse
            blip2 = AddBlipForCoord(zoneHenhouse.Pos)
            SetBlipSprite(blip2, zoneHenhouse.Sprite)
            SetBlipDisplay              (blip2, 2)
            SetBlipScale                (blip2, zoneHenhouse.Scale )
            SetBlipColour               (blip2, zoneHenhouse.Colour)
            SetBlipAsShortRange         (blip2, true)
            SetBlipHighDetail           (blip2, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_henhouse'))
            EndTextCommandSetBlipName   (blip2)

            local zoneChoppingChicken = Config.ChoppingChicken
            blip3 = AddBlipForCoord(zoneChoppingChicken.Pos)
            SetBlipSprite(blip3, zoneChoppingChicken.Sprite)
            SetBlipDisplay              (blip3, 2)
            SetBlipScale                (blip3, zoneChoppingChicken.Scale )
            SetBlipColour               (blip3, zoneChoppingChicken.Colour)
            SetBlipAsShortRange         (blip3, true)
            SetBlipHighDetail           (blip3, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_chopping'))
            EndTextCommandSetBlipName   (blip3)

            local zoneChickenPacking = Config.ChickenPacking
            blip4 = AddBlipForCoord(zoneChickenPacking.Pos)
            SetBlipSprite(blip4, zoneChickenPacking.Sprite)
            SetBlipDisplay              (blip4, 2)
            SetBlipScale                (blip4, zoneChickenPacking.Scale )
            SetBlipColour               (blip4, zoneChickenPacking.Colour)
            SetBlipAsShortRange         (blip4, true)
            SetBlipHighDetail           (blip4, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_packing'))
            EndTextCommandSetBlipName   (blip4)
        end
    end)
end


function MP:ClaimJobThread()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            local claimJobPos = Config.ClaimJob.Pos
            local x, y, z = claimJobPos.x, claimJobPos.y, claimJobPos.z
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

function MP:CatchChicken()
    Citizen.CreateThread(function()
        while true do
            cy(3)
            local nearbyObject, nearbyID
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1, #objChickens, 1 do
                local ObjectCoords = GetEntityCoords(objChickens[i])
                if GetDistanceBetweenCoords(pedCoords, GetEntityCoords(objChickens[i]), false) < 1 then
                    DrawMarker(20, ObjectCoords.x, ObjectCoords.y, ObjectCoords.z +1.0,0, 0, 0, 0, 0, 100.0, 0.5, 0.5, 0.5, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                    nearbyObject, nearbyID = objChickens[i], i
                end
            end
            if nearbyObject and IsPedOnFoot(self.ped) and self.InJob == true then
                if not self.isBusy then
                    ESX.ShowHelpNotification(TranslateCap("action_catch"))
                end
                if IsControlJustReleased(1, 51) and not self.isBusy then
                    self.isBusy = true
                    local p = promise.new()
                    ClearPedTasksImmediately(GetPlayerPed( -1))
                    ResetPedMovementClipset(PlayerPedId())
                    TaskStartScenarioInPlace(self.ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, false)
                    TriggerEvent("mythic_progbar:client:progress", {
                        name = "pickupCottons",
                        duration = Config.Duration.catch_chicken,
                        label = "Đang bắt gà",
                        useWhileDead = false,
                        canCancel = true,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }
                    }, function(status)
                        ClearPedTasksImmediately(self.ped)
                        if not status then
                            print("catch_chicken")
                            DeletePed(nearbyObject)
                            table.remove(objChickens, nearbyID)
							spawnedChikens = spawnedChikens - 1
                            self.isBusy = false
                        else
                            self.isBusy = false
                        end
                        p:resolve(status)
                    end)
                    Citizen.Await(p)
                end
            else
                Wait(1000)
            end
        end
    end)
end

function MP:ChoppingChicken()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.ChoppingChickenLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.ChoppingChickenLocations[i].x, Config.ChoppingChickenLocations[i].y, Config.ChoppingChickenLocations[i].z, true) < 15 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.ChoppingChickenLocations[i].x, Config.ChoppingChickenLocations[i].y, Config.ChoppingChickenLocations[i].z, true) <= 7 then
                        DrawMarker(20, Config.ChoppingChickenLocations[i].x, Config.ChoppingChickenLocations[i].y, Config.ChoppingChickenLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.ChoppingChickenLocations[i].x, Config.ChoppingChickenLocations[i].y, Config.ChoppingChickenLocations[i].z, true) <= 1 then
                            
                            ESX.ShowHelpNotification(TranslateCap("action_chopping"))
                                if IsControlJustPressed(1, 51) then
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "choppingChicken",
                                        duration = Config.Duration.chopping_chicken,
                                        label = "Đang chặt gà",
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
                                            print("chopping_chicken")
                                            self.isBusy = false
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
        end
    end)
end

function MP:ChickenPacking()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.ChickenPackingLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.ChickenPackingLocations[i].x, Config.ChickenPackingLocations[i].y, Config.ChickenPackingLocations[i].z, true) < 15 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.ChickenPackingLocations[i].x, Config.ChickenPackingLocations[i].y, Config.ChickenPackingLocations[i].z, true) <= 7 then
                        DrawMarker(20, Config.ChickenPackingLocations[i].x, Config.ChickenPackingLocations[i].y, Config.ChickenPackingLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.ChickenPackingLocations[i].x, Config.ChickenPackingLocations[i].y, Config.ChickenPackingLocations[i].z, true) <= 1 then
                            
                            ESX.ShowHelpNotification(TranslateCap("action_packing"))
                                if IsControlJustPressed(1, 51) then
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "packingChicken",
                                        duration = Config.Duration.chopping_chicken,
                                        label = "Đang đóng gói gà",
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
                                            print("packing_chicken")
                                            self.isBusy = false
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
        end
    end)
end
function MP:SpawnChickens()
    Citizen.CreateThread(function()
        while true do
            cy(500)
            if self.InJob == false then
                local henHousePos = Config.Henhouse.Pos
                local x, y, z = henHousePos.x, henHousePos.y, henHousePos.z
                self.ped = PlayerPedId()
                local pedCoords = GetEntityCoords(self.ped)
                local distance = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
                if distance <= 50 then
                    SpawnObjChicken()
                else
                    Wait(1000)
                end
            end
        end
    end)
end

function SpawnObjChicken()
	while spawnedChikens < 15 do
		Citizen.Wait(0)
        
		local chickenCoords = GenerateChickenCoords()
        loadModel("a_c_hen")
        local chickenHash = GetHashKey("a_c_hen")
		while not HasModelLoaded(chickenHash) do
            Citizen.Wait(1)
        end
        local obj = CreatePed(28, chickenHash, chickenCoords, 10.0, false, true)
        table.insert(objChickens, obj)
        spawnedChikens = spawnedChikens + 1 

	end
end

function GenerateChickenCoords()
	while true do
		Citizen.Wait(1)

		local chickenCoordX, chickenCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-20, 20)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		chickenCoordX = Config.Henhouse.Pos.x + modX
		chickenCoordY = Config.Henhouse.Pos.y + modY

		local coordZ = 42
		local coord = vector3(chickenCoordX, chickenCoordY, coordZ)

		if ValidateCottonCoord(coord) then
			return coord
		end
	end
end

function ValidateCottonCoord(chickenCoord)
	if spawnedChikens > 0 then
		local validate = true

		for k, v in pairs(objChickens) do
			if GetDistanceBetweenCoords(chickenCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(chickenCoord, Config.Henhouse.Pos, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end




function MP:OpenMenuClaimJob()
    local elements = {
        {unselectable = true, icon = "fas fa-egg", title = TranslateCap("menu_claim")}
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
            RemoveBlip(blip2)
            RemoveBlip(blip3)
            RemoveBlip(blip4)
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

function OpenMenuSell()
    local elements = {
        {unselectable = true, icon = "fas fa-egg", title = TranslateCap("menu_sell")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_packing_chicken"),
		value = "sell_packing_chicken",
		type = "sell_packing_chicken"
    }



    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "sell_packing_chicken" then
            print("sell_packing_chicken")     
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(objChickens) do
			DeletePed(v)
            objChickens = {}
            spawnedChikens = 0
		end
	end
end)

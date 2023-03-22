MP = {}
MP.__index = MP

local cy = coroutine.yield
local firstSpawn = false
local blip2, blip3, blip4
local spawnedCottons = 0
local cottonPlants = {}
local isPickingUp = false

Citizen.CreateThread(function()
    MP:Init()

    loadModel("cs_molly")
    local pedhash = GetHashKey("cs_molly")


    loadModel("s_m_y_casino_01")
    local pedhash2 = GetHashKey("s_m_y_casino_01")

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

        local pedSellPos = Config.SellClothes.Pos
        local npc1 = CreatePed(6, pedhash2, pedSellPos.x, pedSellPos.y, pedSellPos.z - 0.99, Config.SellClothes.pedHeading, false, false)
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
    o:BlipThread()
    o:ClaimJobThread()
    o:SpawnPlants()
    o:PickCottons()
    o:SpinningCottons()
    o:SewThread()
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

function MP:AddBlipJob()
    Citizen.CreateThread(function()
        if self.InJob then
            ESX.ShowNotification(TranslateCap('claimJob_success'))
            local zoneCottonField = Config.CottonFields
            blip3 = AddBlipForCoord(zoneCottonField.Pos)
            SetBlipSprite(blip3, zoneCottonField.Sprite)
            SetBlipDisplay              (blip3, 2)
            SetBlipScale                (blip3, zoneCottonField.Scale )
            SetBlipColour               (blip3, zoneCottonField.Colour)
            SetBlipAsShortRange         (blip3, true)
            SetBlipHighDetail           (blip3, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_cottonfield'))
            EndTextCommandSetBlipName   (blip3)

            local zoneSpinningCotton = Config.SpinningLocation
            blip4 = AddBlipForCoord(zoneSpinningCotton.Pos)
            SetBlipSprite(blip4, zoneSpinningCotton.Sprite)
            SetBlipDisplay              (blip4, 2)
            SetBlipScale                (blip4, zoneSpinningCotton.Scale )
            SetBlipColour               (blip4, zoneSpinningCotton.Colour)
            SetBlipAsShortRange         (blip4, true)
            SetBlipHighDetail           (blip4, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_spinning'))
            EndTextCommandSetBlipName   (blip4)

            local zoneSew = Config.SewLocation
            blip5 = AddBlipForCoord(zoneSew.Pos)
            SetBlipSprite(blip5, zoneSew.Sprite)
            SetBlipDisplay              (blip5, 2)
            SetBlipScale                (blip5, zoneSew.Scale )
            SetBlipColour               (blip5, zoneSew.Colour)
            SetBlipAsShortRange         (blip5, true)
            SetBlipHighDetail           (blip5, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_sew'))
            EndTextCommandSetBlipName   (blip5)
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

function MP:SellThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            local sellPos = Config.SellClothes.Pos
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

function MP:PickCottons()
    Citizen.CreateThread(function()
        while true do
            cy(3)
            local nearbyObject, nearbyID
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1, #cottonPlants, 1 do
                local ObjectCoords = GetEntityCoords(cottonPlants[i])
                if GetDistanceBetweenCoords(pedCoords, GetEntityCoords(cottonPlants[i]), false) < 1 then
                    DrawMarker(20, ObjectCoords.x, ObjectCoords.y, ObjectCoords.z + 2.0,0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                    nearbyObject, nearbyID = cottonPlants[i], i
                end
            end
            if nearbyObject and IsPedOnFoot(self.ped) and self.InJob then
                if not self.isBusy then
                    ESX.ShowHelpNotification(TranslateCap("action_pickup"))
                end
                if IsControlJustReleased(1, 51) and not self.isBusy then
                    self.isBusy = true
                    local p = promise.new()
                    ClearPedTasksImmediately(GetPlayerPed( -1))
                    ResetPedMovementClipset(PlayerPedId())
                    TaskStartScenarioInPlace(self.ped, 'world_human_gardener_plant', 0, false)
                    TriggerEvent("mythic_progbar:client:progress", {
                        name = "pickupCottons",
                        duration = Config.pickupDuration,
                        label = "Đang hái bông",
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
                            print("pickup_cotton")
                            ESX.Game.DeleteObject(nearbyObject)
                            table.remove(cottonPlants, nearbyID)
							spawnedCottons = spawnedCottons - 1
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



function MP:SpinningCottons()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.spinningCottonLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.spinningCottonLocations[i].x, Config.spinningCottonLocations[i].y, Config.spinningCottonLocations[i].z, true) < 15 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.spinningCottonLocations[i].x, Config.spinningCottonLocations[i].y, Config.spinningCottonLocations[i].z, true) <= 7 then
                        DrawMarker(20, Config.spinningCottonLocations[i].x, Config.spinningCottonLocations[i].y, Config.spinningCottonLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.spinningCottonLocations[i].x, Config.spinningCottonLocations[i].y, Config.spinningCottonLocations[i].z, true) <= 1 then
                            
                            ESX.ShowHelpNotification(TranslateCap("action_spinning"))
                                if IsControlJustPressed(1, 51) then
                                    print("123123")
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "spinningCotton",
                                        duration = Config.spinningDuration,
                                        label = "Đang kéo sợi",
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
                                            print("spinning_cotton")
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

function MP:SewThread()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.sewLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.sewLocations[i].x, Config.sewLocations[i].y, Config.sewLocations[i].z, true) < 15 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.sewLocations[i].x, Config.sewLocations[i].y, Config.sewLocations[i].z, true) <= 7 then
                        DrawMarker(20, Config.sewLocations[i].x, Config.sewLocations[i].y, Config.sewLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.sewLocations[i].x, Config.sewLocations[i].y, Config.sewLocations[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_sew"))
                                if IsControlJustPressed(1, 51) then
                                    print("123123")
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "spinningCotton",
                                        duration = Config.sewDuration,
                                        label = "Đang may áo",
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
                                            print("sew")
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

function MP:SpawnPlants()
    Citizen.CreateThread(function()
        while true do
            cy(500)
            if self.InJob then
                local cottonFieldPos = Config.CottonFields.Pos
                local x, y, z = cottonFieldPos.x, cottonFieldPos.y, cottonFieldPos.z
                self.ped = PlayerPedId()
                local pedCoords = GetEntityCoords(self.ped)
                local distance = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
                if distance <= 50 then
                    SpawnCottonPlants()
                else
                    Wait(1000)
                end
            end
        end
    end)
end

function SpawnCottonPlants()
	while spawnedCottons < 30 do
		Citizen.Wait(1)
		local cottonCoords = GenerateCottonCoords()

		ESX.Game.SpawnLocalObject('prop_plant_int_01b', cottonCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(cottonPlants, obj)
			spawnedCottons = spawnedCottons + 1
		end)
	end
end

function GenerateCottonCoords()
	while true do
		Citizen.Wait(1)

		local weedCoordX, weedCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-20, 20)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		cottonCoordX = Config.CottonFields.Pos.x + modX
		cottonCoordY = Config.CottonFields.Pos.y + modY

		local coordZ = GetCoordZCotton(cottonCoordX, cottonCoordY)
		local coord = vector3(cottonCoordX, cottonCoordY, coordZ)

		if ValidateCottonCoord(coord) then
			return coord
		end
	end
end

function ValidateCottonCoord(plantCoord)
	if spawnedCottons > 0 then
		local validate = true

		for k, v in pairs(cottonPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CottonFields.Pos, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GetCoordZCotton(x, y)
	local groundCheckHeights = { 39.0, 40.0, 41.0}

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 40.38
end

function MP:OpenMenuClaimJob()
    local elements = {
        {unselectable = true, icon = "fas fa-tshirt", title = TranslateCap("menu_claim")}
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
        {unselectable = true, icon = "fas fa-tshirt", title = TranslateCap("menu_sell")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_clothes"),
		value = "sell_clothes",
		type = "sell_clothes"
    }



    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "sell_clothes" then
            print("sell_clothes")     
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

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(cottonPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)


RegisterCommand("tpm", function(source, args, arr)
	if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
			print(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
			SetPedCoordsKeepVehicle(PlayerPedId(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
	else
		TeleportToWaypoint()
	end
end, false)


function TeleportToWaypoint()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
            local height = 0.0
            for height = 1, 1000 do
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
                if foundGround then
                    SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                    break
                end
                Wait(1)
            end
    else
        print("tele_fail")
    end
end

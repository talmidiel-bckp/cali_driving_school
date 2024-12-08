local drivingSchoolPos = _G.Config.DrivingSchool.Coordinates
local currentTest = nil -- name of the currently taken test (Car, Truck, Bike)
local testVehicle = nil -- current driveing school vehicle
local outsideVehicleTime = 0 -- time spentoutside the driving school vehicle (in seconds)

function StartDrivingTest()
    local model = GetHashKey(_G.Config.Licenses[currentTest].vehicle)
    local vehicleSpawnCoords = _G.Config.Vehicle.SpawnCoords

    -- TODO: check if a vehicle is blocking the spawn point

    RequestModel(model)
    while not HasModelLoaded(model) do -- wait for the model to load before going further
        Wait(100)
    end

    if testVehicle then
        DeleteVehicle(testVehicle)
    end

    testVehicle = CreateVehicle(
        model,
        vehicleSpawnCoords.x,
        vehicleSpawnCoords.y,
        vehicleSpawnCoords.z,
        vehicleSpawnCoords.heading,
        _G.Config.Vehicle.isNetwork,
        _G.Config.Vehicle.netMissionEntity
    )

    math.randomseed(GetGameTimer())
    SetVehicleNumberPlateText(testVehicle, string.format(_G.Config.Vehicle.numberPlate, math.random(1000, 9999)))
    SetVehicleFuelLevel(testVehicle, 100.0)
    TaskWarpPedIntoVehicle(PlayerPedId(), testVehicle, -1)
    CheckCurrentVehicle()
end

function EndDrivingTest(success, reason)
    DeleteVehicle(testVehicle)
    ESX.ShowNotification(reason)

    currentTest = nil
    testVehicle = nil
    outsideVehicleTime = 0
end

-- Generate the driving school's menu
function OpenLicenseMenu()
    local elements = {
        {
            unselectable = true,
            title = "Auto École"
        }
    }

    -- dynamically generate the elements
    for key, value in pairs(_G.Config.Licenses) do
        -- TODO: put the licenses in correct order (current = random)
        -- TODO: find a way to grey out the entry if player already has the license
        -- maybe use disabled = true or unselectable = true
        table.insert(elements, {title = value.menuName, description = value.price .. '$', value = value.name, price = value.price, key = key})
    end

    ESX.OpenContext(
        'right',
        elements,
        function(menu, element) -- action if an entry is selected
            -- return true and deduct the price from player's account if he have enough money
            ESX.TriggerServerCallback('cali_driving_school:playerHasEnoughMoney', function(playerHasEnoughMoney)
                if playerHasEnoughMoney then
                    currentTest = element.key
                    -- TODO: try to show notification on left of screen rather than top
                    ESX.ShowNotification(string.format(_G.Messages.amountPaid, element.price))
                    ESX.CloseContext()
                    StartDrivingTest()
                else
                    -- TODO: try to show notification on left of screen rather than top
                    ESX.ShowNotification(string.format(_G.Messages.notEnoughMoney, element.title, element.price))
                    ESX.CloseContext()
                end
            end, element.price, element.title)
        end)
end

RegisterNetEvent('cali_driving_school:startTest')
AddEventHandler('cali_driving_school:startTest', function()
    StartDrivingTest()
    -- DrawCheckpoints
end)

function CheckCurrentVehicle()
    CreateThread(function()
        while currentTest do
            local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if currentVehicle ~= testVehicle then
                if outsideVehicleTime >= 45 and outsideVehicleTime < 60 then
                    ESX.ShowNotification(string.format(_G.Messages.wrongVehicle2, 60 - outsideVehicleTime))
                elseif outsideVehicleTime == 60 then
                    EndDrivingTest(false, _G.Messages.monitorLeft)
                else
                    ESX.ShowNotification(_G.Messages.wrongVehicle)
                end

                outsideVehicleTime = outsideVehicleTime + 5
            else
                outsideVehicleTime = 0
            end

            Wait(5000)
        end
    end)
end

-- Create driving school blip
CreateThread(function ()
    local blip = AddBlipForCoord(drivingSchoolPos.x, drivingSchoolPos.y, drivingSchoolPos.z)
    local drivingSchoolBlip = _G.Config.DrivingSchool.Blip

    SetBlipSprite(blip, drivingSchoolBlip.Sprite)
    SetBlipColour(blip, drivingSchoolBlip.Color)
    SetBlipDisplay(blip, drivingSchoolBlip.Display)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto École")
    EndTextCommandSetBlipName(blip)
end)

-- Create driving school origin marker
CreateThread(function ()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId()) -- get current player coordinates
        local distanceFromSchool = #(playerCoords - vector3(drivingSchoolPos.x, drivingSchoolPos.y, drivingSchoolPos.z)) -- get distance from marker

        if distanceFromSchool < _G.Config.DrawDistance then
            local drivingSchoolMarker =  _G.Config.DrivingSchool.Marker

            DrawMarker(
                drivingSchoolMarker.Type,
                drivingSchoolPos.x,
                drivingSchoolPos.y,
                drivingSchoolPos.z,
                drivingSchoolMarker.Direction.x,
                drivingSchoolMarker.Direction.y,
                drivingSchoolMarker.Direction.z,
                drivingSchoolMarker.Rotation.x,
                drivingSchoolMarker.Rotation.y,
                drivingSchoolMarker.Rotation.z,
                drivingSchoolMarker.Scale.x,
                drivingSchoolMarker.Scale.y,
                drivingSchoolMarker.Scale.z,
                drivingSchoolMarker.Color.r,
                drivingSchoolMarker.Color.g,
                drivingSchoolMarker.Color.b,
                drivingSchoolMarker.Color.a,
                drivingSchoolMarker.Bobbing,
                drivingSchoolMarker.FaceCamera,
                drivingSchoolMarker.P19,
                drivingSchoolMarker.Rotation.rotate,
                drivingSchoolMarker.Texture.dict,
                drivingSchoolMarker.Texture.name,
                drivingSchoolMarker.DrawOnEnts
            )

            if distanceFromSchool < _G.Config.InteractDistance then
                ESX.ShowHelpNotification(string.format(_G.Messages.pedInteract, _G.Config.InteractKey.name))

                if IsControlJustReleased(0, _G.Config.InteractKey.id) then
                    OpenLicenseMenu()
                end
            end
        end
    end
end)

-- create driving school monitor npc
CreateThread(function ()
    local pedConfig = _G.Config.DrivingSchool.Ped
    local modelHash = GetHashKey(pedConfig.Model)

    -- load the model before spawning it
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100) -- make sure the model is loaded before moving forward
    end

    -- create the and spawn the npc
    local npcPed = CreatePed(
        pedConfig.Type,
        modelHash,
        drivingSchoolPos.x,
        drivingSchoolPos.y,
        drivingSchoolPos.z,
        pedConfig.Heading,
        pedConfig.isNetwork,
        pedConfig.bScriptHostPed
    )

    -- Set NPC properties
    SetEntityInvincible(npcPed, true) -- Make NPC invincible
    SetBlockingOfNonTemporaryEvents(npcPed, true) -- Prevent reactions
    FreezeEntityPosition(npcPed, true) -- Prevent movement

    SetModelAsNoLongerNeeded(modelHash) -- free up some memory
end)

local drivingSchoolPos = _G.Config.DrivingSchool.Coordinates
local currentTest = nil -- name of the currently taken test (Car, Truck, Bike)
local testVehicle = nil -- current driving school vehicle
local outsideVehicleTime = 0 -- time spent outside the driving school vehicle (in seconds)
local currentCheckpoint = 1
local currentBlip = nil

-- Handles the logic for starting the driving test
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
    SetVehicleNumberPlateText(testVehicle, _G.Config.Vehicle.numberPlate)
    SetVehicleFuelLevel(testVehicle, 100.0)
    TaskWarpPedIntoVehicle(PlayerPedId(), testVehicle, -1)
    SetModelAsNoLongerNeeded(model) -- free up some memory
    CheckCurrentVehicle()
end

-- Handles the logic after the test is done
function EndDrivingTest(success, message)
    DeleteVehicle(testVehicle)
    ESX.ShowNotification(message)

    -- TODO: give license to player if success

    currentTest = nil
    testVehicle = nil
    outsideVehicleTime = 0
    currentCheckpoint = 1
    LastCheckPoint = -1
    currentBlip = nil
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
        table.insert(elements, {title = value.menuName, description = value.price .. '$', value = value.name, price = value.price, key = key}) -- TODO: refactor this (useless params)
    end

    ESX.OpenContext(
        'right',
        elements,
        function(menu, element) -- action if an entry is selected
            -- return true and deduct the price from player's account if he have enough money
            ESX.TriggerServerCallback('cali_driving_school:playerHasEnoughMoney', function(playerHasEnoughMoney)
                if playerHasEnoughMoney then
                    currentTest = element.key
                    ESX.CloseContext()
                    TriggerEvent('cali_driving_school:startTest')

                    Wait(2000) -- TODO: Move this to a more appropriate place
                    -- TODO: try to show notification on left of screen rather than top
                    ESX.ShowNotification(string.format(_G.Messages.startMessage, element.price))
                else
                    -- TODO: try to show notification on left of screen rather than top
                    ESX.ShowNotification(string.format(_G.Messages.notEnoughMoney, element.title, element.price))
                    ESX.CloseContext()
                end
            end, element.price, element.title)
        end)
end

-- TODO: merge with driving school blip and maybe move to an utils file ?
function CreateCheckpointBlip(coords)
    local blipConfig = _G.Config.Checkpoints.Blip
    currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(currentBlip, blipConfig.Sprite)
    SetBlipColour(currentBlip, blipConfig.Color)
    SetBlipRoute(currentBlip, blipConfig.Route)
    SetBlipScale(currentBlip, blipConfig.Scale)
end

RegisterNetEvent('cali_driving_school:startTest')
AddEventHandler('cali_driving_school:startTest', function()
    StartDrivingTest()
    DrawCheckpoints()
end)

-- Draw the checkpoints markers, blips, and messages
function DrawCheckpoints()
    local checkpoints = _G.Config.Checkpoints[currentTest]
    local checkpointMarker = _G.Config.Checkpoints.Marker

    CreateThread(function()
        CreateCheckpointBlip(checkpoints[currentCheckpoint].Pos)

        while currentCheckpoint <= #checkpoints do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local checkpoint = checkpoints[currentCheckpoint]

            DrawMarker(
                checkpointMarker.Type,
                checkpoint.Pos.x,
                checkpoint.Pos.y,
                checkpoint.Pos.z,
                checkpointMarker.Direction.x,
                checkpointMarker.Direction.y,
                checkpointMarker.Direction.z,
                checkpointMarker.Rotation.x,
                checkpointMarker.Rotation.y,
                checkpointMarker.Rotation.z,
                checkpointMarker.Scale.x,
                checkpointMarker.Scale.y,
                checkpointMarker.Scale.z,
                checkpointMarker.Color.r,
                checkpointMarker.Color.g,
                checkpointMarker.Color.b,
                checkpointMarker.Color.a,
                checkpointMarker.Bobbing,
                checkpointMarker.FaceCamera,
                checkpointMarker.P19,
                checkpointMarker.Rotation.rotate,
                checkpointMarker.Texture.dict,
                checkpointMarker.Texture.name,
                checkpointMarker.DrawOnEnts
            )

            local distanceFromCheckpoint = #(playerCoords - vector3(checkpoint.Pos.x, checkpoint.Pos.y, checkpoint.Pos.z))
            if distanceFromCheckpoint <= _G.Config.Checkpoints.validationDistance then -- TODO: check if the vehicle is the school one
                if checkpoint.Message then
                    ESX.ShowNotification(checkpoint.Message)
                end

                currentCheckpoint = currentCheckpoint + 1
                checkpoint = checkpoints[currentCheckpoint]

                RemoveBlip(currentBlip)
                if currentCheckpoint <= #checkpoints then
                    CreateCheckpointBlip(checkpoint.Pos)
                end

                -- TODO: check if last checkpoint, is a vehicle present on the spot
            end

            Wait(0)
        end

        EndDrivingTest(true, string.format(_G.Messages.testSucess, _G.Config.Licenses[currentTest].menuName))
    end)
end

-- Handles the player's leaving the driving school vehicle
function CheckCurrentVehicle()
    CreateThread(function()
        Wait(2000) -- Supposed to solve the mesage as soon as test starts bug
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

            if distanceFromSchool < _G.Config.InteractDistance and not currentTest then
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

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100) -- make sure the model is loaded before moving forward
    end

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

    SetEntityInvincible(npcPed, true) -- Make NPC invincible
    SetBlockingOfNonTemporaryEvents(npcPed, true) -- Prevent reactions
    FreezeEntityPosition(npcPed, true) -- Prevent movement

    SetModelAsNoLongerNeeded(modelHash) -- free up some memory
end)

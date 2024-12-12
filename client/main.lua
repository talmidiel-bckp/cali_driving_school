local drivingSchoolPos = _G.Config.DrivingSchool.Coordinates
local currentTest = nil -- name of the currently taken test (Car, Truck, Bike)
local testVehicle = nil -- current driving school vehicle
local outsideVehicleTime = 0 -- time spent outside the driving school vehicle (in seconds)
local currentCheckpoint = 1
local currentBlip = nil
local ownedLicense = {}
local driveErrors = 0
local currentZone = 'Town'
local lastVehicleHealth = nil
local closestVehicle = nil

local monitoring = {
    vehicle = false,
    speed = false,
    damage = false
}

function CleanTestRessources()
    if testVehicle then
        DeleteVehicle(testVehicle)
        testVehicle = nil
    end

    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
    end

    currentTest = nil
    currentCheckpoint = 1
    currentBlip = nil
    currentZone = nil
end

function HandleTestResult(success, callback)
    if success then
        TriggerServerEvent('cali_driving_school:addLicense', _G.Config.Licenses[currentTest].name)
    else
        local schoolCoordinates = _G.Config.Vehicle.SpawnCoords
        SetEntityCoords(PlayerPedId(), schoolCoordinates.x, schoolCoordinates.y, schoolCoordinates.z, false, false, false, true)
    end

    if callback then
        callback()
    end
end

function SpawnVehicle()
    local model = GetHashKey(_G.Config.Licenses[currentTest].vehicle)
    local vehicleSpawnCoords = _G.Config.Vehicle.SpawnCoords

    if testVehicle then
        DeleteVehicle(testVehicle)
    end

    RequestModel(model)
    while not HasModelLoaded(model) do -- wait for the model to load before going further
        Wait(100)
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


    math.randomseed(GetGameTimer()) -- seeding the random generator bafore calling math.random() from config
    SetVehicleNumberPlateText(testVehicle, _G.Config.Vehicle.numberPlate)
    SetVehicleFuelLevel(testVehicle, 100.0)
    SetModelAsNoLongerNeeded(model)
end

function StartMonitoring()
    monitoring = {
        vehicle = true,
        speed = true,
        damage = true
    }

    StartMonitoringVehicle()
    StartMonitoringSpeed()
    StartMonitoringColision()
end

function StopMonitoring()
    monitoring = {
        vehicle = false,
        speed = false,
        damage = false
    }

    lastVehicleHealth = nil
    outsideVehicleTime = 0
    driveErrors = 0
end

function CheckErrorsCount()
    if driveErrors >= _G.Config.MaxErrors then
        TriggerEvent('cali_driving_school:endTest', false, _G.Messages.tooManyErrors)
    else
        Wait(_G.Config.MonitoringCooldown)
    end
end

function IsVehicleBlockingSpawn()
    local spawnCoords = _G.Config.Vehicle.SpawnCoords
    closestVehicle = GetClosestVehicle(spawnCoords.x, spawnCoords.y, spawnCoords.z, _G.Config.Vehicle.SpawnRadius, 0, 71) -- 71 = bitmask for all vehicles

    return DoesEntityExist(closestVehicle)
end

function WaitForClearSpawn(callback)
    if not IsVehicleBlockingSpawn() then
        callback()
        return
    end

    local timePassed = 0

    ESX.ShowNotification(string.format(_G.Messages.blockedSpawn, _G.Config.ImpoundDelay))

    while timePassed < _G.Config.ImpoundDelay do
        Wait(1000)
        timePassed = timePassed + 1
    end

    if IsVehicleBlockingSpawn() then
        DeleteVehicle(closestVehicle)
        closestVehicle = nil
        ESX.ShowNotification(string.format(_G.Messages.impound, _G.Config.testDelay.impound / 1000)) -- ms to s
        Wait(_G.Config.testDelay.impound)
    else
        ESX.ShowNotification(string.format(_G.Messages.clearSpawn, _G.Config.testDelay.movedVehicle / 1000)) -- ms to s
        Wait(_G.Config.testDelay.movedVehicle)
    end

    callback()
end

function OpenLicenseMenu()
    local elements = {
        {
            unselectable = true,
            title = "Auto École",
            order = 0
        }
    }

    -- dynamically generate the elements
    for key, value in pairs(_G.Config.Licenses) do
        if ownedLicense[value.name] then
            table.insert(elements, {title = value.menuName, description = _G.Messages.ownedLicense, order = value.order, disabled = true})
        else
            table.insert(elements, {title = value.menuName, description = value.price .. '$', price = value.price, key = key, order = value.order})
        end
    end

    table.sort(elements, function(a, b)
        return a.order < b.order -- sort elements since pairs() is random
    end)

    ESX.OpenContext(
        'right',
        elements,
        function(menu, element)
            -- return true and deduct the price from player's account if he have enough money
            ESX.TriggerServerCallback('cali_driving_school:playerHasEnoughMoney', function(playerHasEnoughMoney)
                if playerHasEnoughMoney then
                    currentTest = element.key
                    ESX.CloseContext()
                    TriggerEvent('cali_driving_school:startTest')
                else
                    ESX.ShowNotification(string.format(_G.Messages.notEnoughMoney, element.title, element.price))
                    ESX.CloseContext()
                end
            end, element.price, element.title)
        end)
end

function CreateBlip(blipConfig, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, blipConfig.Sprite)
    SetBlipColour(blip, blipConfig.Color)
    SetBlipRoute(blip, blipConfig.Route)
    SetBlipScale(blip, blipConfig.Scale)
    SetBlipDisplay(blip, blipConfig.Display)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto École")
    EndTextCommandSetBlipName(blip)

    return blip
end

RegisterNetEvent('cali_driving_school:getLicenses')
AddEventHandler('cali_driving_school:getLicenses', function(licenses)
    for _, license in ipairs(licenses) do
        ownedLicense[license.type] = true
    end
end)

RegisterNetEvent('cali_driving_school:startTest')
AddEventHandler('cali_driving_school:startTest', function()
    WaitForClearSpawn(function()
        SpawnVehicle()
        TaskWarpPedIntoVehicle(PlayerPedId(), testVehicle, -1)
        StartMonitoring()
        DrawCheckpoints()
        Wait(1000) -- 1s delay to make it feel more "human"
        ESX.ShowNotification(_G.Messages.startMessage)
    end)
end)

RegisterNetEvent('cali_driving_school:endTest')
AddEventHandler('cali_driving_school:endTest', function(success, message)
    HandleTestResult(success, function()
        CleanTestRessources()
        ESX.ShowNotification(message)
    end)
    StopMonitoring()
end)

-- Draw the checkpoints markers, blips, and messages
function DrawCheckpoints()
    local checkpoints = _G.Config.Checkpoints[currentTest]
    local checkpointMarker = _G.Config.Checkpoints.Marker

    CreateThread(function()
        CreateBlip(_G.Config.Checkpoints.Blip, checkpoints[currentCheckpoint].Pos)

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
            if distanceFromCheckpoint <= _G.Config.Checkpoints.validationDistance and outsideVehicleTime == 0 then
                if checkpoint.Message then
                    ESX.ShowNotification(string.format(checkpoint.Message, _G.Config.SpeedLimits[checkpoint.Zone]))
                end

                currentCheckpoint = currentCheckpoint + 1
                checkpoint = checkpoints[currentCheckpoint]

                RemoveBlip(currentBlip)
                if currentCheckpoint <= #checkpoints then
                    currentBlip = CreateBlip(_G.Config.Checkpoints.Blip, checkpoint.Pos)
                end

                if currentZone ~= checkpoint.zone then
                    Wait(_G.Config.MonitoringCooldown) -- Let the player reduce it's speed between zones
                    currentZone = checkpoint.Zone
                end
            end

            Wait(0)
        end

        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        monitoring.vehicle = false

        while currentVehicle == testVehicle do
            currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            Wait(1000)
        end

        TriggerEvent('cali_driving_school:endTest', true, string.format(_G.Messages.testSucess, _G.Config.Licenses[currentTest].menuName))
    end)
end

function StartMonitoringVehicle()
    CreateThread(function()
        Wait(2000) -- Supposed to solve the message as soon as test starts bug
        local maxTime = _G.Config.MaxOutsideVehicleTime

        while monitoring.vehicle do
            local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if currentVehicle ~= testVehicle then
                monitoring.speed, monitoring.damage = false, false -- pause monitoring in case player gets inside another vehicle.

                if outsideVehicleTime >= maxTime then
                    TriggerEvent('cali_driving_school:endTest', false, _G.Messages.monitorLeft)
                elseif outsideVehicleTime >= (maxTime * 0.75) then
                    ESX.ShowNotification(string.format(_G.Messages.wrongVehicle2, maxTime - outsideVehicleTime))
                else
                    ESX.ShowNotification(_G.Messages.wrongVehicle)
                end

                outsideVehicleTime = outsideVehicleTime + (_G.Config.OutsideVehicleCooldown / 1000) -- ms to s
            elseif outsideVehicleTime > 0 then
                outsideVehicleTime = 0
                monitoring.speed, monitoring.damage = true, true

                StartMonitoringSpeed()
                StartMonitoringColision()
            end

            Wait(_G.Config.OutsideVehicleCooldown)
        end
    end)
end

function StartMonitoringSpeed()
    CreateThread(function()
        while monitoring.speed do
            local speed = GetEntitySpeed(testVehicle) * 3.6 -- Convert to kph

            if speed > _G.Config.SpeedLimits[currentZone] then
                driveErrors = driveErrors + 1
                ESX.ShowNotification(string.format(_G.Messages.speeding, _G.Config.SpeedLimits[currentZone], driveErrors, _G.Config.MaxErrors))
                CheckErrorsCount()
            end

            Wait(_G.Config.MonitoringInterval)
        end
    end)
end

function StartMonitoringColision()
    lastVehicleHealth = GetEntityHealth(testVehicle)

    CreateThread(function()
        while monitoring.damage do
            local health = GetEntityHealth(testVehicle)

            if health < lastVehicleHealth then
                driveErrors = driveErrors + 1
                ESX.ShowNotification(string.format(_G.Messages.colision, driveErrors, _G.Config.MaxErrors))
                lastVehicleHealth = health
                CheckErrorsCount()
            end

            Wait(_G.Config.MonitoringInterval)
        end
    end)
end

-- Create driving school origin marker
CreateThread(function ()
    CreateBlip(_G.Config.DrivingSchool.Blip, _G.Config.DrivingSchool.Coordinates)

    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distanceFromSchool = #(playerCoords - vector3(drivingSchoolPos.x, drivingSchoolPos.y, drivingSchoolPos.z))

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

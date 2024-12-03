local drivingSchoolPos = _G.Config.DrivingSchool.Coordinates
local currentTest = nil

function OpenLicenseMenu()
    local elements = {
        {
            unselectable = true,
            title = "Auto École"
        }
    }

    -- dynamically generate the elements
    for key, value in pairs(_G.Config.Licenses) do
        -- TODO: find a way to grey out the entry if player already has the license
        -- maybe use disabled = true or unselectable = true
        table.insert(elements, {title = value.menuName, description = value.price, value = value.name})
    end

    ESX.OpenContext(
        'right',
        elements,
        function(menu, element) -- action if an entry is selected
            --TODO: check if player have enough money
            currentTest = element.value
            print(string.format('%s selectioné', currentTest))
            ESX.CloseContext()
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

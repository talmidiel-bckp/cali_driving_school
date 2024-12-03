local drivingSchoolPos = _G.Config.DrivingSchool.Coordinates

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
        end
    end
end)

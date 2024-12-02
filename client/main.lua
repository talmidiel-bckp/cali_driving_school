-- Create driving school blip
CreateThread(function ()
    local pos = _G.Config.Coordinates.DrivingSchool.Position
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)

    SetBlipSprite(blip, _G.Config.Blip.Sprite)
    SetBlipColour(blip, _G.Config.Blip.Color)
    SetBlipDisplay(blip, _G.Config.Blip.Display)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto École")
    EndTextCommandSetBlipName(blip)
end)

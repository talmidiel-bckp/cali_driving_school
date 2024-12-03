_G.Config = {
    DrawDistance = 10.0,

    DrivingSchool = {
        Coordinates = {x = 239.471, y = -1380.960, z = 32.741},

        Blip = {
            Sprite = 782, -- radar_test_car
            Color = 0, -- White
            Display = 6 -- Main AND Mini map
        },

        Marker = {
            Type = 20, -- MarkerTypeChevronUpx1
            Direction = {x = 0.0, y = 0.0, z = 0.0},
            Color = {r = 0, g = 255, b = 0, a = 100}, -- Green
            Rotation = {x = 1.0, y = 1.0, z = 0.0, rotate = true},
            Scale = {x = 3.0, y = 0.5, z = 1.0},
            Bobbing = true,
            FaceCamera = true,
            P19 = 2,
            Texture = {dict = nil, name = nil},
            DrawOnEnts = false
        }
    }
}

print('config file loaded')

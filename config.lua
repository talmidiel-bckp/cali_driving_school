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
            Type = 25, -- MarkerTypeHorizontalCircleSkinny
            Direction = {x = 0.0, y = 0.0, z = 0.0},
            Color = {r = 0, g = 0, b = 0, a = 0}, -- Invisible
            Rotation = {x = 0.0, y = 0.0, z = 0.0, rotate = false},
            Scale = {x = 2.0, y = 2.0, z = 1.0},
            Bobbing = false,
            FaceCamera = false,
            P19 = 2,
            Texture = {dict = nil, name = nil},
            DrawOnEnts = false
        }
    }
}

print('config file loaded')

_G.Config = {
    DrawDistance = 10.0,
    InteractDistance = 1.5,
    InteractKey = {id = 38, name = 'E'},

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
        },

        Ped = {
            Model = 'a_m_m_bevhills_02',
            Type = 4, --Civilian
            Heading = 139.0,
            isNetwork = false, -- false for static Npc
            bScriptHostPed = false -- hosted locally
        }
    },

    Licenses = {
        Car = {name = 'drive', menuName = 'permis voiture', price = 500, vehicle = 'blista'},
        Bike = {name = 'drive_bike', menuName = 'permis moto', price = 500, vehicle = 'daemon'},
        Truck = {name = 'drive_truck', menuName = 'permis poids lourds', price = 500, vehicle = 'mule3'}
    },

    Vehicle = {
        SpawnCoords = {x = 223.068, y = -1387.859, z = 30.358, heading = 269.0},
        isNetwork = true, -- avoid other players seeing someone floating
        netMissionEntity = false, -- no need to keep the vehicle across multiple sessions
        numberPlate = "ECOL%s"
    }
}

_G.Messages = {
    pedInteract = "appuyez sur [%s] pour parler au moniteur", -- touche d'interaction variable
    notEnoughMoney = "vous n'avez pas les moyens pour passer le permis : %s (%s$)",
    bankMessage = "auto école : %s.",
    amountPaid = "vous avez payé %s$"
}

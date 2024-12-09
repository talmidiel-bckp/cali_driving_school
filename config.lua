_G.Config = {
    DrawDistance = 10.0,
    InteractDistance = 1.5,
    InteractKey = {id = 38, name = 'E'},

    SpeedLimits = {
        Town = 90,
        Outskirts = 120,
        Freeway = "Illimitée"
    },

    DrivingSchool = {
        Coordinates = {x = 239.471, y = -1380.960, z = 32.741},

        Blip = {
            Sprite = 782, -- radar_test_car
            Color = 0, -- White
            Display = 4 -- Main AND Mini map, non-sticky
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
        Car = {name = 'drive', menuName = 'permis voiture', price = 500, vehicle = 'blista', order = 1},
        Bike = {name = 'drive_bike', menuName = 'permis moto', price = 500, vehicle = 'daemon', order = 2},
        Truck = {name = 'drive_truck', menuName = 'permis poids lourds', price = 500, vehicle = 'mule3', order = 3}
    },

    Vehicle = {
        SpawnCoords = {x = 223.068, y = -1387.859, z = 30.358, heading = 269.0},
        isNetwork = true, -- avoid other players seeing someone floating
        netMissionEntity = false, -- no need to keep the vehicle across multiple sessions
        numberPlate = string.format("ECOL%s", math.random(1000, 9999))
    },

    Checkpoints = {
        validationDistance = 3.0,

        Marker = {
            Type = 25, -- MarkerTypeHorizontalCircleSkinny
            Direction = {x = 0.0, y = 0.0, z = 0.0},
            Color = {r = 204, g = 204, b = 0, a = 100}, -- Yellow
            Rotation = {x = 0.0, y = 0.0, z = 0.0, rotate = false},
            Scale = {x = 4.0, y = 4.0, z = 0.1},
            Bobbing = false,
            FaceCamera = false,
            P19 = 2,
            Texture = {dict = nil, name = nil},
            DrawOnEnts = false
        },

        Blip = {
            Sprite = 9, -- radar_radius_blip
            Color = 60,  -- Yellow Orange
            Display = 6, -- Main AND Mini map, sticky
            Route = true, -- Show route to blip
            Scale = 0.2
        },

        Car = {
            {
                Pos = {x = 213.006, y = -1417.160, z = 28.824},
                Message = "Insérez vous sur la voie de droite, puis tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 181.687, y = -1396.153, z = 28.824},
                Message = "Bien ! nous allons continuer tout droit. Attention, en ville la vitesse est limitée !",
                Zone = 'Town'
            },
            {
                Pos = {x = 218.716, y = -1090.588, z = 28.858},
                Message = "Attention ce carrefour est trés fréquenté !",
                Zone = 'Town'
            },
            {
                Pos = {x = 463.560, y = -510.830, z = 27.797},
                Message = "Nous allons rentrer sur l'autoroute, la vitesse n'est pas limitée.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 940.140, y = 198.593, z = 76.442},
                Message = "Nous allons sortir a la prochaine sortie, restez sur la voie de droite.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 1118.070, y = 362.650, z = 91.219},
                Message = "Tournez a gauche. Attention, en periphérie la vitesse est limitée !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1044.659, y = 474.791, z = 94.168},
                Message = "Tournez a droite, puis prenez a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1116.870, y = 616.338, z = 109.788},
                Message = "Attention au virages dangereux sur cette route !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 453.032, y = 879.784, z = 197.929},
                Message = "Prenez le chemin a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 302.030, y = 845.406, z = 192.891},
                Message = "Tournez a gauche. Attention, nous allons rentrer en ville !",
                Zone = 'Town'
            },
            {
                Pos = {x = 237.942, y = 467.024, z = 124.245},
                Message = "Tourner legérement a gauche pour continuer tout droit.",
                Zone = "Town"
            },
            {
                Pos = {x = -213.600, y = -936.290, z = 29.128},
                Message = "Préparez vous, nous allons prendre la prochaine a gauche.",
                Zone = 'Town'
            },
            {
                Pos = {x = 4.074, y = -1144.166, z = 28.201},
                Message = "Tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 193.081, y = -1423.674, z = 29.161},
                Message = "Faites demi-tour un peu plus loin avant de rentrez dans l'auto école.",
                Zone = 'Town'
            },
            {
                Pos = {x = 234.857, y = -1400.360, z = 30.071},
                Message = "Garez votre vehicule avant de sortir.",
                Zone = 'Town'
            },
            {
                Pos = {x = 240.758, y = -1413.740, z = 29.391},
                Message = "Soretez du vehicule pour valider le test !",
                Zone = 'Town'
            }
        },
        Bike = {
            {
                Pos = {x = 213.006, y = -1417.160, z = 28.824},
                Message = "Insérez vous sur la voie de droite, puis tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 181.687, y = -1396.153, z = 28.824},
                Message = "Bien ! nous allons continuer tout droit. Attention, en ville la vitesse est limitée !",
                Zone = 'Town'
            },
            {
                Pos = {x = 218.716, y = -1090.588, z = 28.858},
                Message = "Attention ce carrefour est trés fréquenté !",
                Zone = 'Town'
            },
            {
                Pos = {x = 463.560, y = -510.830, z = 27.797},
                Message = "Nous allons rentrer sur l'autoroute, la vitesse n'est pas limitée.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 940.140, y = 198.593, z = 76.442},
                Message = "Nous allons sortir a la prochaine sortie, restez sur la voie de droite.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 1118.070, y = 362.650, z = 91.219},
                Message = "Tournez a gauche. Attention, en periphérie la vitesse est limitée !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1044.659, y = 474.791, z = 94.168},
                Message = "Tournez a droite, puis prenez a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1116.870, y = 616.338, z = 109.788},
                Message = "Attention au virages dangereux sur cette route !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 453.032, y = 879.784, z = 197.929},
                Message = "Prenez le chemin a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 302.030, y = 845.406, z = 192.891},
                Message = "Tournez a gauche. Attention, nous allons rentrer en ville !",
                Zone = 'Town'
            },
            {
                Pos = {x = 237.942, y = 467.024, z = 124.245},
                Message = "Tourner legérement a gauche pour continuer tout droit.",
                Zone = "Town"
            },
            {
                Pos = {x = -213.600, y = -936.290, z = 29.128},
                Message = "Préparez vous, nous allons prendre la prochaine a gauche.",
                Zone = 'Town'
            },
            {
                Pos = {x = 4.074, y = -1144.166, z = 28.201},
                Message = "Tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 193.081, y = -1423.674, z = 29.161},
                Message = "Faites demi-tour un peu plus loin avant de rentrez dans l'auto école.",
                Zone = 'Town'
            },
            {
                Pos = {x = 234.857, y = -1400.360, z = 30.071},
                Message = "Garez votre vehicule avant de sortir.",
                Zone = 'Town'
            },
            {
                Pos = {x = 240.758, y = -1413.740, z = 29.391},
                Message = "Soretez du vehicule pour valider le test !",
                Zone = 'Town'
            }
        },
        Truck = {
            {
                Pos = {x = 213.006, y = -1417.160, z = 28.824},
                Message = "Insérez vous sur la voie de droite, puis tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 181.687, y = -1396.153, z = 28.824},
                Message = "Bien ! nous allons continuer tout droit. Attention, en ville la vitesse est limitée !",
                Zone = 'Town'
            },
            {
                Pos = {x = 218.716, y = -1090.588, z = 28.858},
                Message = "Attention ce carrefour est trés fréquenté !",
                Zone = 'Town'
            },
            {
                Pos = {x = 463.560, y = -510.830, z = 27.797},
                Message = "Nous allons rentrer sur l'autoroute, la vitesse n'est pas limitée.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 940.140, y = 198.593, z = 76.442},
                Message = "Nous allons sortir a la prochaine sortie, restez sur la voie de droite.",
                Zone = 'Freeway'
            },
            {
                Pos = {x = 1118.070, y = 362.650, z = 91.219},
                Message = "Tournez a gauche. Attention, en periphérie la vitesse est limitée !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1044.659, y = 474.791, z = 94.168},
                Message = "Tournez a droite, puis prenez a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 1116.870, y = 616.338, z = 109.788},
                Message = "Attention au virages dangereux sur cette route !",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 453.032, y = 879.784, z = 197.929},
                Message = "Prenez le chemin a gauche.",
                Zone = 'Outskirts'
            },
            {
                Pos = {x = 302.030, y = 845.406, z = 192.891},
                Message = "Tournez a gauche. Attention, nous allons rentrer en ville !",
                Zone = 'Town'
            },
            {
                Pos = {x = 237.942, y = 467.024, z = 124.245},
                Message = "Tourner legérement a gauche pour continuer tout droit.",
                Zone = "Town"
            },
            {
                Pos = {x = -213.600, y = -936.290, z = 29.128},
                Message = "Préparez vous, nous allons prendre la prochaine a gauche.",
                Zone = 'Town'
            },
            {
                Pos = {x = 4.074, y = -1144.166, z = 28.201},
                Message = "Tournez a droite.",
                Zone = 'Town'
            },
            {
                Pos = {x = 193.081, y = -1423.674, z = 29.161},
                Message = "Faites demi-tour un peu plus loin avant de rentrez dans l'auto école.",
                Zone = 'Town'
            },
            {
                Pos = {x = 234.857, y = -1400.360, z = 30.071},
                Message = "Garez votre vehicule avant de sortir.",
                Zone = 'Town'
            },
            {
                Pos = {x = 240.758, y = -1413.740, z = 29.391},
                Message = "Soretez du vehicule pour valider le test !",
                Zone = 'Town'
            }
        }
    }
}

_G.Messages = {
    pedInteract = "appuyez sur [%s] pour parler au moniteur", -- touche d'interaction variable
    notEnoughMoney = "vous n'avez pas les moyens pour passer le permis : %s (%s$)",
    bankMessage = "auto école : %s.",
    wrongVehicle = "Veuillez retourner dans le vehicule de l'auto école pour poursuivre le test",
    wrongVehicle2 = "le moniteur partiras sans vous dans %s secondes",
    monitorLeft = "le moniteur est rentré sans vous !",
    testSucess = "Félicitations, vous avez réussi votre %s",
    startMessage = "Sortez de l'auto école et prenez a droite"
}

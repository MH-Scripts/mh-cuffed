--[[ ===================================================== ]] --
--[[                MH Cuffed by MaDHouSe79                ]] --
--[[ ===================================================== ]] --
SV_Config = {}

SV_Config.Peds = Peds
SV_Config.Vehicles = Vehicles

SV_Config.ResetTimer = 30 -- 30 * 1000
SV_Config.DisableRunningWhenCuffed = false

SV_Config.JailCoords = vector3(441.0086, -981.1292, 30.6896)
-- Make sure you have the items in your system.
SV_Config.JailItems = {'cokebaggy', 'crack_baggy', 'xtcbaggy', 'meth'}
SV_Config.HandcuffItem = "weapon_handcuffs"
SV_Config.RevieItem = "firstaid"

SV_Config.UseItems = false -- True when you use a inventory.
SV_Config.Inventory = "qb-inventory" -- Use your own inventory and make sure you have an HasItem(item, amount) export


SV_Config.Animations = {
    player = {
        walk = {
            dict = "amb@world_human_drinking@coffee@female@base",
            name = "base",
        },
        search = {
            dict = "random@shop_robbery",
            name = "robbery_action_b",
        },
        revive = {
            dict = "mini@cpr@char_a@cpr_str",
            name = "cpr_pumpchest",
        },
    },
    ped = {
        idle = {
            dict = "mp_arresting",
            name = "idle",
        },
        sit = {
            dict = "mp_arresting",
            name = "sit",
        },
        walk = {
            dict = "mp_arresting",
            name = "walk",
        },
        run = {
            dict = "anim@move_m@trash",
            name = "run",
        },
        hostage = {
            dict = "anim@heists@ornate_bank@hostages@ped_d@",
            name = "idle",
        },
        surender = {
            dict = "random@arrests@busted",
            name = "idle_a"
        },
    }
}

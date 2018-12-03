local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet (с учетом scene:getChipFrame)
    cpu = 1,
    gpu = 2,
    asic = 3,
    alien = 4,
    --chuck = 5, -- norris
}

local INF = 1000 * 1000 * 1000 * 1000

local Gh = 1000
local Th = 1000 * Gh
local Ph = 1000 * Th

M.chips = {
    { epoch = M.epoches.cpu, cost = 1, output = 0.6, power_consumption = 15, name = 'Electron 330', },
    { epoch = M.epoches.cpu, cost = 10, output = 3, power_consumption = 50, name = 'Outel P4', },
    { epoch = M.epoches.cpu, cost = 70, output = 15, power_consumption = 95, name = 'Phantom II', },
    { epoch = M.epoches.cpu, cost = 150, output = 30, power_consumption = 35, name = 'Kernel j3M', },
    { epoch = M.epoches.cpu, cost = 300, output = 50, power_consumption = 95, name = 'Kernel 2', },
    { epoch = M.epoches.cpu, cost = 700, output = 80, power_consumption = 130, name = 'Adm Athlete', },
    { epoch = M.epoches.cpu, cost = 1 * 1000, output = 100, power_consumption = 100, name = 'Kernel j7', },
    { epoch = M.epoches.cpu, cost = 3 * 1000, output = 150, power_consumption = 190, name = 'A10-5800K', },
    { epoch = M.epoches.cpu, cost = 5000, output = 500, power_consumption = 500, name = 'Smart Fridge', },

    { epoch = M.epoches.gpu, cost = 2 * 1000, output = 200, power_consumption = 170, name = 'Videmus 250', },
    { epoch = M.epoches.gpu, cost = 3 * 1000, output = 400, power_consumption = 160, name = 'AdvanDev X1', },
    { epoch = M.epoches.gpu, cost = 5 * 1000, output = 830, power_consumption = 150, name = 'Poweron 5970', },
    { epoch = M.epoches.gpu, cost = 10 * 1000, output = 2 * Gh, power_consumption = 140, name = 'GTX Uber', },
    { epoch = M.epoches.gpu, cost = 20 * 1000, output = 50 * Gh, power_consumption = 130, name = 'GTY', },
    { epoch = M.epoches.gpu, cost = 20 * 1000, output = 200 * Gh, power_consumption = 5000, name = 'Black Hole', },
    { epoch = M.epoches.gpu, cost = 50 * 1000, output = 500 * Gh, power_consumption = 800, name = 'Thor', },
    { epoch = M.epoches.gpu, cost = 100 * 1000, output = 800 * Gh, power_consumption = 1000, name = 'Odin', },
    { epoch = M.epoches.gpu, cost = 500 * 1000 * 1000, output = 100 * Th, power_consumption = 500, name = 'Voodoo', },

    { epoch = M.epoches.asic, cost = 1 * 1000 * 1000, output = 1 * Th, power_consumption = 4000, name = 'TerraSha DX', },
    { epoch = M.epoches.asic, cost = 2 * 1000 * 1000, output = 3 * Th, power_consumption = 3200, name = 'AntMan S2', },
    { epoch = M.epoches.asic, cost = 5 * 1000 * 1000, output = 14 * Th, power_consumption = 2500, name = 'AntMan S9', },
    { epoch = M.epoches.asic, cost = 6 * 1000 * 1000, output = 18 * Th, power_consumption = 1800, name = 'Etherbit E10', },
    { epoch = M.epoches.asic, cost = 10 * 1000 * 1000, output = 28 * Th, power_consumption = 1600, name = 'Realasic', },
    { epoch = M.epoches.asic, cost = 30 * 1000 * 1000, output = 60 * Th, power_consumption = 2000, name = 'GoldRiver', },
    { epoch = M.epoches.asic, cost = 50 * 1000 * 1000, output = 150 * Th, power_consumption = 5000, name = 'Rainbow', },
    { epoch = M.epoches.asic, cost = 200 * 1000 * 1000, output = 500 * Th, power_consumption = 6000, name = 'SolarLight', },
    { epoch = M.epoches.asic, cost = 1000 * 1000 * 1000, output = 2 * Ph, power_consumption = 1600, name = 'Universe', },

    { epoch = M.epoches.alien, cost = 500 * 1000 * 1000, output = 999 * Ph, power_consumption = 1000 * 1000, name = 'Kirill', },
}

M.epochLimits = {
    [M.epoches.cpu] = 0,
    [M.epoches.gpu] = 2 * 1000,
    [M.epoches.asic] = 100 * 1000,
    [M.epoches.alien] = 1000 * 1000 * 1000,
}

for i, chip in ipairs(M.chips) do
    chip.idx = i
    chip.power_consumption = chip.power_consumption / 60 -- Из минут в секунды

    --print(chip.name, chip.output / chip.power_consumption, chip.cost / (chip.output / chip.power_consumption))
end

return M

local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet
    cpu = 1,
    gpu = 2,
    asic = 3,
    --alien = 4,
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
    { epoch = M.epoches.cpu, cost = 150, output = 10, power_consumption = 35, name = 'Kernel j7M', },
    { epoch = M.epoches.cpu, cost = 300, output = 30, power_consumption = 95, name = 'Kernel 2', },
    { epoch = M.epoches.cpu, cost = 700, output = 55, power_consumption = 130, name = 'Adm Athlete', },
    { epoch = M.epoches.cpu, cost = 1 * 1000, output = 80, power_consumption = 100, name = 'Kernel j7', },
    { epoch = M.epoches.cpu, cost = 3 * 1000, output = 150, power_consumption = 190, name = 'A10-5800K', },
    { epoch = M.epoches.cpu, cost = 5000, output = 500, power_consumption = 1000, name = 'Smart Fridge', },

    { epoch = M.epoches.gpu, cost = 3 * 1000, output = 100, power_consumption = 170, name = 'Videmus 250', },
    { epoch = M.epoches.gpu, cost = 10 * 1000, output = 400, power_consumption = 100, name = 'AdvanDev X1', },
    { epoch = M.epoches.gpu, cost = 30 * 1000, output = 830, power_consumption = 100, name = 'Poweron 5970', },
    { epoch = M.epoches.gpu, cost = 100 * 1000, output = 2 * Gh, power_consumption = 100, name = 'GTX Uber', },
    { epoch = M.epoches.gpu, cost = 500 * 1000, output = 50 * Gh, power_consumption = 100, name = 'GTY', },
    { epoch = M.epoches.gpu, cost = 10 * 1000 * 1000, output = 200 * Gh, power_consumption = 100, name = 'Black Hole', },
    { epoch = M.epoches.gpu, cost = 100 * 1000 * 1000, output = 900 * Gh, power_consumption = 100, name = 'Thor', },
    { epoch = M.epoches.gpu, cost = 200 * 1000 * 1000, output = 4 * Th, power_consumption = 100, name = 'Odin', },
    { epoch = M.epoches.gpu, cost = 1000 * 1000 * 1000, output = 100 * Th, power_consumption = 10000, name = 'Voodoo', },

    { epoch = M.epoches.asic, cost = INF, output = 28 * Th, power_consumption = 1600, name = 'Realasic', }, -- 120k rub

    --{ epoch = M.epoches.alien, cost = INF, output = 999 * Ph, power_consumption = 1000 * 1000, name = 'Kirill', },
}

M.epochLimits = {
    [M.epoches.cpu] = 0,
    [M.epoches.gpu] = 2 * 1000,
    [M.epoches.asic] = 50 * 1000 * 1000,
    --[M.epoches.alien] = 1000 * 1000 * 1000 * 1000,
}

for i, chip in ipairs(M.chips) do
    chip.idx = i
    chip.power_consumption = chip.power_consumption / 60 -- Из минут в секунды

    --print(chip.name, chip.output / chip.power_consumption, chip.cost / (chip.output / chip.power_consumption))
end

return M

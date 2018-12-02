local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet
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
    { epoch = M.epoches.cpu, cost = 1, output = 0.6, power_consumption = 15, name = 'Atom 330', },
    { epoch = M.epoches.cpu, cost = 10, output = 3, power_consumption = 50, name = 'Intel P4', },
    { epoch = M.epoches.cpu, cost = 100, output = 15, power_consumption = 95, name = 'Phenom II X4', },
    { epoch = M.epoches.cpu, cost = 400, output = 10, power_consumption = 35, name = 'Core i7 620M', },
    { epoch = M.epoches.cpu, cost = 500, output = 20, power_consumption = 95, name = 'Core 2 Quad', },
    { epoch = M.epoches.cpu, cost = 1000, output = 55, power_consumption = 130, name = 'Adm Athlete', },
    { epoch = M.epoches.cpu, cost = 2000, output = 80, power_consumption = 90, name = 'Outel Kernel j7', },
    { epoch = M.epoches.cpu, cost = 3000, output = 105, power_consumption = 100, name = 'A10-5800K', },
    { epoch = M.epoches.cpu, cost = 5000, output = 500, power_consumption = 300, name = 'Smart Fridge', },

    { epoch = M.epoches.gpu, cost = 2000, output = 100, power_consumption = 130, name = 'Videmus 250', },
    { epoch = M.epoches.gpu, cost = 3000, output = 150, power_consumption = 200, name = 'Poweron Graphics', },
    { epoch = M.epoches.gpu, cost = 4000, output = 530, power_consumption = 725, name = 'Radeon 5970', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#4', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#5', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#6', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#7', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#8', },
    { epoch = M.epoches.gpu, cost = 5000, output = 68, power_consumption = 170, name = 'GPU#9', },

    { epoch = M.epoches.asic, cost = INF, output = 28 * Th, power_consumption = 1600, name = 'Realasic', }, -- 120k rub

    { epoch = M.epoches.alien, cost = INF, output = 999 * Ph, power_consumption = 1000 * 1000, name = 'Kirill', },
}

M.epochLimits = {
    [M.epoches.cpu] = 0,
    [M.epoches.gpu] = 2 * 1000,
    [M.epoches.asic] = 50 * 1000 * 1000,
    [M.epoches.alien] = 1000 * 1000 * 1000 * 1000,
}

for i, chip in ipairs(M.chips) do
    chip.idx = i
    chip.power_consumption = chip.power_consumption / 60 -- Из минут в секунды

    --print(chip.name, chip.output / chip.power_consumption, chip.cost / (chip.output / chip.power_consumption))
end

return M

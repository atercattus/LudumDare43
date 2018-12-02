local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet
    cpu = 1,
    gpu = 2,
    asic = 3,
    alien = 4,
    chuck = 5, -- norris
}

local INF = 1000 * 1000 * 1000 * 1000

M.chips = {
    { epoch = M.epoches.cpu, cost = 1, output = 0.6, power_consumption = 15, minimal_output = 0, name = 'Atom 330', },
    { epoch = M.epoches.cpu, cost = 10, output = 3, power_consumption = 50, minimal_output = 3, name = 'Intel P4', },
    { epoch = M.epoches.cpu, cost = 100, output = 15, power_consumption = 95, minimal_output = INF, name = 'Phenom II X4', },
    { epoch = M.epoches.cpu, cost = 500, output = 10, power_consumption = 35, minimal_output = INF, name = 'Core i7 620M', },
    { epoch = M.epoches.cpu, cost = INF, output = 18, power_consumption = 95, minimal_output = INF, name = 'Core 2 Quad', },
    { epoch = M.epoches.cpu, cost = INF, output = 30, power_consumption = 150, minimal_output = INF, name = 'Adm Athlete', },
    { epoch = M.epoches.cpu, cost = INF, output = 80, power_consumption = 70, minimal_output = INF, name = 'Outel Kernel j7', },
    { epoch = M.epoches.cpu, cost = INF, output = 105, power_consumption = 100, minimal_output = INF, name = 'A10-5800K', },
    { epoch = M.epoches.cpu, cost = INF, output = 100, power_consumption = 300, minimal_output = INF, name = 'Smart Fridge', },

    { epoch = M.epoches.gpu, cost = INF, output = 100, power_consumption = 120, minimal_output = 0, name = 'Videmus 250', },
    { epoch = M.epoches.gpu, cost = INF, output = 150, power_consumption = 200, minimal_output = 0, name = 'Poweron Graphics', },
    { epoch = M.epoches.gpu, cost = INF, output = 530, power_consumption = 725, minimal_output = 0, name = 'Radeon 5970', },
    { epoch = M.epoches.gpu, cost = INF, output = 68, power_consumption = 170, minimal_output = 0, name = 'GTX560 Ti', },

    { epoch = M.epoches.asic, cost = INF, output = 28 * 1000 * 1000, power_consumption = 1600, minimal_output = 0, name = 'Realasic', }, -- 120k rub
}

for i, chip in ipairs(M.chips) do
    chip.idx = i
    chip.power_consumption = chip.power_consumption / 60 -- Из минут в секунды

    print(chip.name, chip.output / chip.power_consumption, chip.cost / (chip.output / chip.power_consumption))
end

return M

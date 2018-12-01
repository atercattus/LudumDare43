local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet
    cpu = 1,
    gpu = 2,
    asic = 3,
}

M.chips = {
    {
        name = 'Outel Neptium 4',
        epoch = M.epoches.cpu,
        cost = 10,
        output = 1,
        power_consumption = 65,
        --temperature = { max = 100 },
    },
    {
        name = 'Adm Athlete',
        epoch = M.epoches.cpu,
        cost = 20,
        output = 10,
        power_consumption = 90,
        --temperature = { max = 120 },
    },
    {
        name = 'Outel Kernel j7',
        epoch = M.epoches.cpu,
        cost = 100,
        output = 80,
        power_consumption = 70,
        --temperature = { max = 80 },
    },
    {
        name = 'Videmus 250',
        epoch = M.epoches.gpu,
        cost = 1000,
        output = 100,
        power_consumption = 120,
        --temperature = { max = 80 },
    },
    {
        name = 'Poweron Graphics',
        epoch = M.epoches.gpu,
        cost = 700,
        output = 150,
        power_consumption = 200,
        --temperature = { max = 120 },
    },
}

for i in ipairs(M.chips) do
    M.chips[i].idx = i
end

return M

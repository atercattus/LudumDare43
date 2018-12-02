local M = {}

M.epoches = {
    -- Порядок должен совпадать с chipsImageSheet
    cpu = 1,
    gpu = 2,
    asic = 3,
}

M.chips = {
    {
        name = 'Atom 330',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 1,
        power_consumption = 8,
    },
    {
        name = 'Intel P4',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 3,
        power_consumption = 65,
    },
    {
        name = 'Phenom II X4',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 9,
        power_consumption = 95,
    },
    {
        name = 'Core i7 620M',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 6,
        power_consumption = 35,
    },
    {
        name = 'Core 2 Quad',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 18,
        power_consumption = 95,
    },
    {
        name = 'Adm Athlete',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 30,
        power_consumption = 150,
    },
    {
        name = 'Outel Kernel j7',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 80,
        power_consumption = 70,
    },
    {
        name = 'A10-5800K',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 105,
        power_consumption = 100,
    },
    {
        name = 'Smart Fridge',
        epoch = M.epoches.cpu,
        cost = 1,
        output = 100,
        power_consumption = 300,
    },



    {
        name = 'Videmus 250',
        epoch = M.epoches.gpu,
        cost = 1,
        output = 100,
        power_consumption = 120,
    },
    {
        name = 'Poweron Graphics',
        epoch = M.epoches.gpu,
        cost = 1,
        output = 150,
        power_consumption = 200,
    },
    {
        name = 'Radeon 5970', -- Реальная
        epoch = M.epoches.gpu,
        cost = 1,
        output = 530,
        power_consumption = 725,
    },
    {
        name = 'GTX560 Ti', -- Реальная
        epoch = M.epoches.gpu,
        cost = 1,
        output = 68,
        power_consumption = 170,
    },
    {
        name = 'Realasic', -- реальный цифры, название нет
        epoch = M.epoches.asic,
        cost = 1, --120*1000,
        output = 28*1000*1000, -- 28Th
        power_consumption = 1600,
    },
}

for i, chips in ipairs(M.chips) do
    chips.idx = i
    chips.power_consumption = chips.power_consumption / 60 -- Из минут в секунды
end

return M

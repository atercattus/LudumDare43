local M = {}

local copyPlain = require('libs.utils').copyPlain

local config = require("data.config")
local epoches = config.epoches
local chips = config.chips

function M.newGameState()
    local state = {
        -- Состояние
        coins = 43.0, -- Сколько всего монет доступно (LC)
        output = 0.0, -- Выработка в Mhash/sec
        xchg = 100, -- Текущий курс обмена Mhash на LC
        epoch = epoches.cpu, -- Текущее поколение вычислителей

        -- Вычисляемые на каждом такте
        consumption = 0, -- Текущее потребление в W/sec
        consumptionCost = 0.0, -- Стоимость текущего потребления в LC/sec
    }

    function state:getAllowedShopList()
        local list = {}

        local epoch = self.epoch
        local coins = self.coins

        for _, chip in ipairs(chips) do
            if chip.epoch <= epoch then
                list[#list + 1] = copyPlain(chip)
            end
        end

        return list
    end

    return state
end

function M.newChipState()
    local state = {-- Состояние

        -- Вычисляемые на каждом такте
    }

    return state
end

return M

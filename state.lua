local M = {}

local ipairs = ipairs

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
        epoch = epoches.cpu, -- Текущее поколение чипов
        chipsList = {}, -- Купленные чипы

        -- Вычисляемые на каждом такте
        consumption = 0, -- Текущее потребление в W/sec
        consumptionCost = 0.0, -- Стоимость текущего потребления в LC/sec
    }

    function state:getAllowedShopList()
        local list = {}

        local epoch = self.epoch

        for _, chip in ipairs(chips) do
            if chip.epoch <= epoch then
                list[#list + 1] = copyPlain(chip)
            end
        end

        return list
    end

    function state:tryToBuy(chipIdx)
        if (chipIdx < 1) or (chipIdx > #chips) then
            return false
        end

        local chipInfo = chips[chipIdx]

        if (self.coins < chipInfo.cost) or (self.epoch < chipInfo.epoch) then
            return false
        end

        self.coins = self.coins - chipInfo.cost
        self:addChip(chipIdx)

        return true
    end

    function state:addChip(chipIdx)
        local ourChips
        for _, chips in ipairs(self.chipsList) do
            if chips.idx == chipIdx then
                ourChips = chips
                break
            end
        end

        if ourChips == nil then
            -- Куплен новый тип чипа
            ourChips = M:newChipsState()
            self.chipsList[#self.chipsList + 1] = ourChips

            ourChips.idx = chipIdx
        end

        ourChips.count = ourChips.count + 1
    end

    function state:getShopChipInfo(chipIdx)
        for _, chips in ipairs(self.chipsList) do
            if chips.idx == chipIdx then
                return chips
            end
        end

        return nil
    end

    return state
end

function M.newChipsState()
    local state = {
        idx = 0, -- Индекс в массиве config.chips
        count = 0, -- Общее количество
    }

    return state
end

return M

local M = {}

local ipairs = ipairs
local floor = math.floor

local copyPlain = require('libs.utils').copyPlain

local config = require("data.config")
local epoches = config.epoches
local chipsConfig = config.chips

function M.newGameState()
    local state = {
        -- Состояние
        coins = 43.0, -- Сколько всего монет доступно (LC)
        xchg = 100, -- Текущий курс обмена Mhash на LC
        epoch = epoches.cpu, -- Текущее поколение чипов
        chipsList = {}, -- Купленные чипы

        -- Вычисляемые на каждом такте
        output = 0.0, -- Выработка в Mhash/sec
        outputTotal = 0.0, -- Выработка в hash/sec с момента прошлой покупки LC
        consumption = 0, -- Текущее потребление в W/sec
        consumptionCost = 0.0, -- Стоимость текущего потребления в LC/sec
    }

    function state:getAllowedShopList()
        local list = {}

        local epoch = self.epoch

        for _, chip in ipairs(chipsConfig) do
            if chip.epoch <= epoch then
                list[#list + 1] = copyPlain(chip)
            end
        end

        return list
    end

    function state:tryToBuy(chipIdx)
        if (chipIdx < 1) or (chipIdx > #chipsConfig) then
            return false
        end

        local chipInfo = chipsConfig[chipIdx]

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

    function state:processingTick(dt)
        local shortInfo = {
            changedCoins = false,
            changedOutput = false,
            changedXchg = false,
            changedConsumption = false,
            changedConsumptionCost = false, -- ToDo: self.consumptionCost
        }

        local consumption = 0
        local output = 0
        local outputTotal = self.outputTotal
        if dt > 0 then
            for _, chips in ipairs(self.chipsList) do
                local chipInfo = chipsConfig[chips.idx]
                consumption = consumption + chips.count * chipInfo.power_consumption
                output = output + chips.count * chipInfo.output
                outputTotal = outputTotal + chips.count * chipInfo.output * dt
            end
        end

        if outputTotal >= self.xchg then
            local add = floor(outputTotal / self.xchg)
            outputTotal = outputTotal - add * self.xchg
            self.coins = self.coins + add
            shortInfo.changedCoins = true
        end

        self.output = output
        self.outputTotal = outputTotal
        shortInfo.changedOutput = output > 0

        self.consumption = consumption
        shortInfo.changedConsumption = consumption > 0

        return shortInfo
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

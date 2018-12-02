local M = {}

local ipairs = ipairs
local floor = math.floor

local copyPlain = require('libs.utils').copyPlain

local config = require("data.config")
local epoches = config.epoches
local chipsConfig = config.chips

local turboBoostStep = 5 -- На сколько одно нажатие Turbo ускоряет работу
local turboFadingStep = 2 -- На сколько за секунду замедляется Turbo режим

local electricityBillCoeff = 0.0001 -- Стоимость 1 W/s в LC

function M.newGameState()
    local state = {
        -- Состояние
        coins = 43.0, -- Сколько всего монет доступно (LC)
        xchg = 100, -- Текущий курс обмена Mhash на LC
        epoch = epoches.cpu, -- Текущее поколение чипов
        chipsList = {}, -- Купленные чипы
        buyMultiplier = 1, -- Множитель количества при покупке

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

        local cost = chipInfo.cost * self.buyMultiplier

        if (self.coins < cost) or (self.epoch < chipInfo.epoch) then
            return false
        end

        self.coins = self.coins - cost
        self:addChip(chipIdx, self.buyMultiplier)

        return true
    end

    function state:addChip(chipIdx, mult)
        local mult = mult or 1

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

        ourChips.count = ourChips.count + mult
    end

    function state:getShopChipInfo(chipIdx)
        for _, chips in ipairs(self.chipsList) do
            if chips.idx == chipIdx then
                return chips
            end
        end

        return nil
    end

    function state:turboBoost(chipIdx)
        local ourChips
        for _, chips in ipairs(self.chipsList) do
            if chips.idx == chipIdx then
                ourChips = chips
                break
            end
        end
        if ourChips == nil then
            return
        end

        ourChips.turboBoost = ourChips.turboBoost + turboBoostStep

        -- ToDo: if ourChips.turboBoost >= 100 - ПЕРЕГРЕВ
    end

    function state:processingTick(dt)
        local shortInfo = {
            changedCoins = false,
            changedOutput = false,
            changedXchg = false,
            changedConsumption = false,
            changedFarm = false,
        }

        local consumption = 0
        local output = 0
        local outputTotal = self.outputTotal
        if dt > 0 then
            for _, chips in ipairs(self.chipsList) do
                local chipInfo = chipsConfig[chips.idx]

                local boost = chips.turboBoost
                if boost > 0 then
                    shortInfo.changedFarm = true
                    boost = boost - turboFadingStep * dt
                    if boost > 100 then
                        boost = 100
                    elseif boost < 0 then
                        boost = 0
                    end
                    chips.turboBoost = boost
                end


                local count = chips:turboBoostCount()

                consumption = consumption + count * chipInfo.power_consumption
                output = output + count * chipInfo.output
                outputTotal = outputTotal + count * chipInfo.output * dt
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
        self.consumptionCost = electricityBillCoeff * consumption
        if self.consumptionCost > 0 then
            self.coins = self.coins - self.consumptionCost
            shortInfo.changedCoins = true
        end

        return shortInfo
    end

    function state:setBuyMultiplier(mult)
        if self.buyMultiplier == mult then
            return false
        end

        self.buyMultiplier = mult
        return true
    end

    return state
end

function M.newChipsState()
    local state = {
        idx = 0, -- Индекс в массиве config.chips
        count = 0, -- Общее количество
        turboBoost = 0, -- "Турбо" режим в процентах от максимума
    }

    function state:turboBoostCount()
        -- При активном бусте чипов как бы становится больше
        return self.count * ((self.turboBoost / 100) + 1)
    end

    return state
end

return M

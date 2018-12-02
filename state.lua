local M = {}

local ipairs = ipairs
local floor = math.floor
local tableRemove = table.remove
local mathRandom = math.random
local mathRound = math.round

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

        -- Статичные
        overheatPercentage = 60, -- С этого уровня начинается перегрев
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

    function state:tryToBuy(chipIdx, count)
        local count = count or self.buyMultiplier

        if (chipIdx < 1) or (chipIdx > #chipsConfig) then
            return false
        end

        local chipInfo = chipsConfig[chipIdx]

        local cost = chipInfo.cost * count

        if (self.coins < cost) or (self.epoch < chipInfo.epoch) then
            return false
        end

        self.coins = self.coins - cost
        self:addChip(chipIdx, count)

        return true
    end

    function state:tryToThrowOut(chipIdx, count)
        if (chipIdx < 1) or (chipIdx > #chipsConfig) then
            return false
        end
        return state:deleteChip(chipIdx, count)
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

    function state:deleteChip(chipIdx, mult)
        local mult = mult or 1

        local ourChips
        local idx
        for i, chips in ipairs(self.chipsList) do
            if chips.idx == chipIdx then
                ourChips = chips
                idx = i
                break
            end
        end

        if ourChips == nil then
            return false
        end

        ourChips.count = ourChips.count - mult
        if ourChips.count <= 0 then
            tableRemove(self.chipsList, idx)
        end

        return true
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

                    -- Тест на перегрев может вызывать deleteChip, т.е. выкидывать chips из массива chipsList
                    self:processingTick_processOverheat(chips, boost, dt)

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
                shortInfo.changedOutput = true
            end
        end

        if outputTotal >= self.xchg then
            local add = floor(outputTotal / self.xchg)
            outputTotal = outputTotal - add * self.xchg
            self.coins = self.coins + add
            shortInfo.changedCoins = true
        end

        shortInfo.changedOutput = shortInfo.changedOutput or (self.output ~= output)
        self.output = output
        self.outputTotal = outputTotal

        self.consumption = consumption
        shortInfo.changedConsumption = consumption > 0
        self.consumptionCost = electricityBillCoeff * consumption
        if self.consumptionCost > 0 then
            self.coins = self.coins - self.consumptionCost
            shortInfo.changedCoins = true
        end

        return shortInfo
    end

    function state:processingTick_processOverheat(chips, boost, dt)
        local delta
        if boost >= 100 then
            delta = 5
        elseif boost >= 80 then
            delta = 2
        elseif boost >= self.overheatPercentage then
            delta = 1
        else
            -- Пусть чипы остывают супер быстро :)
            chips.overheat = 0
            return
        end

        chips.overheat = chips.overheat + (delta * dt)
        if chips.overheat < 0 then
            chips.overheat = 0
            return
        end

        if chips.overheat > 20 then
            local ev = mathRandom(0, 2000) < chips.overheat
            if ev then
                local cnt = mathRound(chips.count * 0.01, 0)
                if cnt == 0 then
                    cnt = 1
                end

                -- ToDo: визуализация перегрева
                print('OVERHEATED', chips.idx, chips.overheat, 'CNT=', cnt)
                self:deleteChip(chips.idx, cnt)
                return
            end
        end

        return
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
        turboBoost = 0, -- "Турбо" режим в процентах от максимума (100)
        overheat = 0, -- Температурное состояние чипов
    }

    function state:turboBoostCount()
        -- При активном бусте чипов как бы становится больше
        return self.count * ((self.turboBoost / 100) + 1)
    end

    return state
end

return M

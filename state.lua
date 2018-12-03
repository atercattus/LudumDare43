local M = {}

local ipairs = ipairs
local mathFloor = math.floor
local tableRemove = table.remove
local mathRandom = math.random
local mathRound = math.round
local systemGetTimer = system.getTimer

local copyPlain = require('libs.utils').copyPlain

local config = require("data.config")
local epoches = config.epoches
local chipsConfig = config.chips
local configEpochLimits = config.epochLimits

local turboBoostStep = 5 -- На сколько одно нажатие Turbo ускоряет работу
local turboFadingStep = 2 -- На сколько за секунду замедляется Turbo режим

function M.newGameState()
    local state = {
        -- Состояние
        coins = 3, -- Сколько всего монет доступно (LC)
        xchg = 2.5, -- Текущий курс обмена Mhash на LC
        epoch = epoches.cpu, -- Текущее поколение чипов
        chipsList = {}, -- Купленные чипы
        buyMultiplier = 1, -- Множитель количества при покупке
        shopChipType = epoches.cpu, -- Текущий видимый раздел в магазине

        -- Вычисляемые на каждом такте
        output = 0.0, -- Выработка в Mhash/sec
        outputTotal = 0.0, -- Выработка в hash/sec с момента прошлой покупки LC
        consumption = 0, -- Текущее потребление в W/sec
        maximumCoins = 0, -- Максимальное (пиковое) полученное число монент за все время

        -- Статичные
        overheatPercentage = 60, -- С этого уровня начинается перегрев
        startedAt = systemGetTimer(), -- Время запуска
    }
    state.maximumCoins = state.coins

    function state:getConsumptionLimit()
        -- Общий лимит по питанию: 100kW/h в секундах
        return 5 * (10 ^ state.epoch) * 1000 / 3600
    end

    function state:clearChipsList()
        self.chipsList = {}
    end

    function state:switchShopType(shopChipType)
        if self.shopChipType == shopChipType then
            return false
        end
        self.shopChipType = shopChipType
        return true
    end

    function state:getAllowedShopList()
        local list = {}

        local epoch = self.shopChipType

        local firstUnavailable = true
        for _, chip in ipairs(chipsConfig) do
            if chip.epoch ~= epoch then
                -- skip
            else
                local allowAdd = chip.cost <= self.maximumCoins

                if (not allowAdd) and firstUnavailable then
                    firstUnavailable = false
                    allowAdd = true
                end

                if allowAdd then
                    list[#list + 1] = copyPlain(chip)
                end
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

        if (self.coins < cost) or (self.epoch < chipInfo.epoch) or (self.consumption + chipInfo.power_consumption > self:getConsumptionLimit()) then
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

        if mult > ourChips.count then
            mult = ourChips.count
        end

        ourChips.count = ourChips.count - mult

        -- Возвращаю половину стоимости от убранных чипов
        self.coins = self.coins + (chipsConfig[chipIdx].cost * mult) / 2

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
    end

    function state:processingTick(dt)
        local shortInfo = {
            changedCoins = false,
            changedOutput = false,
            changedXchg = false,
            changedConsumption = false,
            changedFarm = false,
            changedShopList = false, -- Появился новый пункт в магазине
        }

        local consumption = 0
        local output = 0
        local outputTotal = self.outputTotal
        local chipsCount = 0
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

                chipsCount = chipsCount + chips.count

                local boostCount = chips:turboBoostCount()

                consumption = consumption + chips.count * chipInfo.power_consumption -- без boostCount
                output = output + boostCount * chipInfo.output
                outputTotal = outputTotal + boostCount * chipInfo.output * dt
                shortInfo.changedOutput = true
            end
        end

        if self:processingTick_processXchg(dt) then
            shortInfo.changedXchg = true
        end

        if outputTotal >= self.xchg then
            local add = mathFloor(outputTotal / self.xchg)
            outputTotal = outputTotal - add * self.xchg
            self.coins = self.coins + add
            shortInfo.changedCoins = true
        end

        shortInfo.changedOutput = shortInfo.changedOutput or (self.output ~= output)
        self.output = output
        self.outputTotal = outputTotal

        if self:processingTick_processMaximumCoins() then
            shortInfo.changedShopList = true
        end

        shortInfo.changedConsumption = (consumption > 0) or (self.consumption ~= consumption)
        self.consumption = consumption

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
            local ev = mathRandom(0, 800) < chips.overheat
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

    function state:processingTick_processXchg(dt)
        -- Расчет окупаемости
        -- Сейчас хорошие ASIC'и окупаются за 1+ год. Для игры такое не подойдет :)

        local epoch = self.epoch

        local maximumCoins = self.maximumCoins

        local topChipH = 0

        local newChipEverySecs = 90 -- где-то в мире запускают новый чит каждые сколько секунд
        local chipCount = mathFloor((systemGetTimer() - self.startedAt) / 1000 / newChipEverySecs)
        if chipCount < 1 then
            chipCount = 1
        end

        for _, chip in ipairs(chipsConfig) do
            if chip.epoch > epoch then
                -- pass
            elseif chip.cost > maximumCoins then
                -- pass
            else
                local chipH = chip.output
                if chipH > topChipH then
                    topChipH = chipH
                end
            end
        end

        local complexityFactor = 2 + epoch
        if complexityFactor > 9 then
            complexityFactor = 9
        end
        complexityFactor = complexityFactor / 10

        local bill = chipCount * topChipH * 3 * complexityFactor
        if bill < 2.5 then
            bill = 2.5
        end

        local delta = bill - self.xchg
        if delta > 0.1 then
            delta = 0.1
        end

        self.xchg = self.xchg + delta * dt
        return true
    end

    function state:processingTick_processMaximumCoins()
        local newMaximum = self.coins
        local oldMaximum = self.maximumCoins

        if self.maximumCoins >= newMaximum then
            -- Это не новый максимум, так что нечего и проверять
            return false
        end
        self.maximumCoins = newMaximum

        local epoch = self.epoch

        for _, chip in ipairs(chipsConfig) do
            if chip.epoch > epoch then
                -- skip
            elseif (chip.cost > oldMaximum) and (chip.cost <= newMaximum) then
                return true
            end
        end

        return false
    end

    function state:setBuyMultiplier(mult)
        if self.buyMultiplier == mult then
            return false
        end

        self.buyMultiplier = mult
        return true
    end

    function state:tryToOpenNewChipType()
        if self.epoch >= #configEpochLimits then
            -- Уже достигли всего
            return false
        end

        if self.coins >= configEpochLimits[self.epoch + 1] then
            self.epoch = self.epoch + 1
            return true
        end

        return false
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
        return self.count * ((1.2 * self.turboBoost / 100) + 1)
    end

    return state
end

return M

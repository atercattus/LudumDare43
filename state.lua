local M = {}

local copyPlain = require('libs.utils').copyPlain

local config = require("data.config")
local epoches = config.epoches
local chips = config.chips

function M.newGameState()
    local state = {
        -- ���������
        coins = 43.0, -- ������� ����� ����� �������� (LC)
        output = 0.0, -- ��������� � Mhash/sec
        xchg = 100, -- ������� ���� ������ Mhash �� LC
        epoch = epoches.cpu, -- ������� ��������� ������������

        -- ����������� �� ������ �����
        consumption = 0, -- ������� ����������� � W/sec
        consumptionCost = 0.0, -- ��������� �������� ����������� � LC/sec
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
    local state = {-- ���������

        -- ����������� �� ������ �����
    }

    return state
end

return M

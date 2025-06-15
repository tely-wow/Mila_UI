---@class AbstractFramework
local AF = _G.AbstractFramework

local floor, ceil, abs, max, min = math.floor, math.ceil, math.abs, math.max, math.min

---------------------------------------------------------------------
-- math
---------------------------------------------------------------------
AF.epsilon = 0.00001

function AF.ApproxEqual(a, b, epsilon)
    return abs(a - b) <= (epsilon or AF.epsilon)
end

function AF.ApproxZero(n)
    return AF.ApproxEqual(n, 0)
end

function AF.Round(num)
    if num < 0.0 then
        return ceil(num - 0.5)
    end
    return floor(num + 0.5)
end

function AF.RoundToDecimal(num, numDecimalPlaces)
    local mult = 10 ^ numDecimalPlaces
    num = num * mult
    if num < 0.0 then
        return ceil(num - 0.5) / mult
    end
    return floor(num + 0.5) / mult
end

function AF.RoundToNearestMultiple(num, multiplier)
    return AF.Round(num / multiplier) * multiplier
end

function AF.Interpolate(start, stop, step, maxSteps)
    return start + (stop - start) * step / maxSteps
end

function AF.Clamp(value, minValue, maxValue)
    maxValue = max(minValue, maxValue) -- to ensure maxValue >= minValue
    if value > maxValue then
        return maxValue
    elseif value < minValue then
        return minValue
    end
    return value
end

function AF.PercentageBetween(value, startValue, endValue)
    if startValue == endValue then
        return 0.0
    end
    return (value - startValue) / (endValue - startValue)
end

function AF.ClampedPercentageBetween(value, startValue, endValue)
    return AF.Clamp(AF.PercentageBetween(value, startValue, endValue), 0.0, 1.0)
end
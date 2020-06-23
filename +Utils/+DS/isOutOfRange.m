function [outOfRange] = isOutOfRange(vec, lower, upper)
    outOfRange = (vec<lower | vec>upper);
end
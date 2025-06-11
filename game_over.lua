local M = {}
M.__index = M
function M:execute(msg, font, x, y, scale)
         love.graphics.setBackgroundColor(0, 0, 0)
         love.graphics.setColor(1, 0, 0)
         love.graphics.print(msg, font, x, y, nil, scale)
         love.graphics.setColor(1, 1, 1)
end
return M
local M = {}
M.__index = M
M.imageNotAssigned = [[
         Module image not found. Please set it manually or use function (modulename):setImage(image) and try again.
]]
M.colorNotAssigned = [[
         Module color not found. Please set it manually or use function (modulename):setColor(color) and try again.
]]

function M:setImage(img)
         if img then
                  M.sprite = img
         else
                  error('setup or syntax error')
         end
end

--use rgb values
function M:setColor(color)
         if color then
                  M.color = color
         else
                  error('Use RGB when assigning (ie eg: red:(1, 0, 0), green(0, 1, 0), blue(0, 0, 1), white(1, 1, 1), black(0, 0, 0). Adjust alpha (transparency) values via 4th argument.')
         end
end

function M:setFont(font, fontScale)
         M.font = font
         M.font_scale = fontScale
end

function M:spawn(x, y, text, size)
         if M.sprite and M.color then
                  love.graphics.draw(M.sprite, x, y, nil, size * 2.5, size * 2)
                  love.graphics.setColor(M.color)
                  --[[
                  if M.font then
                           love.graphics.printf(tostring(text), M.font, x + size * 10, y + size * 5.8, nil, M.font_scale)
                  else
                           love.graphics.printf(tostring(text), x + size * 10, y + size * 5, nil, size * 0.5, 5)
                  end
                  ]]
                  if M.font then
                           love.graphics.printf(tostring(text), M.font, x + (5 * (size * 1.3)), y + (5 * (size / 1.2)), size * 30, "left", nil, M.font_scale, M.font_scale / 1.2)
                  else
                           love.graphics.printf(tostring(text), x, y, size * 30, "left", nil, size)
                  end
                  love.graphics.setColor(1, 1, 1)
         else
                  error(M.imageNotAssigned.."\n"..M.colorNotAssigned)
         end
end
return M
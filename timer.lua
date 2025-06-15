timer = {}
timer.__index = timer

function timer.new(tag, time, color)
         local instance = setmetatable({}, timer)
         instance.tag = tag
         instance.time = time
         instance.color = color
         return instance
end

function timer:deplete(rate)
         self.time = self.time - rate
end

function timer:draw()
         love.graphics.setColor(self.color)
         love.graphics.print(math.floor(self.time), game.font, 400, 10, nil, 3)
         love.graphics.setColor(1, 1, 1)
end
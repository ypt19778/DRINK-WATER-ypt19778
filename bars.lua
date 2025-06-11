thirst_bar = {}
thirst_bar.__index = thirst_bar

function thirst_bar.new(x, y, width, height, capacity)
         local instance = setmetatable({}, thirst_bar)
         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height

         instance.full_capacity = capacity
         instance.capacity = capacity + (width / 2)
         instance.extra_capacity = 0
         return instance
end

function thirst_bar:drain(rate)
         self.capacity = self.capacity - rate
end

function thirst_bar:update(dt)
         if self.capacity <= 0 then
                  game.state = 'game over'
                  self.capacity = 0
         elseif self.capacity > self.full_capacity then
                  self.capacity = self.full_capacity
         end
end

function thirst_bar:draw()
         -- bar border
         love.graphics.setColor(0, 0, 0)
         love.graphics.rectangle("fill", self.x - 5, self.y - 5, self.width + 5, self.height + 10)
         -- bar
         love.graphics.setColor(0, 0, 1)
         love.graphics.rectangle("fill", self.x, self.y, self.capacity, self.height)
         love.graphics.setColor(1, 1, 1)
end
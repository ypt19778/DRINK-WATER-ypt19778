player = {}
player.__index = player

function player.new(tag, x, y, width, height, speed, world)
         local instance = setmetatable({}, player)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height
         instance.speed = speed

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
         instance.physics.body:setFixedRotation(true)

         instance.physics.fixture:setUserData(instance)

         return instance
end

function player:move()
-- speed tracker         local velX, velY = self.physics.body:getLinearVelocity()
         local vectX, vectY = 0, 0

         if love.keyboard.isDown('w') then
                  vectY = -self.speed
         elseif love.keyboard.isDown('a') then
                  vectX = -self.speed
         elseif love.keyboard.isDown('s') then
                  vectY = self.speed
         elseif love.keyboard.isDown('d') then
                  vectX = self.speed
         end

         self.physics.body:setLinearVelocity(vectX, vectY)         
end

function player:draw()
         love.graphics.polygon('line', self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
end

function player:interact()

end
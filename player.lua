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

         instance.animation = {
                  frameSpeed = 3,
                  currentFrame = 1,
                  idle = love.graphics.newImage('assets/sprites/player-idle-anim.png'),
                  left = love.graphics.newImage('assets/sprites/player-left-anim.png'),
                  right = love.graphics.newImage('assets/sprites/player-right-anim.png'),
                  up = love.graphics.newImage('assets/sprites/player-up-anim.png'),
                  down = love.graphics.newImage('assets/sprites/player-down-anim.png'),
                  frames = {}
         }
         instance.animation.currentAnimation = instance.animation.idle

         local sprite_width = 28
         local sprite_height = 11
         local frame_width = 7
         local frame_height = 11
         for i = 0, 4 do
                  table.insert(instance.animation.frames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, sprite_width, sprite_height))
         end

         return instance
end

function player:move()
-- speed tracker         local velX, velY = self.physics.body:getLinearVelocity()
         local vectX, vectY = 0, 0

         if love.keyboard.isDown('w') then
                  vectY = -self.speed
                  self.animation.currentAnimation = self.animation.up
         elseif love.keyboard.isDown('a') then
                  vectX = -self.speed
                  self.animation.currentAnimation = self.animation.left
         elseif love.keyboard.isDown('s') then
                  vectY = self.speed
                  self.animation.currentAnimation = self.animation.down
         elseif love.keyboard.isDown('d') then
                  vectX = self.speed
                  self.animation.currentAnimation = self.animation.right
         else
                  self.animation.currentAnimation = self.animation.idle
         end

         self.physics.body:setLinearVelocity(vectX, vectY)     
         self.x = self.physics.body:getX()
         self.y = self.physics.body:getY()    
end

function player:update(dt)
         self.animation.currentFrame = self.animation.currentFrame + self.animation.frameSpeed * dt
         print(self.animation.currentFrame)
         if self.animation.currentFrame >= 5 then
                  self.animation.currentFrame = 1
         end
end

function player:draw()
         love.graphics.draw(self.animation.currentAnimation, self.animation.frames[math.floor(self.animation.currentFrame)], self.x, self.y, nil, 3)
         --love.graphics.polygon('line', self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
end
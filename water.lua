waters = {}

water = {}
water.__index = water

local rows = 14
local inRows = 10

local spawngrid = {}

for i = 1, rows do
         for j = 1, inRows do
                  table.insert(spawngrid, {x = 50 * i, y = 50 * j})
         end
end

function water.new(tag, x, y, width, height)
         local instance = setmetatable({}, water)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'static')
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

         instance.physics.fixture:setUserData(instance)

         instance.animation = {
                  frameSpeed = 5,
                  currentFrame = 1,
                  spriteSheet = love.graphics.newImage('assets/sprites/water-anim.png'),
                  frames = {}
         }

         local sprite_width = instance.animation.spriteSheet:getWidth()
         local sprite_height = instance.animation.spriteSheet:getHeight()
         local frame_width = 13
         local frame_height = 14

         for i = 0, 4 do
                  table.insert(instance.animation.frames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, sprite_width, sprite_height))
         end

         instance.alpha = 100
         return instance
end

timer = 0
amount = 0
function water:startSpawn(rate)
         timer = timer + 1
         if timer > rate then
                  amount = amount + 1

                  local dice = math.random(#spawngrid)
                  new_water = water.new("water"..amount, spawngrid[dice].x, spawngrid[dice].y, 38, 40)
                  table.insert(waters, new_water)

                  print(new_water.tag.."  ".."x : "..new_water.x..", y : "..new_water.y)
                  timer = 0
         end
end

function water:pickup(mark)
         table.remove(waters, mark)
         self.physics.fixture:destroy()
         sounds.drink.one:play()
end

function water:update(dt)
         self.animation.currentFrame = self.animation.currentFrame + self.animation.frameSpeed * dt
         if self.animation.currentFrame >= 4 then
                  self.animation.currentFrame = 1
         end
end

function water:draw()
         love.graphics.setColor(1, 1, 1, self.alpha)
         love.graphics.draw(self.animation.spriteSheet, self.animation.frames[math.floor(self.animation.currentFrame)], self.x, self.y, nil, 3)
         --love.graphics.polygon('line', self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
         love.graphics.setColor(1, 1, 1)
end
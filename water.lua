waters = {}

water = {}
water.__index = water

function water.new(tag, x, y, width, height)
         local instance = setmetatable({}, water)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
         instance.physics.body:setFixedRotation(true)
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
         return instance
end

--this will check the locations of every water on screen
local function checkWaters(chkX, chkY)
         --for every water in array waters, do
                  --if the argument x and y equals any x or y in the array waters then return false and end the function
         for i, v in ipairs(waters) do
                  if chkX == v.x and chkY == v.y then
                           print('replacing water...')
                           return false
                  end
         end
                  --if said argument is not equal to any x or y in the array waters return true and end the function                  
         --print('successfully spawned new water.')
         return true
end

local timer = 0
local amount = 0
function water:startSpawn(rate)
         local rows = 14
         local inRows = 10

         local spawngrid = {}

         for i = 1, rows do
                  for j = 1, inRows do
                           table.insert(spawngrid, {x = 50 * i, y = 50 * j})
                  end
         end
         
         timer = timer + 1
         if timer > rate then
                  local dice = math.random(#spawngrid)
                  num = 0

                  --while the location is occupied and the number of loops is less than ( or equal to ) the number of waters, do
                  --(more on num <= waters):
                  --if num is greater than the number of values in the water array the while loop will stop ( so it doesn't crash the game ) and move on until a water is removed and a new spot has become open.
                           --amount of loops = amount of loops plus one ( tracking amount of loops )
                           --reroll dice ( so next water can spawn )
                  while checkWaters(spawngrid[dice].x, spawngrid[dice].y) == false and num <= #waters do
                           num = num + 1
                           dice = math.random(#spawngrid)
                  end

                  --the code will move on to this if statement when the while loop is done.
                  --if the location is not occupied then
                           --spawn and insert newly spawned water into a table
                  if checkWaters(spawngrid[dice].x, spawngrid[dice].y) then
                           new_water = water.new("water"..amount, spawngrid[dice].x, spawngrid[dice].y, 38, 40)
                           table.insert(waters, new_water)
                           amount = amount + 1
                  end

                  --reset timer to make waters respawnable
                  timer = 0
         end
end

function water:pickup(mark, sound)
         table.remove(waters, mark)
         self.physics.fixture:destroy()
         if sound == true then
                  --sounds.drink.one:play()
         end
end

function water:update(dt)
         for i, v in ipairs(waters) do
                  if collisions == 'playercolliding'..v.tag then
                           v:pickup(i, true)
                           t_bar.capacity = t_bar.capacity + (t_bar.full_capacity - t_bar.capacity)
                  end
          
                  v.animation.currentFrame = v.animation.currentFrame + v.animation.frameSpeed * dt
                  if v.animation.currentFrame >= 4 then
                           v.animation.currentFrame = 1
                  end
                  v.x = v.physics.body:getX()
                  v.y = v.physics.body:getY()
         end
end

function water:draw()
         for i, v in ipairs(waters) do
                  love.graphics.draw(v.animation.spriteSheet, v.animation.frames[math.floor(v.animation.currentFrame)], v.x, v.y, nil, 3)
                  --love.graphics.polygon('line', v.physics.body:getWorldPoints(v.physics.shape:getPoints()))
         end
end

function water:killall()
         for i, v in ipairs(waters) do
                  v.physics.fixture:destroy()
                  waters[i] = nil
                  waters = {}
         end
end

function water:checkCollisions(a)
         for i, v in ipairs(waters) do
                  if a.x + a.width > v.x and a.x < v.x + v.width and a.y + a.height > v.y and a.y < v.y + v.height then
                           return true
                  end
         end
         return false   
end
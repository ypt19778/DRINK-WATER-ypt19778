bushes = {}

bush = {}
bush.__index = bush

function bush.new(tag, x, y, width, height, type, world)
         local instance = setmetatable({}, bush)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height
         instance.scale = 5

         instance.sprite = love.graphics.newImage('assets/sprites/bush-sprite.png')

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, type)
         instance.physics.body:setFixedRotation(true)
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
         instance.physics.fixture:setRestitution(0.3)

         instance.physics.fixture:setUserData(instance)

         return instance
end

local spawn_amount = 1
local spawn_amount_cur = 1
function bush:spawnMaze()
         local grid = {
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                  {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
                  {1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1},
                  {1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1},
                  {1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1},
                  {1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1},
                  {1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1},
                  {1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1},
                  {1, 0, 0, 1, 0, 0, 0, 1, 1, 2, 1, 0, 1, 1},
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
         }
         if spawn_amount_cur <= spawn_amount then
                  bush:killall()
                  for i, row in ipairs(grid) do
                           for j, tile in ipairs(row) do
                                    if tile ~= 0 then
                                             if tile == 1 then
                                                      print('bush spawned')
                                                      new_bush = bush.new('bush', 50 * j - 10, 50 * i - 10, 45, 45, 'static', world)
                                                      table.insert(bushes, new_bush)
                                             elseif tile == 2 then
                                                      print('campfire spawned')
                                                      new_fire = campfire.new('fire', 50 * j, 50 * i, 45, 45, world)
                                                      table.insert(campfires, new_fire)
                                             end
                                    end
                           end
                  end
                  spawn_amount_cur = spawn_amount_cur + 1
         end
end

local spawn_amount_2 = 0
function bush:spawnSpots()
         grid  = {
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,},
                  {1, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                  {1, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                  {1, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
                  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1},
                  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1},

         }

         if spawn_amount_2 ~= 1 then
                  for index_row, row in ipairs(grid) do
                           for index_tile, tile in ipairs(row) do
                                    if tile ~= 0 then
                                             if tile == 1 then
                                                      print('bush spawned')
                                                      new_bush = bush.new('bush', 50 * index_tile - 3500, 50 * index_row + 100, 45, 45, 'static', world)
                                                      table.insert(bushes, new_bush)     
                                             elseif tile == 2 then
                                                      print('bush spawned')
                                                      new_bush = bush.new('bush', 50 * index_tile - 3500, 50 * index_row + 100, 45, 45, 'dynamic', world)
                                                      table.insert(bushes, new_bush)    
                                             elseif tile == 3 then
                                                      print('e')
                                             end
                                    end
                           end
                  end
                  spawn_amount_2 = 1
         end
end

local rows = 14
local inRows = 10

local spawngrid = {}

local amount = 0
local maxAmount = 4 

local event = 0

local function checkBushes(chkX, chkY)
         for i, v in ipairs(bush) do
                  if chkX == v.x and chkY == v.y then
                           print('replacing bush...')
                           return false
                  end
         end

         print('successfully spawned new bush.')
         return true
end

function bush:availablerand()
         amount = 0
end

function bush:spawnRand()-- set as the amount of bushes needed
         for i = 1, rows do
                  for j = 1, inRows do
                           table.insert(spawngrid, {x = 50 * i, y = 50 * j})
                  end
         end

         local dice = math.random(#spawngrid)

         local num = 0
         if amount <= maxAmount then
                  while checkBushes(spawngrid[dice].x, spawngrid[dice].y) == false and num <= #bush do
                           num = num + 1
                           dice = math.random(#spawngrid)
                  end         
                  if checkBushes(spawngrid[dice].x, spawngrid[dice].y) then
                           amount = amount + 1
                           new_bush = bush.new('bush'..amount, spawngrid[dice].x, spawngrid[dice].y, 45, 45, 'static', world)
                           print(new_bush.tag)
                           table.insert(bushes, new_bush)
                  end
         end
end

function bush:draw()
         for i, v in ipairs(bushes) do
                  love.graphics.draw(v.sprite, v.x, v.y, nil, v.scale)
                  --love.graphics.polygon("line", v.physics.body:getWorldPoints(v.physics.shape:getPoints()))
         end
end

function bush:killall()
         for i, v in ipairs(bushes) do
                  v.physics.fixture:destroy()
                  bushes[i] = nil
                  bushes = {}
         end
end

function bush:update(dt)
         for i, v in ipairs(bushes) do
                  v.x = v.physics.body:getX()
                  v.y = v.physics.body:getY()
         end
end

cacti = {}

cactus = {}
cactus.__index = cactus 
function cactus.new(tag, x, y, speed, world)
         local instance = setmetatable({}, cactus)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = 33
         instance.height = 37

         instance.scale = 4

         instance.sprite = love.graphics.newImage('assets/sprites/cactus-sprite.png')

         instance.speed = speed

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'dynamic')
         instance.physics.body:setFixedRotation(true)
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

         instance.physics.fixture:setUserData(instance)
         return instance
end

function cactus:move(dt, gotoX, gotoY)
         for i, v in ipairs(cacti) do
                  local angle = math.atan2(gotoY - v.y, gotoX - v.x)

                  local cos = math.cos(angle)
                  local sin = math.sin(angle)

                  v.physics.body:applyLinearImpulse((v.speed * 2) * cos * dt, (v.speed * 2) * sin * dt)
                  v.x = v.physics.body:getX()
                  v.y = v.physics.body:getY()
         end
end

function cactus:checkCollisions(a)
         for i, v in ipairs(cacti) do
                  if a.x + a.width > v.x and a.x < v.x + v.width and a.y + a.height > v.y and a.y < v.y + v.height then
                           return true
                  end
         end
         return false
end

function cactus:draw()
         for i, v in ipairs(cacti) do
                  --love.graphics.polygon('line', v.physics.body:getWorldPoints(v.physics.shape:getPoints()))
                  love.graphics.draw(v.sprite, v.x, v.y, nil, v.scale)
         end
end
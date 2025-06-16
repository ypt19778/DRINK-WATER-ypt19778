cacti = {}

cactus = {}
cactus.__index = cactus

function cactus.new(tag, x, y, width, height, world)
         local instance = setmetatable({}, cactus)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height
         instance.scale = 5

         instance.sprite = love.graphics.newImage('assets/sprites/cactus-sprite.png')

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'static')
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

         instance.physics.fixture:setUserData(instance)

         return instance
end

local spawn_amount = 1
local spawn_amount_cur = 1
function cactus:spawnMaze()
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
                  for i, row in ipairs(grid) do
                           for j, tile in ipairs(row) do
                                    if tile ~= 0 then
                                             if tile == 1 then
                                                      new_cactus = cactus.new('cactus', 50 * j - 10, 50 * i - 10, 45, 45, world)
                                                      table.insert(cacti, new_cactus)
                                             elseif tile == 2 then
                                                      new_fire = campfire.new('fire', 50 * j, 50 * i, 45, 45, world)
                                                      table.insert(campfires, new_fire)
                                             end
                                    end
                           end
                  end
                  spawn_amount_cur = spawn_amount_cur + 1
         end
end

local rows = 14
local inRows = 10

local spawngrid = {}

local amount = 0
local maxAmount = 4 

local function checkCacti(chkX, chkY)
         for i, v in ipairs(cacti) do
                  if chkX == v.x and chkY == v.y then
                           print('replacing cacti...')
                           return false
                  end
         end

         print('successfully spawned new cactus.')
         return true
end

function cactus:spawnRand()-- set as the amount of cacti needed
         for i = 1, rows do
                  for j = 1, inRows do
                           table.insert(spawngrid, {x = 50 * i, y = 50 * j})
                  end
         end

         local dice = math.random(#spawngrid)

         local num = 0
         if amount <= maxAmount then
                  while checkCacti(spawngrid[dice].x, spawngrid[dice].y) == false and num <= #cacti do
                           num = num + 1
                           dice = math.random(#spawngrid)
                  end         
                  if checkCacti(spawngrid[dice].x, spawngrid[dice].y) then
                           amount = amount + 1
                           new_cactus = cactus.new('cactus'..amount, spawngrid[dice].x, spawngrid[dice].y, 45, 45, world)
                           print(new_cactus.tag)
                           table.insert(cacti, new_cactus)
                  end
         end
end

function cactus:draw()
         for i, v in ipairs(cacti) do
                  love.graphics.draw(v.sprite, v.x, v.y, nil, v.scale)
                  love.graphics.polygon("line", v.physics.body:getWorldPoints(v.physics.shape:getPoints()))
         end
end

function cactus:killall()
         for i, v in ipairs(cacti) do
                  v.physics.fixture:destroy()
                  cacti[i] = nil
                  cacti = {}
         end
end
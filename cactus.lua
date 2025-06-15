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

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'static')
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

         instance.sprite = love.graphics.newImage('assets/sprites/cactus-sprite.png')

         return instance
end

local spawn_amount = 1
local spawn_amount_cur = 1
function cactus:spawnMaze()
         local grid = {
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                  {1, 0, 2, 0, 0, 1, 0, 2, 0, 0, 0, 2, 0, 1},
                  {1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1},
                  {1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1},
                  {1, 2, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1},
                  {1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2, 1},
                  {1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1},
                  {1, 2, 0, 0, 0, 1, 1, 2, 0, 0, 0, 0, 0, 1},
                  {1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1},
                  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
         }
         if spawn_amount_cur <= spawn_amount then
                  for i, row in ipairs(grid) do
                           for j, tile in ipairs(row) do
                                    if tile == 1 then
                                             new_cactus = cactus.new('cactus', 50 * j, 50 * i, 45, 45, world)
                                             table.insert(cacti, new_cactus)
                                    elseif tile == 2 then
                                             new_water = water.new('water', 50 * j, 50 * i, 45, 45, world)
                                             table.insert(waters, new_water)
                                    elseif tile == 3 then
                                             print('campfire')
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
function cactus:spawnRand()-- set as the amount of cacti needed

         for i = 1, rows do
                  for j = 1, inRows do
                           table.insert(spawngrid, {x = 50 * i, y = 50 * j})
                  end
         end

         if amount <= maxAmount then
                  local dice = math.random(#spawngrid)
                  new_cactus = cactus.new('cactus'..amount, spawngrid[dice].x, spawngrid[dice].y, 45, 45, world)
                  print(new_cactus.tag)
                  table.insert(cacti, new_cactus)
                  
                  amount = amount + 1
         end
end

function cactus:draw()
         for i, v in ipairs(cacti) do
                  love.graphics.draw(v.sprite, v.x, v.y, nil, v.scale)
                  love.graphics.polygon("line", v.physics.body:getWorldPoints(v.physics.shape:getPoints()))
         end
end

--[[
function cactus:damage(amount)
         if cactus:checkCollisions(self, player) == true then
                  
         end
end

function cactus:checkCollisions(a, b)
         if a.x + a.width > b.x and a.x < b.x + b.width and a.y + a.height > b.y and a.y < b.y + b.height then
                  return true
         end
end
]]
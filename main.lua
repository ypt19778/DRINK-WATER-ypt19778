require('audio')
require('player')
require('water')

collisions = ""
function onCollisionEnter(a, b, contact)
         local o1, o2 = a:getUserData(), b:getUserData()

         if o1 and o2 then
                  collisions = tostring(o1.tag.."colliding"..o2.tag)
         end
end

function onCollisionExit(a, b, contact)
         collisions = ""
end

function love.load()
         math.randomseed(os.time())
         love.graphics.setDefaultFilter('nearest', 'nearest')
         audio:init()

         world = love.physics.newWorld(0, 0)
         world:setCallbacks(onCollisionEnter, onCollisionExit)

         --format player (tag, x, y, width, height, speed, world)
         p = player.new('player', 400, 300, 50, 75, 100, world)

         --format water (tag, x, y, width, height)
         --wtr = water.new('water', 600, 300, 10, 10)
         --table.insert(waters,wtr)
end

function love.update(dt)
         world:update(dt)

         water:startSpawn(100)
         for i, v in ipairs(waters) do
                  v:update(dt)
                  if collisions == "playercolliding"..v.tag then
                           v:pickup(i)
                  end
         end

         p:move()
end

function love.draw()
         love.graphics.print(collisions, 10, 10)
         p:draw()

         for i, v in ipairs(waters) do
                  v:draw()
         end
end
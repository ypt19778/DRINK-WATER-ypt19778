require('audio')
require('player')
require('water')
require('bars')
gameover = require('game_over')

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
         game = {
                  font = love.graphics.newFont('assets/fonts/Gameplay.ttf'),
                  points = 0,
                  state = 'running'
         }

         math.randomseed(os.time())
         love.graphics.setDefaultFilter('nearest', 'nearest')
         audio:init()

         world = love.physics.newWorld(0, 0)
         world:setCallbacks(onCollisionEnter, onCollisionExit)

         --format player (tag, x, y, width, height, speed, world)
         p = player.new('player', 400, 300, 20, 35, 100, world)

         --format water (tag, x, y, width, height)
         
         --format bar (x, y, width, height, capacity)
         t_bar = thirst_bar.new(10, 10, 150, 10, 100)
end

function love.update(dt)
         world:update(dt)

         if game.state == 'running' then
                  water:startSpawn(100)
                  for i, v in ipairs(waters) do
                           v:update(dt)
                           if collisions == "playercolliding"..v.tag then
                                    v:pickup(i)
                                    t_bar.capacity = t_bar.capacity + t_bar.full_capacity
                           end
                  end

                  p:move()
                  p:update(dt)

                  t_bar:update(dt)
                  t_bar:drain(0.3)
         elseif game.state == 'game over' then
                  p.speed = 0
                  p.currentFrame = 2
         end
end

function love.draw()
         if game.state == 'running' then
                  --sand color 250, 200, 90
                  love.graphics.setBackgroundColor(250 / 255, 200 / 255, 90 / 255)
                  p:draw()
                  t_bar:draw()         
                  for i, v in ipairs(waters) do
                           v:draw()
                  end
         elseif game.state == 'game over' then
                  gameover:execute("GAME OVER", game.font, 250, 200, 4)
         end
end
-- pre-game must-haves 
require('audio')
love.audio.setVolume(1)
local system_audio_compatibility_ = love.audio.isEffectsSupported()
print(system_audio_compatibility_)

-- in-game functionalities
require('bars')
require('timer')
gameover = require('game_over')

-- "living" objects
require('player')
require('water')
require('cactus')

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

                  --all states:
                  --[[
                  game over: the game over screen
                  running: not
                  water stage: play the water minigame
                  cactus stage: play the cactus maze stage
                  cutscene(number): play the specified cutscene via cutscene number (0 - 3 are accepted)
                  ]]
                  state = 'water stage'
         }

         math.randomseed(os.time())
         love.graphics.setDefaultFilter('nearest', 'nearest')
         audio:init()

         world = love.physics.newWorld(0, 0)
         world:setCallbacks(onCollisionEnter, onCollisionExit)

         --format player (tag, x, y, width, height, speed, world)
         p = player.new('player', 400, 300, 20, 30, 100, world)

         --format water (tag, x, y, width, height)
         
         --format bar (x, y, width, height, capacity)
         t_bar = thirst_bar.new(10, 10, 150, 10, 100)

         --format cactus (x, y, width, height, world)

         --format timer (tag, time, color)
         water_stage_timer = timer.new('water stage timer', 50, {0, 0, 0})
end

function love.update(dt)
         world:update(dt)

         if game.state == 'water stage' then
                  p:move()
                  p:update(dt)

                  t_bar:update(dt)
                  t_bar:drain(0.2)

                  cactus:spawnRand()

                  water:startSpawn(100)
                  water:update(dt)

                  water_stage_timer:deplete(0.1)
                  print(water_stage_timer.time)
                  if water_stage_timer.time <= 0 then
                           p.physics.body:setPosition(400, 300)
                           game.state = 'cactus stage'
                  end
         elseif game.state == 'cactus stage' then
                  p:move()
                  p:update(dt)
                  t_bar:update(dt)
                  t_bar:drain(0.05)
                  cactus:spawnMaze()
                  water:update(dt)
         elseif game.state == 'game over' then
                  p.speed = 0
                  p.currentFrame = 2
         end
end

function love.draw()
         for i = 0, 3 do
                  if game.state == "cutscene"..i then
                           if i == 0 then
                                    print("lv0 test")
                           elseif i == 1 then
                                    print("lv1 test")
                           end
                  end
         end
         if game.state == 'water stage' then
                  --sand color 250, 200, 90
                  love.graphics.setBackgroundColor(250 / 255, 200 / 255, 90 / 255)

                  p:draw()

                  t_bar:draw()

                  cactus:draw()

                  water:draw()

                  water_stage_timer:draw()
         elseif game.state == 'cactus stage' then
                  water:killall()
                  
                  love.graphics.setBackgroundColor(0, 0, 0)

                  p:draw()
                  t_bar:draw()                   
                  cactus:draw()                  
                  water:draw()
         elseif game.state == 'game over' then
                  gameover:execute("GAME OVER...\n continue?", game.font, 250, 200, 4)
         end
end

function love.keypressed(k)
         if k == "escape" then
                  love.event.quit()
         end
end
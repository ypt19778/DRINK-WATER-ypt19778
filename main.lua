-- pre-game must-haves 
love.graphics.setDefaultFilter('nearest', 'nearest')
require('audio')
love.audio.setVolume(1)
local system_audio_compatibility_ = love.audio.isEffectsSupported()
print(system_audio_compatibility_)

-- in-game functionalities
require('bars')
require('timer')
gameover = require('game_over')

messageBubble = require('textBubbles')
local bubble_image_ = love.graphics.newImage('assets/sprites/msgbubble.png')
local bubble_font_ = love.graphics.newFont('assets/fonts/block.ttf')
messageBubble:setImage(bubble_image_)
messageBubble:setColor({0, 0, 0})
messageBubble:setFont(bubble_font_, 1)

-- "living" objects
require('player')
require('water')
require('cactus')
require('campfire')

collisions = "nil"
function onCollisionEnter(a, b, contact)
         local o1, o2 = a:getUserData(), b:getUserData()

         if o1 and o2 then
                  collisions = tostring(o1.tag.."colliding"..o2.tag)
         end
end

function onCollisionExit(a, b, contact)
         collisions = "nil"
end

function love.load()
         game = {
                  title = 'nul',
                  font = love.graphics.newFont('assets/fonts/Gameplay.ttf'),
                  --all states:
                  --[[
                  game over: the game over screen
                  running: not
                  water stage: play the water minigame
                  cactus stage: play the cactus maze stage
                  cactus juice stage: play the insanity that is the true cactus phase
                  cutscene(number): play the specified cutscene via cutscene number (0 - 3 are accepted)
                  ]]
                  state = 'cutscene0'
         }

         math.randomseed(os.time())
         audio:init()
         light_code = [[
                  #define NUM_LIGHTS 32

                  struct Light {
                           vec2 position;
                           vec3 diffuse;
                           float power;
                  };

                  extern Light lights[NUM_LIGHTS];
                  extern int num_lights;

                  extern vec2 screen;

                  const float constant = 1.0;
                  const float linear = 0.09;
                  const float quadratic = 0.032;

                  vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){
                           vec4 pixel = Texel(image, uvs);

                           vec2 norm_screen = screen_coords / screen;
                           vec3 diffuse = vec3(0);

                           for (int i = 0; i < num_lights; i++) {
                                    Light light = lights[i];
                                    vec2 norm_pos = light.position / screen;

                                    float distance = length(norm_pos - norm_screen) * light.power;
                                    float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
                                    diffuse += light.diffuse * attenuation;
                           }

                           diffuse = clamp(diffuse, 0.0, 1.0);

                           return pixel * vec4(diffuse, 1.0);
                  }
         ]]
         light = love.graphics.newShader(light_code)

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

local _countReset = true
local function _resetAvailable()
         _countReset = true
end
local function _reset()
         if _countReset == true then
                  water:killall()
                  cactus:killall()
                  campfire:killall()
                  p.physics.body:setPosition(400, 300)
                  _countReset = false
         end
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
                  campfire:update(dt)
         elseif game.state == 'game over' then
                  p.speed = 0
                  p.currentFrame = 2
         end
end

local intro_timer_ = 0
function love.draw()
         local mx, my = love.mouse.getPosition()

         love.graphics.print(collisions, p.x - 10, p.y - 10)
         for i = 0, 3 do
                  if game.state == "cutscene"..i then
                           if i == 0 then
                                    messageBubble:spawn(mx- 20, my - 50, 'Hello!', 3)
                                    love.graphics.setBackgroundColor(0, 0, 0.2)

                                    intro_timer_ = intro_timer_ + 0.3
                                    print(intro_timer_)

                                    love.graphics.print('this repository represents...\na game made in LÖVE2D...\n'..game.title..".", 0, 0, nil, 3)

                                    if intro_timer_ > 100 then
                                             game.state = 'cutscene1'
                                    end
                           elseif i == 1 then
                                    love.graphics.setBackgroundColor(250 / 255, 150 / 255, 50 / 255)

                                    messageBubble:spawn(100, 10, 'Friend:\nNice hike so far!', 5)
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
                  love.graphics.setBackgroundColor(0, 0, 0)
                  love.graphics.setShader(light)
                  light:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('num_lights', 3)
                  light:send('lights[0].position', {p.x + 15, p.y + 20})
                  light:send('lights[0].diffuse', {1, 1, 1})
                  light:send('lights[0].power', 250)

                  light:send('lights[1].position', {new_fire.x + 15 , new_fire.y + 15})
                  light:send('lights[1].diffuse', {1, 0.5, 0})
                  light:send('lights[1].power', 450)

                  water:killall()

                  p:draw()
                  t_bar:draw()                   
                  cactus:draw()                  
                  water:draw()
                  campfire:draw()
                  love.graphics.setShader()
         elseif game.state == 'game over' then
                  light:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('num_lights', 1)
                  light:send('lights[0].position', {love.graphics.getWidth() / 2, love.graphics.getHeight() / 2})
                  light:send('lights[0].diffuse', {1, 1, 1})
                  light:send('lights[0].power', 64)

                  gameover:execute("GAME OVER...\n continue?", game.font, 250, 200, 4)
         end

         love.graphics.draw(love.graphics.newImage('assets/sprites/ms cursor.png'), mx, my, nil, 3)
         love.mouse.setVisible(false)
end

function love.keypressed(k)
         if k == "escape" then
                  love.event.quit()
         end
         if k == "enter" and game.state == 'cutscene' then

         end
end
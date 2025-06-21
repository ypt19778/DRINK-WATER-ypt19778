-- pre-game must-haves 
love.graphics.setDefaultFilter('nearest', 'nearest')

require('audio')
love.audio.setVolume(1)
local system_audio_compatibility_ = love.audio.isEffectsSupported()
print(system_audio_compatibility_)

-- in-game functionalities
require('props')
require('bars')
require('timer')
gameover = require('game_over')

messageBubble = require('textBubbles')
local bubble_image_ = love.graphics.newImage('assets/sprites/msgbubble.png')
local bubble_font_ = love.graphics.newFont('assets/fonts/EASyText.ttf')
messageBubble:setImage(bubble_image_)
messageBubble:setColor({0, 0, 0})
messageBubble:setFont(bubble_font_, 1.8)
msg_ = 0

-- "living" objects
require('player')
require('water')
require('bushes')
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
                  title = 'FUN HIKE',
                  font = love.graphics.newFont('assets/fonts/EASyText.ttf'),
                  --all states:
                  --[[
                  game over: the game over screen
                  running: not
                  water stage: play the water minigame
                  bush stage: play the bush maze stage
                  cactus juice stage (p1, p2): play the insanity that is the true bush phase
                  cutscene(number): play the specified cutscene via cutscene number (0 - 3 are accepted)
                  ]]
                  state = 'cutscene0'
         }

         camera = require('assets/lib/camera')
         cam = camera()

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
         t_bar = thirst_bar.new(p.x, p.y, 90, 10, 85)

         --format bush (x, y, width, height, world)

         --format timer (tag, time, color)
         water_stage_timer = timer.new('water stage timer', 50, {0, 0, 0})
end

local event = 0
local timer = 0

prop_maze_dir = 'right'
function love.update(dt)
         prop:update(dt)
         world:update(dt)
         cam:lookAt(p.x, p.y)

         for i = 0, 5 do
                  if game.state == 'cutscene'..i then
                           if i == 1 then
                                    for i, v in ipairs(props) do
                                             v.x = v.x + 50 * dt
                                    end
                           elseif i == 2 then
                                    timer = timer + 0.1
                                    for i, v in ipairs(props) do
                                             if timer <= 30 then
                                                      v.animation.anim = love.graphics.newImage('assets/sprites/player-right-anim.png')
                                             elseif timer > 30 and timer < 60 then
                                                      v.animation.anim = love.graphics.newImage('assets/sprites/player-left-anim.png')
                                             elseif timer >= 60 then
                                                      v.animation.anim = love.graphics.newImage('assets/sprites/player-idle-anim.png')
                                                      timer = 0
                                             end
                                    end
                           elseif i == 5 then
                                    for i, v in ipairs(props) do
                                             v.animation.frameSpeed = 1
                                    end
                                    if msg_ < 2 then
                                             if Bob_prop_end and James_prop_end and Carl_prop_end then
                                                      Bob_prop_end.animation.anim = love.graphics.newImage('assets/sprites/cactus-sprite.png')
                                                      James_prop_end.animation.anim = love.graphics.newImage('assets/sprites/cactus-sprite.png')
                                                      Carl_prop_end.animation.anim = love.graphics.newImage('assets/sprites/cactus-sprite.png')
                                             end
                                    elseif msg_ >= 2 then
                                             Bob_prop_end.animation.anim = love.graphics.newImage('assets/sprites/player-idle-anim.png')
                                             James_prop_end.animation.anim = love.graphics.newImage('assets/sprites/player-idle-anim.png')
                                             Carl_prop_end.animation.anim = love.graphics.newImage('assets/sprites/player-idle-anim.png')
                                    end
                           end
                  end
         end

         if game.state == 'water stage' then
                  p:move()
                  p:update(dt)

                  t_bar:update(dt)
                  t_bar:drain(0.1)

                  bush:spawnRand()

                  water:startSpawn(200)
                  water:update(dt)

                  water_stage_timer:deplete(0.02)
                  if water_stage_timer.time <= 0 then
                           game.state = 'cutscene2'
                  end
         elseif game.state == 'bush stage' then
                  water:killall()
                  bush:spawnMaze()
                  p:move()
                  p:update(dt)
                  t_bar:update(dt)
                  t_bar:drain(0.05)
                  water:update(dt)
                  campfire:update(dt)
         elseif game.state == 'cactus juice stage p1' then     
                  if event ~= 1 then
                           p.physics.body:setPosition(400, 300)
                           bush:availablerand()
                           bush:spawnRand()
                           event = 1
                  end
                  p:move()
                  p:update(dt)
                  water:startSpawn(100)
                  water:update(dt)
                  if water:checkCollisions(p) == true then
                           event = 0
                           game.state = 'cutscene4'
                  end
         elseif game.state == 'cactus juice stage p2' then
                  if event ~= 1 then
                           p.physics.body:setPosition(400, 300)
                           bush:killall()
                           for i = 1, 3 do
                                    new_cactus = cactus.new('cactus'..i, 600, 600, 105, world)
                                    table.insert(cacti, new_cactus)
                           end
                           event = 1
                  end
                  p:move()
                  p:update(dt)
                  p.speed = 200
                  p.animation.frameSpeed = 8

                  bush:spawnSpots()

                  cactus:move(dt, p.x, p.y)

                  bush:update(dt)

                  if cactus:checkCollisions(p) == true then
                           game.state = 'cutscene5'
                  end      
         elseif game.state == 'game over' then
                  p.speed = 0
                  p.currentFrame = 2
         end
end

local intro_timer_ = 0

local event = 0

dirt = {
         love.graphics.newImage('assets/sprites/dirt-fill.png'),
         love.graphics.newImage('assets/sprites/dirt-fill-full.png')
}
wood = {
         love.graphics.newImage('assets/sprites/wood-stump-1.png'),
         love.graphics.newImage('assets/sprites/wood-stump-2.png'),
         love.graphics.newImage('assets/sprites/wood-stump-3.png')
}
leaves = {
         love.graphics.newImage('assets/sprites/branch-slope-up-fill.png'),
         love.graphics.newImage('assets/sprites/branch-slope-up-right.png'),
         love.graphics.newImage('assets/sprites/branch-slope-up-left.png'),
         love.graphics.newImage('assets/sprites/branch-merge-wood.png'),
         love.graphics.newImage('assets/sprites/branch-slope-down-right.png'),
         love.graphics.newImage('assets/sprites/branch-slope-down-left.png'),
         love.graphics.newImage('assets/sprites/branch-fill.png')
}
function love.draw()
         local mx, my = love.mouse.getPosition()

         --cutscene handler (very large for no reason)
         for i = 0, 5 do
                  if game.state == "cutscene"..i then
                           if i == 0 then
                                    msg_ = 0
                                    messageBubble:spawn(mx- 20, my - 50, 'Hello!', 3)
                                    love.graphics.setBackgroundColor(0, 0, 0)

                                    intro_timer_ = intro_timer_ + 0.3

                                    love.graphics.print('this repository represents...\na game made in LÖVE2D...\n'..game.title..".", 0, 0)

                                    if intro_timer_ > 50 then
                                             game.state = 'cutscene1'
                                    end
                           elseif i == 1 then
                                    love.graphics.setBackgroundColor(0, 0.1, 0)
                                    if event ~= 1 then
                                             Carl_prop_intro = prop.player(0, 490, 'right')
                                             table.insert(props, Carl_prop_intro)
                                             James_prop_intro = prop.player(0 + 50, 500, 'right')
                                             table.insert(props, James_prop_intro)
                                             Bob_prop_intro = prop.player(0 - 10, 520, 'right')
                                             table.insert(props, Bob_prop_intro)
                                             You_prop_intro = prop.player(0 - 60, 540, 'right')
                                             love.graphics.print('You', 390, 390)
                                             table.insert(props, You_prop_intro)
                                             event = 1
                                    end
                                    local grid = {
                                             {8, 13, 9, 8, 13, 13, 9, 8, 13, 13, 9, 8, 13, 9, 8, 9},
                                             {13, 7, 13, 13, 7, 13, 7, 13, 7, 7, 13, 13, 7, 13, 7, 13},
                                             {13, 7, 13, 13, 7, 13, 7, 13, 7, 7, 13, 13, 7, 13, 7, 13},
                                             {12, 10, 11, 12, 10, 11, 10, 11, 10, 7, 11, 12, 10, 11, 10, 11},
                                             {0, 5, 0, 0, 3, 0, 5, 0, 4, 3, 0, 0, 4, 0, 5, 0},
                                             {0, 4, 0, 0, 3, 0, 4, 0, 5, 5, 0, 0, 5, 0, 5, 0},
                                             {0, 3, 0, 0, 4, 0, 3, 0, 5, 4, 0, 0, 4, 0, 4, 0},
                                             {0, 3, 0, 0, 5, 0, 5, 0, 5, 3, 0, 0, 5, 0, 3, 0},
                                             {0, 4, 0, 0, 4, 0, 4, 0, 3, 3, 0, 0, 4, 0, 5, 0},
                                             {0, 3, 0, 0, 3, 0, 3, 0, 3, 3, 0, 0, 3, 0, 3, 0},
                                             {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                                             {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
                                    }

                                    for index_row, row in ipairs(grid) do
                                             for index_tile, tile in ipairs(row) do
                                                      for index_dirt, v in pairs(dirt) do
                                                               if tile == index_dirt then
                                                                        love.graphics.draw(dirt[index_dirt], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)    
                                                               end
                                                      end
                                                      for index_wood, v in pairs(wood) do
                                                               if tile == (index_wood + 2) then
                                                                        love.graphics.draw(wood[index_wood], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)
                                                               end
                                                      end
                                                      for index_leaves, v in pairs(leaves) do
                                                               if tile == (index_leaves + 6) then
                                                                        love.graphics.draw(leaves[index_leaves], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)
                                                               end
                                                      end
                                             end
                                    end

                                    local messages = {
                                             'Carl:\nNice hike so far!',
                                             'James, Bob, and You:\nYeah!',
                                             'You:\nIm a little thirsty \nthough.',
                                             'Carl:\nWell met!\nGo and get yourself some\nwater.',
                                             'You:\nAgreed.',
                                             'USE W TO MOVE UP',
                                             'USE A TO MOVE LEFT',
                                             'USE S TO MOVE DOWN',
                                             'USE D TO MOVE RIGHT.',
                                             'FILL UP THE BAR BELOW\nTHE PLAYER BY WALKING\nOVER TO A WATER DROP.',
                                             'DON\'T LET THE BAR DROP\nTO ZERO!'
                                    }

                                    if msg_ <= #messages then
                                             messageBubble:spawn(200, 200, 'PRESS ENTER OR M1 TO\nCONTINUE', 7)
                                    end

                                    for i, v in ipairs(messages) do
                                             if msg_ == i-1 then
                                                      messageBubble:spawn(200, 100, messages[i], 7)
                                             end
                                    end

                                    if msg_ > #messages then
                                             prop:killall()
                                             print('transferring stage to water stage')
                                             event = 0
                                             game.state = 'water stage'
                                    end

                           elseif i == 2 then
                                    love.graphics.setBackgroundColor(0, 0, 0.1)
                                    if event ~= 1 then
                                             msg_ = 0
                                             You_prop_maze = prop.player(400, 400, prop_maze_dir)
                                             love.graphics.print('You', 390, 390)
                                             table.insert(props, You_prop_maze)
                                             event = 1
                                    end

                                    local messages = {
                                             'You:\nGuys?',
                                             '...',
                                             'You:\nGUYSS?!?!',
                                             '...',
                                             'You:\nWHERE ARE YOU ALL?',
                                             '...',
                                             'You:\nSigh...',
                                             'You:\nIt looks about nighttime.',
                                             'You:\nI should get some sleep.',
                                             '...',
                                             'You:\nIs that a campfire?'
                                    }

                                    if msg_ <= #messages then
                                             messageBubble:spawn(200, 200, 'PRESS ENTER OR M1 TO\nCONTINUE', 7)
                                    end

                                    for i, v in ipairs(messages) do
                                             if msg_ == i-1 then
                                                      messageBubble:spawn(200, 100, messages[i], 7)
                                             end
                                    end

                                    if msg_ >= #messages then
                                             prop:killall()
                                             p.physics.body:setPosition(400, 300)
                                             print('transferring stage to bush stage')
                                             event = 0
                                             timer = 0
                                             game.state = 'bush stage'
                                    end
                           elseif i == 3 then
                                    if event ~= 1 then
                                             msg_ = 0
                                             event = 1
                                    end

                                    local messages = {
                                             'You:\nZzz...\nZzz...',
                                             'Voices:\nDrInK iTtTt~~...',
                                             'You:\nHuh?',
                                             'You:\nWait, where am I?'
                                    }
                                    if msg_ <= #messages then
                                             messageBubble:spawn(200, 200, 'PRESS ENTER OR M1 TO\nCONTINUE', 7)
                                    end

                                    for i, v in ipairs(messages) do
                                             if msg_ == i-1 then
                                                      messageBubble:spawn(200, 100, messages[i], 7)
                                             end
                                    end

                                    if msg_ > #messages then
                                             game.state = 'cactus juice stage p1'
                                             event = 0
                                    end
                           elseif i == 4 then
                                    love.graphics.setBackgroundColor(0, 0.3, 0)
                                    if event ~= 1 then
                                             msg_ = 0
                                             event = 1
                                    end

                                    local messages = {
                                             'You:\n*slurp*',
                                             'You:\nWoaahhh\nI don\'t feel so\n good...',
                                             '???:\nDo you know where\nhe is?',
                                             '???:\nNo.',
                                             '???:\nTHERE HE IS!!!',
                                             '???:\nGET HIM!!!', 
                                             'PRESS (W, A, S, D) KEYS\nTO RUN',
                                    }
                                    if msg_ <= #messages then
                                             messageBubble:spawn(200, 200, 'PRESS ENTER OR M1 TO\nCONTINUE', 7)
                                    end

                                    for i, v in ipairs(messages) do
                                             if msg_ == i-1 then
                                                      messageBubble:spawn(200, 100, messages[i], 7)
                                             end
                                    end

                                    if msg_ > #messages then
                                             game.state = 'cactus juice stage p2'
                                             event = 0
                                    end
                           elseif i == 5 then
                                    love.graphics.setBackgroundColor(0, 0.1, 0)
                                    if event ~= 1 then
                                             msg_ = 0
                                             Carl_prop_end = prop.player(640, 435, 'idle')
                                             table.insert(props, Carl_prop_end)
                                             James_prop_end = prop.player(600, 417, 'idle')
                                             table.insert(props, James_prop_end)
                                             Bob_prop_end = prop.player(580, 450, 'idle')
                                             table.insert(props, Bob_prop_end)
                                             You_prop_end = prop.player(300, 423, 'idle')
                                             table.insert(props, You_prop_end)
                                             event = 1
                                    end
                                    local grid = {
                                             {3, 7, 4, 4, 7, 5, 7, 3, 7, 3, 3, 7, 5, 7, 4, 7},
                                             {4, 12, 5, 4, 11, 5, 7, 4, 7, 5, 4, 12, 3, 12, 5, 11},
                                             {3, 0, 4, 4, 0, 5, 11, 5, 12, 4, 3, 0, 5, 0, 4, 0},
                                             {5, 0, 5, 4, 0, 5, 0, 4, 0, 5, 4, 0, 4, 0, 5, 0},
                                             {4, 0, 4, 4, 0, 5, 0, 5, 0, 4, 5, 0, 3, 0, 4, 0},
                                             {3, 0, 3, 3, 0, 5, 0, 4, 0, 3, 4, 0, 4, 0, 5, 0},
                                             {4, 0, 4, 3, 0, 5, 0, 3, 0, 4, 3, 0, 5, 0, 4, 0},
                                             {3, 0, 3, 3, 0, 5, 0, 3, 0, 4, 3, 0, 3, 0, 3, 0},
                                             {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                                             {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
                                             {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
                                             {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
                                    }

                                    for index_row, row in ipairs(grid) do
                                             for index_tile, tile in ipairs(row) do
                                                      for index_dirt, v in pairs(dirt) do
                                                               if tile == index_dirt then
                                                                        love.graphics.draw(dirt[index_dirt], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)    
                                                               end
                                                      end
                                                      for index_wood, v in pairs(wood) do
                                                               if tile == (index_wood + 2) then
                                                                        love.graphics.draw(wood[index_wood], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)
                                                               end
                                                      end
                                                      for index_leaves, v in pairs(leaves) do
                                                               if tile == (index_leaves + 6) then
                                                                        love.graphics.draw(leaves[index_leaves], index_tile * 50 - 50, index_row * 50 - 50, nil, 5)
                                                               end
                                                      end
                                             end
                                    end
                                    love.graphics.print('You', 300, 410)
                                    local messages = {
                                             '???:\n*pant*\nHEY!\n*pant*',
                                             '???:\n*pant*\nSTOP RUNNING!!!\n*wheeze*',
                                             'You:\nCarl?',
                                             'Carl:\nYEAH!',
                                             'You:\nBut I thought I lost you\nguys???',
                                             'Carl:\nWe thought we lost you!',
                                             'James, Bob, and Carl:\nBut then we spotted you...',
                                             'James, Bob, and Carl:\nAND YOU WERE RUNNING\nAROUND LIKE A CRAZY\nLUNATIC!',
                                             'You:\nWhat...?',
                                             'James, Bob, and Carl:\nYEAH!',
                                             'Carl:\nFirst you went around\nand around bushes...',
                                             'You:\nSounds familiar...',
                                             'Carl:\nThen you went through \nthe UNCHARTED parts of\nthe forest',
                                             'Carl:\nAnd we couldn\'t find you\nfor a WHOLE night!',
                                             'You:\nHuh...',
                                             'Carl:\nAnd this morning we\nfound you...',
                                             'Carl:\nAnd you started\nrunning AWAY!',
                                             'You:\nBut I was running\naway from cacti!',
                                             'You:\n...Right?',
                                             'Carl:\nYou were running\naway from US!\nwait...',
                                             'Carl:\nHave you been drinking \nthat green cactus\njuice around here..?',
                                             'You:\n...no...', 
                                             'Carl:\nOh okay...Let\'s just do\nthe hike already.',
                                             'James, Bob, and You:\nAlright!',
                                             'You:\nWhat was that water\ngreen for...'
                                    }

                                    if msg_ <= #messages then
                                             messageBubble:spawn(200, 200, 'PRESS ENTER OR M1 TO\nCONTINUE', 7)
                                    end

                                    for i, v in ipairs(messages) do
                                             if msg_ == i-1 then
                                                      messageBubble:spawn(200, 100, messages[i], 7)
                                             end
                                    end
                                    if msg_ >= 3 then
                                             love.graphics.print('Bob', 580, 440)
                                             love.graphics.print('Carl', 640, 425)
                                             love.graphics.print('James', 600, 407)
                                    end

                                    if msg_ > #messages then
                                             game.state = 'the end'
                                    end
                                    -- opt pictures of the hike shown at credits screen
                                    -- The end... cutscene not made yet.
                           end
                  end
         end

         if game.state == 'water stage' then
                  time_of_day = -water_stage_timer.time
                  love.graphics.setShader(light)                  
                  light:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('num_lights', 3)
                  light:send('lights[0].position', {0, 0})
                  light:send('lights[0].diffuse', {1, 1, 1})
                  light:send('lights[0].power', 40 + time_of_day)
                  light:send('lights[1].position', {love.graphics.getWidth(), 0})
                  light:send('lights[1].diffuse', {1, 1, 1})
                  light:send('lights[1].power', 40 + time_of_day)
                  light:send('lights[2].position', {0, love.graphics.getHeight()})
                  light:send('lights[2].diffuse', {1, 1, 1})
                  light:send('lights[2].power', 40 + time_of_day) 
                  light:send('lights[3].position', {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('lights[3].diffuse', {1, 1, 1})
                  light:send('lights[3].power', 40 + time_of_day)
                  love.graphics.setBackgroundColor(70 / 255, 40 / 255, 0)
                  bush:draw()
                  water:draw()
                  p:draw()
                  love.graphics.setShader()
                  t_bar:draw()
         elseif game.state == 'bush stage' then
                  love.graphics.setBackgroundColor(0, 0, 0)
                  love.graphics.setShader(light)         
                  p:draw()
                  bush:draw()
                  water:draw()
                  campfire:draw()

                  light:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('num_lights', 2)
                  light:send('lights[0].position', {p.x + 15, p.y + 20})
                  light:send('lights[0].diffuse', {1, 1, 1})
                  light:send('lights[0].power', 150)

                  for i,v in pairs(campfires) do
                           light:send('lights[1].position', {v.x + 15 , v.y + 15})
                           light:send('lights[1].diffuse', {1, 0.5, 0})
                           light:send('lights[1].power', 450)
                  end

                  love.graphics.setShader()
                  t_bar:draw()  
         elseif game.state == 'cactus juice stage p1' then
                  love.graphics.setBackgroundColor(180 / 255, 100 / 255, 0)

                  p:draw()
                  bush:draw()

                  love.graphics.setColor(0, 1, 0)
                           water:draw()
                  love.graphics.setColor(1, 1, 1)
         elseif game.state == 'cactus juice stage p2' then
                  cam:attach()
                           p:draw()
                           bush:draw()
                           cactus:draw()
                  cam:detach()
         elseif game.state == 'game over' then
                  light:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
                  light:send('num_lights', 1)
                  light:send('lights[0].position', {love.graphics.getWidth() / 2, love.graphics.getHeight() / 2})
                  light:send('lights[0].diffuse', {1, 1, 1})
                  light:send('lights[0].power', 64)

                  gameover:execute("GAME OVER", game.font, 250, 200, 4)
         elseif game.state == 'the end' then
                  prop:killall()
                  love.graphics.setBackgroundColor(0, 0, 0.1)
                  love.graphics.print("THE END", 300, 200, nil, 5)
         end

         love.graphics.draw(love.graphics.newImage('assets/sprites/ms cursor.png'), mx, my, nil, 3)
         love.mouse.setVisible(false)
         prop:draw()
end

function love.keypressed(k)
         if k == "escape" then
                  love.event.quit()
         end
         if k == "return" then
                  msg_ = msg_ + 1
         end
end

function love.mousepressed(x, y, button)
         if button == 1 then
                  msg_ = msg_ + 1
         end
end
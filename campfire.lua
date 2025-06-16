campfires = {}

campfire = {}
campfire.__index = campfire

function campfire.new(tag, x, y, width, height, world)
         local instance = setmetatable({}, campfire)
         instance.tag = tag

         instance.x = x
         instance.y = y
         instance.width = width
         instance.height = height

         instance.animation = {
                  frameSpeed = 7,
                  currentFrame = 1,
                  spriteSheet = love.graphics.newImage('assets/sprites/campfire-anim.png'),
                  frames = {}
         }

         instance.psystem_img = love.graphics.newImage('assets/sprites/cfember.png')
         instance.psystem = love.graphics.newParticleSystem(instance.psystem_img, 1000)
         instance.psystem:setEmissionArea('normal', 3, 3)
         instance.psystem:setLinearDamping(10)
         instance.psystem:setLinearAcceleration(0, -100)
         instance.psystem:setParticleLifetime(1.3)
         instance.psystem:setRadialAcceleration(-110, 100)
         instance.psystem:setSpin(200)
         instance.psystem:setSpinVariation(10)
         instance.psystem:setSizeVariation(0.5)

         local fw = 10
         local fh = 10
         local sw = instance.animation.spriteSheet:getWidth()
         local sh = instance.animation.spriteSheet:getHeight()

         for i = 0, 4 do
                  table.insert(instance.animation.frames, love.graphics.newQuad(i * fw, 0, fw, fh, sw, sh))
         end

         instance.physics = {}
         instance.physics.body = love.physics.newBody(world, instance.x, instance.y, 'static')
         instance.physics.shape = love.physics.newRectangleShape(instance.width / 2, instance.height / 2, instance.width, instance.height)
         instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
         instance.physics.body:setFixedRotation(true)

         instance.physics.fixture:setUserData(instance)

         return instance
end

function campfire:update(dt)
         for i, v in ipairs(campfires) do
                  if collisions == 'playercolliding'..v.tag then
                           game.state = 'cactus juice stage'
                           cactus:killall()
                           campfire:killall()
                           t_bar.capacity = t_bar.capacity + t_bar.full_capacity
                  end

                  v.psystem:update(dt)

                  v.animation.currentFrame = v.animation.currentFrame + v.animation.frameSpeed * dt
                  local emit_dice = math.random(150)
                  if emit_dice == 1 then
                           v.psystem:emit(50)
                  end

                  v.frameSpeed = math.random(5, 15)
                  if v.animation.currentFrame >= 5 then
                           v.animation.currentFrame = 1
                  end
         end
end

function campfire:draw()
         for i, v in ipairs(campfires) do
                  love.graphics.draw(v.psystem, v.x + 15, v.y, nil, 3)

                  love.graphics.draw(v.animation.spriteSheet, v.animation.frames[math.floor(v.animation.currentFrame)], v.x, v.y, nil, 3)
         end
end

function campfire:killall()
         for i, v in ipairs(campfires) do
                  v.physics.fixture:destroy()
                  campfires[i] = nil
                  campfires = {} 
         end
end
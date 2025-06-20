props = {}

prop = {}
prop.__index = prop

function prop.player(x, y, dir)
         local prop = setmetatable({}, props)
         prop.x = x
         prop.y = y

         prop.animation = {
                  frameSpeed = 5,
                  currentFrame = 1,
                  frames = {}
         }
         if dir == 'idle' then
                  prop.animation.anim = love.graphics.newImage('assets/sprites/player-idle-anim.png')
         elseif dir == 'left' then
                  prop.animation.anim = love.graphics.newImage('assets/sprites/player-left-anim.png')
         elseif dir == 'right' then
                  prop.animation.anim = love.graphics.newImage('assets/sprites/player-right-anim.png')
         elseif dir == 'up' then
                  prop.animation.anim = love.graphics.newImage('assets/sprites/player-up-anim.png')
         elseif dir == 'down' then
                  prop.animation.anim = love.graphics.newImage('assets/sprites/player-down-anim.png')
         end
         prop.scale = 3

         local sprite_width = 28
         local sprite_height = 11
         local frame_width = 7
         local frame_height = 11
         for i = 0, 4 do
                  table.insert(prop.animation.frames, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, sprite_width, sprite_height))
         end

         return prop
end

function prop:move(x, speed)
         x = x + speed
end

function prop:update(dt)
         for i, v in pairs(props) do
                  v.animation.currentFrame = v.animation.currentFrame + v.animation.frameSpeed * dt
                  if v.animation.currentFrame > #v.animation.frames then v.animation.currentFrame = 1 end
         end
end

function prop:draw()
         for i, v in pairs(props) do
                  love.graphics.draw(v.animation.anim, v.animation.frames[math.floor(v.animation.currentFrame)], v.x, v.y, nil, v.scale)
         end
end

function prop:killall()
         for i, v in ipairs(props) do
                  v[i] = nil
                  props = {}
         end
end
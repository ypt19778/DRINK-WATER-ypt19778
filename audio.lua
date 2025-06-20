audio = {}

love.audio.setEffect('effect_distortion', {
         type = 'distortion',
         gain = 100,
         edge = 400
})

love.audio.setEffect('effect_echo', {
         type = 'echo',
         tapdelay = 0.1,
         feedback = 1,
         spread = 2
})

function audio:init()
         sounds = {
                  talk = {
                           one = love.audio.newSource('assets/audio/talk.mp3', 'static'),
                           two = love.audio.newSource('assets/audio/talk2.mp3', 'static'),
                           three = love.audio.newSource('assets/audio/talk3.mp3', 'static')
                  },
                  walk = {
                           one = love.audio.newSource('assets/audio/walk.mp3', 'static'),
                           two = love.audio.newSource('assets/audio/walk2.mp3', 'static'),
                           three = love.audio.newSource('assets/audio/walk3.mp3', 'static')
                  },
                  drink = {
                           one = love.audio.newSource('assets/audio/drink.mp3', 'static'),
                  }
         }
         --sounds.drink.one:setEffect('effect_distortion', true)
         sounds.drink.one:setPitch(1)
end
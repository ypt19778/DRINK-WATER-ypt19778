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
                  drink = {
                           one = love.audio.newSource('assets/audio/drink water.mp3', 'static'),
                  },
         }
         --sounds.drink.one:setEffect('effect_distortion', true)
         sounds.drink.one:setPitch(1)
end
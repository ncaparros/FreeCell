require 'Util'
require 'Card'
require 'Board'

Deck = Class{}

CardWidth = 923/13
CardHeight = 576/6

math.randomseed(os.time())

function Deck:init()
    self.spritesheet = love.graphics.newImage('img/cards.png')
    self.sprites = generateQuads(self.spritesheet, CardWidth, CardHeight)
    self.cards = {}

    i = 0
    while i < 52 do
        rand = math.random(52)
        if contains(self.cards, rand) == false then
            self.cards[i] = rand
            i = i + 1            
        end
    end

end



function Deck:update(dt)

end

function Deck:render()
    --love.graphics.draw(self.spritesheet, self.sprites[1], 50, 50)
    for i = 0, 8 do
        --love.graphics.draw(self.spritesheet, self.sprites[self.cards[i]], CardWidth/2 +  i * CardWidth + 10 * i, 2 * CardHeight)
    end
end

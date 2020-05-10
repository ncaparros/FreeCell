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
end

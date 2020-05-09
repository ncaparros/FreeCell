Class = require 'class'
push = require 'push'

require 'Board'
require 'Card'
require 'Deck'
require 'FreeCell'

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 720

board = Board()

function love.load()
    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })
end


function love.update(dt)
    board:update(dt)
end

function love.draw()
-- begin virtual resolution drawing
    push:apply('start')
    love.window.setTitle("Nina's CS50 FreeCell")

    -- clear screen using Mario background blue
    love.graphics.clear(62/255, 193/255, 96/255, 255/255)
    board:render()
    -- end virtual resolution
    push:apply('end')
end


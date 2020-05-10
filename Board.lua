require 'Util'

Board = Class{}



CardWidth = 923/13
CardHeight = 576/6

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 720

START_BOARD = 2 * CardHeight 
LEFT_BOARD = CardWidth + 20

TOP_X = 20

function Board:init()

    self.sounds = {
        ['forbidden'] = love.audio.newSource('sounds/forbidden.wav', 'static'),
        ['move'] = love.audio.newSource('sounds/move.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
    }

    self.deck = Deck(self)

    self.freeCells = {}
    for i = 0, 3 do
        self.freeCells[i] = FreeCell(self)
        --self.freeCells[i].isFree = true
        self.freeCells[i]:set(true, 20 + (5 * i) + i * CardWidth, TOP_X)
    end

    for i = 0, 7 do
        self.freeCells[i + 4] = FreeCell(self)
        self.freeCells[i + 4]:set(false, LEFT_BOARD + i * (5 + CardWidth), START_BOARD)
    end

    self.nFreeCells = 4

    self.homeCells = {}
    for i = 0, 3 do
        self.homeCells[i] = FreeCell(self)
        self.homeCells[i]:set(true, WINDOW_WIDTH - (4 - i) * CardWidth - ((3 - i) * 5 + 20), TOP_X)
    end
    self.nHomeCell = 0
    self.boardCards = {}

    for i = 0, 51 do
        self.boardCards[i] = Card(self)
        self.boardCards[i]:setSprite(self.deck.sprites[self.deck.cards[i]])
        self.boardCards[i]:setId(self.deck.cards[i])

        --13 : king
        if self.deck.cards[i] % 13 == 0 then
           self.boardCards[i]:setValue(13)
        else
            self.boardCards[i]:setValue(self.deck.cards[i] % 13)
        end

        if self.deck.cards[i] <= 13 then
            self.boardCards[i]:setColor("s")
        elseif self.deck.cards[i] <= 26 then
            self.boardCards[i]:setColor("h")
        elseif self.deck.cards[i] <= 39 then
            self.boardCards[i]:setColor("c")
        else
            self.boardCards[i]:setColor("d")
        end
        
    end

    self:deal()
    

    for i = 0, 51 do
        self.boardCards[i]:setLock(self.nFreeCells)
        self.boardCards[i].locked = true
    end

    self.state = 'start'
    self:render()
end

function Board:update(dt)
    if self.state == 'start' then
        if love.mouse.isDown(1) then
            self.state = 'click'
            card = self:getCardAt(love.mouse.getX(), love.mouse.getY())
            if card == nil or card == - 1 then
                self.state = 'start'
                self.sounds['forbidden']:play()
            else
                if self:isForHome(card) then
                    self.sounds['move']:play()
                elseif self:isForOtherCard(card) then
                    self.sounds['move']:play()
                elseif self:isForBoardFreeCell(card) then
                    self.sounds['move']:play()
                elseif self:isForFreeCell(card) then
                    self.sounds['move']:play()
                    local tempCell = -1
                    if card.onFreeCell == true then
                        self:freeFreeCell(card)
                    end

                    for i = 0, 11 do
                        if self.freeCells[i].isFree == true then
                            self.freeCells[i]:toString()

                            if card.previous ~= nil and
                            card.previous ~= -1 then
                                card.previous:setNextCard(-1)
                            end
                            card:setCoords(self.freeCells[i].x, self.freeCells[i].y)
                            card:setPreviousCard(-1)
                            card:setNextCard(-1)
                            card:setOnFreeCell(true)
                            self.freeCells[i].card = card
                            self.freeCells[i]:update(dt)
                            self.freeCells[i]:toString()

                            break
                        end
                    end
                else
                    self.sounds['forbidden']:play()
                end
                self:calculateNFreeCells()
                
            end
            self:calculateNFreeCells()
            for i = 0, 51 do
                self.boardCards[i]:setLock(self.nFreeCells)
                self.boardCards[i]:setLockedForEnd()
            end
            --self.state = 'start'

        end
        
        self:render()
    elseif self.state == 'click' and
    love.mouse.isDown(1) == false then
        self.state = 'start'
    elseif self.state == 'finish' then
        self:finishGame()
        self:calculateNFreeCells()
        self:render()
    end

    if self:isNoMoreLock() then
        self.state = 'finish'
        self:render()
    end

    if self.nHomeCell == 52 then
        self.state = 'victory'
        self.sounds['victory']:play()
    end

end

function Board:isNoMoreLock()
    for i = 0, 51 do
        if self.boardCards[i].locked 
        and self.boardCards[i].onHomeCell == false then
            return false
        end
    end
    return true
end

function Board:finishGame()
    for i = 0, 51 do
        if self.boardCards[i].onHomeCell == false and
        (self.boardCards[i].next == nil or
        self.boardCards[i].next == -1) then
            if self:isForHome(self.boardCards[i]) == true then
                self.sounds['move']:play()
                local t = os.clock()
                --timer to slow animation
                while os.clock() < t + 0.1 do 
                end
                return
            end 
        end
    end
end

function Board:calculateNFreeCells()
    local n = 0
    for i = 0, 3 do
        if self.freeCells[i].isFree then
            n = n + 1
        end
    end
    for i = 4, 11 do
        if self.freeCells[i].card == nil or 
        self.freeCells[i].card == - 1 then
            n = n + 1
        end
    end
    self.nFreeCells = n
end

function Board:isForOtherCard(card)

    for i = 0, 51 do 
        if self.boardCards[i].lock == false and
        self.boardCards[i].value - 1 == card.value and
        self.boardCards[i].isBlack ~= card.isBlack and
        (self.boardCards[i].onFreeCell == false or
        self.boardCards[i].y == START_BOARD) and
        self.boardCards[i].onHomeCell == false and
        (self.boardCards[i].next == nil or self.boardCards[i].next == -1) then

            if card.previous ~= nil and
            card.previous ~= - 1 then
                card.previous:setNextCard(-1)
            elseif card.onFreeCell then
                self:freeFreeCell(card)
            end
            card:setCoords(self.boardCards[i].x, self.boardCards[i].y + 30)
            self.boardCards[i]:setNextCard(card)
            card:moveNexts()
            card:setPreviousCard(self.boardCards[i])                               
            return true
        end
    end
    return false
end

function Board:isForHome(card)
    if card.next == nil or
    card.next == - 1 then
        for i = 0, 3 do

            if card.value == 1 
            and (self.homeCells[i].card == nil or
            self.homeCells[i].card == -1) then

                if card.previous ~= nil and 
                card.previous ~= - 1 then
                    card.previous:setNextCard(-1)
                    card:setPreviousCard(-1)
                elseif card.onFreeCell then
                        self:freeFreeCell(card) 
                end

                self.homeCells[i].card = card
                self.homeCells[i].color = card.color
                card.x = self.homeCells[i].x
                card.y = self.homeCells[i].y


                card:setOnHomeCell()
                self.nHomeCell = self.nHomeCell + 1
                return true

            elseif self.homeCells[i].color == card.color and
            self.homeCells[i].card ~= nil and
            self.homeCells[i].card ~= -1 then
                
                local val = self:getLastCard(self.homeCells[i].card).value
                
                if val == card.value - 1 then

                    if card.previous ~= nil and
                    card.previous ~= - 1 then
                        card.previous:setNextCard(-1)             
                    end

                    if card.onFreeCell then
                        self:freeFreeCell(card)
                    end
                    
                    self:getLastCard(self.homeCells[i].card).next = card
                    card:setOnHomeCell()
                    card.x = self.homeCells[i].x
                    card.y = self.homeCells[i].y
                    self.nHomeCell = self.nHomeCell + 1
                    self.homeCells[i].card:render()
                    return true
                else
                    return false
                end
            end
        end
        return false
    else
        return false
    end
end

function Board:freeFreeCell(card)
    for i = 0, 11 do
        if self.freeCells[i].x == card.x and
        self.freeCells[i].y == card.y then
            self.freeCells[i].card = -1
            self.freeCells[i].isFree = true
            card.onFreeCell = false
            break
        end
    end
end

function Board:getLastCard(card)

    if card.next == nil or
    card.next == -1 then
        return card
    else
        return self:getLastCard(card.next)
    end
end

function Board:isForBoardFreeCell(card)
    if self.nFreeCells > 0 and 
    card.lock == false then
        for i = 4, 11 do
            if self.freeCells[i].isFree then
                self:freeFreeCell(card)
                self.freeCells[i].card = card
                self.freeCells[i].isFree = false
                card.x = self.freeCells[i].x
                card.y = self.freeCells[i].y
                card.onFreeCell = true
                if card.previous ~= nil and
                card.previous ~= -1 then
                    card.previous.next = -1
                end
                card.previous = - 1
                card:moveNexts()
                return true
            end
        end
        return false
    else
        return false
    end
end


function Board:isForFreeCell(card)
    if self.nFreeCells > 0 and 
    card.lock == false and 
    card.onHomeCell == false and
    (card.next == nil or card.next == -1) then
        return true
    else
        return false
    end
end

function Board:getCardAt(x, y)
    for i = 51, 0, - 1 do
        if self.boardCards[i]:isAtCoords(x, y) and 
        self.boardCards[i].lock == false then
            self.boardCards[i]:toString()
            return self.boardCards[i]
        end
    end
    return - 1
end

function Board:render()
    love.graphics.setFont(love.graphics.newFont('fonts/font.otf', 20))

    love.graphics.print(tostring(self.nFreeCells) .. " - " .. tostring(self.nHomeCell), WINDOW_WIDTH/2 - 20, 20)

    if self.state == 'victory' then
        love.graphics.setFont(love.graphics.newFont('fonts/font.otf', 40))
        love.graphics.print("VICTORY !", WINDOW_WIDTH/2 - 40, WINDOW_HEIGHT/2 - 20)
    elseif self.state == 'finish' then
        love.graphics.setFont(love.graphics.newFont('fonts/font.otf', 40))
        love.graphics.print("FINISH !", WINDOW_WIDTH/2 - 40, START_BOARD - 60)
    end

    for i = 0, 3 do
        self.freeCells[i]:render()
        self.homeCells[i]:render()
    end

    for i = 0, 51 do
        if self.boardCards[i].onFreeCell and 
        (self.boardCards[i].next == nil or 
        self.boardCards[i].next == -1) then

            love.graphics.draw(self.deck.spritesheet, self.deck.sprites[self.boardCards[i].id], self.boardCards[i].x, self.boardCards[i].y)

        elseif self.boardCards[i].previous == nil or
        self.boardCards[i].previous == -1 then

            self.boardCards[i]:render()
        end
    end
end

function Board:deal()
    for i = 0, 6 do
        self.boardCards[i]:setCoords(LEFT_BOARD, START_BOARD + i * 30)
        self.boardCards[i + 7]:setCoords(CardWidth + LEFT_BOARD + 5, START_BOARD + i * 30)
        self.boardCards[i + 14]:setCoords(LEFT_BOARD + 2 * CardWidth + 10, START_BOARD + i * 30)
        self.boardCards[i + 21]:setCoords(LEFT_BOARD + 3 * CardWidth + 15, START_BOARD + i * 30)

        if i == 0 then
            self.freeCells[4].card = self.boardCards[0]
            self.boardCards[0].onFreeCell = true
            self.freeCells[5].card = self.boardCards[7]
            self.boardCards[7].onFreeCell = true
            self.freeCells[6].card = self.boardCards[14]
            self.boardCards[14].onFreeCell = true
            self.freeCells[7].card = self.boardCards[21]
            self.boardCards[21].onFreeCell = true
        end

        if i > 0 then
            self.boardCards[i]:setPreviousCard(self.boardCards[i - 1])
            self.boardCards[i + 7]:setPreviousCard(self.boardCards[i + 6])
            self.boardCards[i + 14]:setPreviousCard(self.boardCards[i + 13])
            self.boardCards[i + 21]:setPreviousCard(self.boardCards[i + 20])
        end

        if i < 6 then
            self.boardCards[i]:setNextCard(self.boardCards[i + 1])
            self.boardCards[i + 7]:setNextCard(self.boardCards[i + 8])
            self.boardCards[i + 14]:setNextCard(self.boardCards[i + 15])
            self.boardCards[i + 21]:setNextCard(self.boardCards[i + 22])
        end
        
    end

    for i = 0, 5 do
        self.boardCards[i + 28]:setCoords(LEFT_BOARD + 4 * CardWidth + 20, START_BOARD + i * 30)
        self.boardCards[i + 34]:setCoords(LEFT_BOARD + 5 * CardWidth + 25, START_BOARD + i * 30)
        self.boardCards[i + 40]:setCoords(LEFT_BOARD + 6 * CardWidth + 30, START_BOARD + i * 30)
        self.boardCards[i + 46]:setCoords(LEFT_BOARD + 7 * CardWidth + 35, START_BOARD + i * 30)

        if i == 0 then
            self.freeCells[8].card = self.boardCards[28]
            self.boardCards[28].onFreeCell = true
            self.freeCells[9].card = self.boardCards[34]
            self.boardCards[34].onFreeCell = true
            self.freeCells[10].card = self.boardCards[40]
            self.boardCards[40].onFreeCell = true
            self.freeCells[11].card = self.boardCards[46]
            self.boardCards[46].onFreeCell = true
        end

        if i > 0 then
            self.boardCards[i + 28]:setPreviousCard(self.boardCards[i + 27])
            self.boardCards[i + 34]:setPreviousCard(self.boardCards[i + 33])
            self.boardCards[i + 40]:setPreviousCard(self.boardCards[i + 39])
            self.boardCards[i + 46]:setPreviousCard(self.boardCards[i + 45])
        end

        if i < 5 then
            self.boardCards[i + 28]:setNextCard(self.boardCards[i + 29])
            self.boardCards[i + 34]:setNextCard(self.boardCards[i + 35])
            self.boardCards[i + 40]:setNextCard(self.boardCards[i + 41])
            self.boardCards[i + 46]:setNextCard(self.boardCards[i + 47])
        end
    end
end
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
        print(self.homeCells[i].x .. " " .. self.homeCells[i].y)
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
        self.boardCards[i]:setLock()
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
            else
                if self:isForHome(card) then
                    print("is for home")
                elseif self:isForOtherCard(card) then
                    print("is for other card")
                elseif self:isForFreeCell(card) then
                    print("is for free cell")
                    local tempCell = -1
                    if card.onFreeCell == true then
                        for i = 0, 11 do
                            if self.freeCells[i].card == card then
                                tempCell = self.freeCells[i]
                                break
                            end
                        end
                    end

                    for i = 0, 11 do
                        if self.freeCells[i].isFree == true then
                            self.freeCells[i]:toString()
                            self.freeCells[i].isFree = false

                            if card.previous ~= nil and
                            card.previous ~= -1 then
                                card.previous:setNextCard(-1)
                            else
                                self.nFreeCells = self.nFreeCells + 1
                                for i = 4, 11 do
                                    if self.freeCells[i].x == card.x and
                                    self.freeCells[i].y == card.y then
                                        print("jackpot")
                                        self.freeCells[i].card = -1
                                        self.freeCells[i].isFree = true
                                        break
                                    end
                                end
                            end
                            card:setCoords(self.freeCells[i].x, self.freeCells[i].y)
                            card:setPreviousCard(-1)
                            card:setNextCard(-1)
                            card:setOnFreeCell(true)
                            self.nFreeCells = self.nFreeCells - 1
                            self.freeCells[i].card = card
                            self.freeCells[i]:update(dt)
                            self.freeCells[i]:toString()

                            break
                        end
                    end

                    if tempCell ~= -1 then
                        print("temp not nil")
                        tempCell.card = -1
                        tempCell.isFree = true
                    end
                else
                    print("nope")
                end
            end
            for i = 0, 51 do
                self.boardCards[i]:setLock()
            end
            --self.state = 'start'
        end
        self:render()
    elseif self.state == 'click' and
    love.mouse.isDown(1) == false then
        self.state = 'start'
    end

end

function Board:isForOtherCard(card)
    for i = 0, 51 do 
        if self.boardCards[i].lock == false and
        self.boardCards[i].value - 1 == card.value and
        self.boardCards[i].isBlack ~= card.isBlack and
        self.boardCards[i].onFreeCell == false and
        self.boardCards[i].onHomeCell == false and
        (self.boardCards[i].next == nil or self.boardCards[i].next == -1) then
            print("IF")
            --card:toString()
            if card.previous ~= nil and
            card.previous ~= - 1 then
                card.previous:setNextCard(-1)
            else
                self.nFreeCells = self.nFreeCells + 1
                print("ELSE")
                if card.onFreeCell == true then
                    print("is on free")
                    for i = 4, 11 do
                        if self.freeCells[i].x == card.x and 
                        self.freeCells[i].y == card.y then
                            self.freeCells[i].card = -1
                            self.freeCells[i].isFree = true
                            break
                        end
                    end
                end
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
    print(self.nHomeCell)
    --card:toString()
    for i = 0, 3 do

        if card.value == 1 
        and (self.homeCells[i].card == nil or
        self.homeCells[i].card == -1) then
            print("1 home")
            self.homeCells[i].card = card
            self.homeCells[i].color = card.color
            card:setCoords(self.homeCells[i].x, self.homeCells[i].y)

            if card.previous ~= nil and
            card.previous ~= -1  then
                print("not on free cell")
                card.previous:setNextCard(-1)
                card:setPreviousCard(-1)
            end
            card:setOnHomeCell()

            self.nHomeCell = self.nHomeCell + 1
            --card:render()
            return true

        elseif self.homeCells[i].color == card.color and
        self.homeCells[i].card.value == card.value - 1 then
            print("new home")
            if card.previous ~= nil and
            card.previous ~= -1 then
                card.previous:setNextCard(-1)
            end

            if card.onFreeCell == true then
                for i = 4, 11 do
                    if self.freeCells[i].x == card.x and
                    self.freeCells[i].y == card.y then
                        self.freeCells[i].card = -1
                        break
                    end
                end
            end
            
            self.homeCells[i].card.next = card
            --self.boardCards[card.id - 1]:setNextCard(card)
            card:setOnHomeCell()
            card:setCoords(self.homeCells[i].x, self.homeCells[i].y)
            
            self.nHomeCell = self.nHomeCell + 1
            --card:render()
            return true
        end
    end
    return false
end

function Board:isForFreeCell(card)
    if self.nFreeCells > 0 and 
    card.lock == false and 
    card.onHomeCell == false then
        return true
    else
        return false
    end
end

function Board:getCardAt(x, y)
    for i = 0, 51 do
        if self.boardCards[i]:isAtCoords(x, y) and 
        self.boardCards[i].lock == false then
            self.boardCards[i]:toString()
            return self.boardCards[i]
        end
    end
    return - 1
end

function Board:render()

    love.graphics.print(tostring(self.nFreeCells) .. " - " .. tostring(self.nHomeCell), WINDOW_WIDTH/2, 20)
    if self.state == 'start' or self.state == 'click' then
        for i = 0, 3 do
            
            self.freeCells[i]:render()
            self.homeCells[i]:render()
        end

        for i = 0, 51 do
            if self.boardCards[i].onFreeCell then
                love.graphics.draw(self.deck.spritesheet, self.deck.sprites[self.boardCards[i].id], self.boardCards[i].x, self.boardCards[i].y)
            elseif self.boardCards[i].previous == nil or
            self.boardCards[i].previous == -1 then
                self.boardCards[i]:render()
            end
        end
    end
end

function Board:deal()
    for i = 0, 6 do
        self.boardCards[i]:setCoords(LEFT_BOARD, START_BOARD + i * 30)
        self.boardCards[i + 7]:setCoords(CardWidth + LEFT_BOARD + 5, START_BOARD + i * 30)
        self.boardCards[i + 14]:setCoords(LEFT_BOARD + 2 * CardWidth + 10, START_BOARD + i * 30)
        self.boardCards[i + 21]:setCoords(LEFT_BOARD + 3 * CardWidth + 15, START_BOARD + i * 30)

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
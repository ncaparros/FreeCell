
Card = Class {}

CardWidth = 923/13
CardHeight = 576/6

spades = 's'
hearts = 'h'
diamonds = 'd'
clubs = 'c'

function Card:init()
    self.onFreeCell = false
    self.onHomeCell = false
    self.spritesheet = love.graphics.newImage('img/cards.png')
    self.previous = -1
    self.next = -1
end

function Card:update(dt)

end


function Card:setSprite(sprite)
    self.sprite = sprite
end

function Card:setId(id)
    self.id = id
end

function Card:setColor(col)
    self.color = col
    if col == 's' or col == 'c' then
        self.isBlack = true
    else
        self.isBlack = false
    end
end

function Card:setValue(val)
    self.value = val
end

function Card:setOnFreeCell(val)
    self.onFreeCell = val
end

function Card:setOnHomeCell()
    self.onHomeCell = true
end

function Card:setCoords(x, y)
    self.x = x
    self.y = y
end

function Card:isAtCoords(x, y)
    if x > self.x and
    x < self.x + CardWidth and
    y > self.y and 
    y < self.y + CardHeight then
        return true
    else
        return false
    end
end

function Card:remPrevious()
    self.previous = nil
    --self.previous = -1
end

function Card:setPreviousCard(card)
    self.previous = card
end

function Card:setNextCard(card)
    self.next = card
end

function Card:setLock(nFreeCells)
    if self:getRowNb() > nFreeCells then
        self.lock = true
    elseif self.next == nil or self.next == -1 then
        self.lock = false
    elseif self.isBlack ~= self.next.isBlack and
    self.value - 1 == self.next.value then
        self.lock = false
    else
        self.lock = true
    end
end

function Card:setLockedForEnd()
    if self.next == nil or self.next == -1 then
        self.locked = false
    elseif self.isBlack ~= self.next.isBlack and
    self.value - 1 == self.next.value then
        self.locked = false
    else
        self.locked = true
    end
end 


function Card:getRowNb()
    if self.next == nil or
    self.next == -1 then
        return 0
    else
        return self.next:getRowNb() + 1
    end
end

function Card:moveNexts()
    if self.next ~= nil and
    self.next ~= -1 then
        self.next:setCoords(self.x, self.y + 30)
        self.next:moveNexts()
        print("move nexts")
    else
        print("no next " .. tostring(self.next))
    end
end

function Card:toString()
    if self ~= nil and self ~= -1 then
        print("id : " .. self.id .. " value : " .. self.value .. " color : " .. self.color .. " locked : ".. tostring(self.lock) .. " isBlack : " .. tostring(self.isBlack))
        print("rows : " .. self:getRowNb())
        if self.next ~= nil and self.next ~= - 1 then
            print("next : " .. self.next.value)
        end

        if self.previous ~= nil and self.previous ~= -1 then
            print("prev :" .. self.previous.value)
        end
    else
        print("card nil")
    end
end

function Card:render()
    love.graphics.draw(self.spritesheet, self.sprite, self.x, self.y)
    if self.next ~= nil and
    self.next ~= -1 then
        self.next:render()
    end
end

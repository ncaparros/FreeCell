FreeCell = Class{}

CardWidth = 923/13
CardHeight = 576/6

function FreeCell:init()
    self.card = -1
    self.isFree = false
end

function FreeCell:set(isFree, x, y)
    self.isFree = isFree
    self.x = x
    self.y = y
end

function FreeCell:update(dt)
    self.isFree = self.card == nil or self.card == -1
end

function FreeCell:toString()
    print(tostring(self.isFree))
end

function FreeCell:render()
    love.graphics.rectangle("line", self.x, self.y, CardWidth, CardHeight)
end
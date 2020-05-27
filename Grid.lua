Grid = Class{}

require 'Util'

local MINE = 1
local FLAG = 2

function Grid:init(rows)
    self.rows = rows
    self.width = (WINDOW_SIDE * 2 / 3) / rows

    -- spritesheet which stores the graphics
    if WINDOW_SIDE == 720 then
        dir = 'graphics/mine_large.png'
    elseif WINDOW_SIDE == 360 then
        dir = 'graphics/mine_small.png'
    end
    self.spritesheet = love.graphics.newImage(dir)
    self.tileWidth = self.width
    self.tileHeight = self.width
    self.sprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    --[[
        stores map
        0 : empty
        -1 : mine
        1 and above : number of mines around a particular block
    ]]
    self.map = {}

    --[[
        stores if a grid has been opened or not
        0 : not opened
        1 : opened
        2 : flag
    ]]
    self.play = {}

    -- initialising map and play tables
    for i = 1, self.rows * self.rows do
        self.map[i] = 0
        self.play[i] = 0
    end 

    -- time keeping
    self.time = 0
    self.interval = 0
end

-- draws grid lines
function Grid:structure()

    love.graphics.setLineWidth(4)

    for i = 0, WINDOW_SIDE * 2 / 3, self.width do
        -- horizontal lines
        love.graphics.line({
            WINDOW_SIDE / 6, WINDOW_SIDE / 6 + i,
            WINDOW_SIDE * 5 / 6, WINDOW_SIDE / 6 + i
        })

        -- vertical lines
        love.graphics.line({
            WINDOW_SIDE / 6 + i, WINDOW_SIDE / 6,
            WINDOW_SIDE / 6 + i, WINDOW_SIDE * 5 / 6
        })
    end
end

-- returns grid-x position (between 1 and number of rows)
function Grid:returnX(n)
    return (n - 1) % self.rows + 1
end

-- returns grid-y position (between 1 and number of rows)
function Grid:returnY(n)
    return math.floor((n - 1) / self.rows) + 1
end

-- returns grid-x coordinate
function Grid:returnXcoord(gridX)
    return (gridX - 1) * self.width + WINDOW_SIDE / 6
end

-- returns grid-y coordinate
function Grid:returnYcoord(gridY)
    return (gridY - 1)* self.width + WINDOW_SIDE / 6
end

-- fills a square
function Grid:fill(gridX, gridY)
    local x = self:returnXcoord(gridX)
    local y = self:returnYcoord(gridY)
    
    love.graphics.rectangle('fill', x, y, self.width, self.width)
end

-- prints numbers on the blocks
function Grid:numbers(gridX, gridY)
    local x = self:returnXcoord(gridX)
    local y = self:returnYcoord(gridY)

    love.graphics.setFont(love.graphics.newFont(self.width / 2))

    local str = tostring(self.map[(gridY - 1) * self.rows + gridX])

    love.graphics.printf(str, x, y + self.width / 4, self.width, 'center')
end

-- updates game timer
function Grid:update(dt)
    if gameState == 'play' then
        self.interval = self.interval + dt

        if self.interval >= 1 then
            self.time = self.time + 1
            self.interval = self.interval - 1
        end
    end
end 

-- renders tiles/blocks of appropriate colors
function Grid:render()
    for i = 1, self.rows * self.rows do
        -- covered tiles and flagged tiles
        if self.play[i] == 0 or self.play[i] == 2 then
            love.graphics.setColor(186 / 255, 186 / 255, 186 / 255, 1)

        -- opened tiles
        elseif self.map[i] == -1 then
            love.graphics.setColor(255 / 255, 87 / 255, 87 / 255, 1)
        elseif self.map[i] == 0 then
            love.graphics.setColor(222 / 255, 222 / 255, 222 / 255, 1)
        elseif self.map[i] == 1 then
            love.graphics.setColor(171 / 255, 1, 171 / 255, 1)
        elseif self.map[i] == 2 then
            love.graphics.setColor(219 / 255, 1, 176/ 255, 1)
        elseif self.map[i] == 3 then
            love.graphics.setColor(1, 1, 153 / 255, 1)
        elseif self.map[i] == 4 then
            love.graphics.setColor(1, 221 / 255, 176 / 255, 1)
        elseif self.map[i] == 5 then
            love.graphics.setColor(1, 204 / 255, 176 / 255, 1)
        elseif self.map[i] == 6 then
            love.graphics.setColor(1 , 151 / 255, 125 / 255, 1)
        elseif self.map[i] == 7 then
            love.graphics.setColor(1 , 125 / 255, 125 / 255, 1)
        elseif self.map[i] == 8 then
            love.graphics.setColor(1 , 92 / 255, 92 / 255, 1)
        end

        -- if a tile is flagged incorrectly
        if gameState == 'dead' and self.play[i] == 2 and self.map[i] ~= -1 then
            love.graphics.setColor(255 / 255, 87 / 255, 87 / 255, 1)
        end

        -- fills tile
        self:fill(self:returnX(i), self:returnY(i))

        -- prints flag wherever placed
        if self.play[i] == 2 then
            love.graphics.draw(self.spritesheet, self.sprites[FLAG], 
                self:returnXcoord(self:returnX(i)), 
                self:returnYcoord(self:returnY(i)))
        end

        -- reveals all the mines once dead
        if gameState == 'dead' and self.map[i] == -1 and self.play[i] ~= 2 then
            love.graphics.draw(self.spritesheet, self.sprites[MINE], 
            self:returnXcoord(self:returnX(i)), 
            self:returnYcoord(self:returnY(i)))
        end

        -- prints number
        love.graphics.setColor(0, 0, 0, 1)
        if self.map[i] > 0 and self.play[i] == 1 then
            self:numbers(self:returnX(i), self:returnY(i))
        end
    end
end
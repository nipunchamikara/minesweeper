Button = Class{}

--[[
    File stores code for generation and operation of buttons in the game
]]

function Button:init(x, y, width, height, text)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text

    self.mouseDown = false
    self.hover = false
end

-- checks if a button is pressed and hovered
-- if button is pressed, returns true, else returns false
function Button:pressed(cursorX, cursorY)
    if cursorX >= self.x and cursorX <= self.x + self.width and cursorY >= self.y and cursorY <= self.y + self.height then
        self.hover = true
        if love.mouse.isDown(1) then
            self.mouseDown = true
        end

        if love.mouse.isDown(1) == false and self.mouseDown == true then
            self.mouseDown = false
            return true
        end
    else
        self.hover = false
    end
    return false
end

-- renders button
function Button:render()

    -- default button color
    love.graphics.setColor(186 / 255, 186 / 255, 186 / 255, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    -- when hovered upon
    if self.hover then
        love.graphics.setColor(50 / 255, 50 / 255, 50 / 255, 0.25)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end

    -- displays text within button
    love.graphics.setColor(69 / 255, 81 / 255, 94 / 255, 1)
    love.graphics.setFont(love.graphics.newFont(self.height / 2))
    love.graphics.printf(self.text, self.x, self.y + self.height / 4, self.width, 'center')
end
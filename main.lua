--[[
    Minesweeper remake using Lua with LÖVE as it's framework
]]

-- can be changed between 720 and 360
WINDOW_SIDE = 720

-- https://github.com/vrld/hump
Class = require 'class'

require 'Grid'
require 'Mine'
require 'Button'

function love.load()

    -- instantiasation of grid
    grid = Grid(8)

    -- setting window size
    love.window.setMode(WINDOW_SIDE, WINDOW_SIDE, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })

    -- setting window title
    love.window.setTitle("Minesweeper")

    -- stores gameState
    gameState = 'start'

    -- stores if the right mouse button is down or not
    rightMouseDown = false

    -- generates buttons
    newGame = Button(WINDOW_SIDE / 6 + 2, WINDOW_SIDE * 5 / 6 + 2, WINDOW_SIDE * 1 / 3 - 4,
        WINDOW_SIDE / 12 - 2, 'NEW GAME')

    exit = Button(WINDOW_SIDE / 2 + 2, WINDOW_SIDE * 5 / 6 + 2, WINDOW_SIDE * 1 / 3 - 4,
        WINDOW_SIDE / 12 - 2, 'EXIT')

    --non functioning time button (to show time elapsed)
    time = Button(WINDOW_SIDE / 3 + 2, WINDOW_SIDE / 12, WINDOW_SIDE * 1 / 3 - 4,
        WINDOW_SIDE / 12 - 2, '00:00')
end

-- function to clear empty tiles and the tiles around it (recursive function)
function clear(x, y)
    local n = (y - 1) * grid.rows + x
    if grid.play[n] ~= 1 then
        grid.play[n] = 1

        if grid.map[n] == 0 then
            for j = math.max(1, y - 1), math.min(grid.rows, y + 1) do
                for i = math.max(1, x - 1), math.min(grid.rows, x + 1) do
                    clear(i, j)
                end
            end
        end
    end
end

-- function which executes when the mouse is clicked on
function mouseDown(x, y)
    local n = (y - 1) * grid.rows + x

    -- left mouse button
    if love.mouse.isDown(1) then
        if gameState == 'start' then
            mine = Mine(10, x, y)
            gameState = 'play'
        else
            clear(x, y)
            if grid.map[n] == -1 then
                gameState = 'dead'
            end
        end
    end
    
    --right mouse button
    if love.mouse.isDown(2) then
        rightMouseDown = true
    end
    if rightMouseDown == true and love.mouse.isDown(2) == false then
        if grid.play[n] == 0 then
            grid.play[n] = 2
        elseif grid.play[n] == 2 then
            grid.play[n] = 0
        end
        rightMouseDown = false
    end
end

-- checks if mouse hovers over a grid tile
function hover(cursorX, cursorY)

    -- calculates gridx and gridy position of cursor
    local x = math.floor((cursorX - WINDOW_SIDE / 6) / grid.width + 1)
    local y = math.floor((cursorY - WINDOW_SIDE / 6) / grid.width + 1)

    local n = (y - 1) * grid.rows + x

    -- when cursor is hovering over a tile
    if x >= 1 and x <= grid.rows and y >= 1 and y <= grid.rows and grid.play[n] ~= 1 then

        -- changes color
        love.graphics.setColor(50 / 255, 50 / 255, 50 / 255, 0.25)
        grid:fill(x, y)

        -- checks gameState
        if gameState ~= 'dead' and gameState ~= 'victory' then
            mouseDown(x, y)    
        end    
    end
end

function love.update(dt)

    -- counts number of unopened tiles
    local unopened = 0
    for _, value in ipairs(grid.play) do
        if value ~= 1 then
            unopened = unopened + 1
        end
    end
    
    -- checks if the game is won
    if gameState == 'play' and unopened == mine.total then
        gameState = 'victory'
    end

    -- updates time elapsed
    grid:update(dt)
end

-- adds leading zeroes to one-digit numbers
function leadingzero(num)
    if num > 9 then
        return tostring(num)
    else
        return '0' .. tostring(num)
    end
end

-- prints time elapsed using tiem button
function timer()
    time:render()
    time.text = leadingzero(math.floor(grid.time / 60)) .. ':' .. leadingzero(math.floor(grid.time % 60))
end

function love.draw()

    -- essentially sets background colour
    -- if game is won, green background, else default dark blue background
    if gameState == 'victory' then
        love.graphics.clear(25 / 255, 156 / 255, 53 / 255, 1)
    else
        love.graphics.clear(69 / 255, 81 / 255, 94 / 255, 1)
    end

    -- renders grid and button
    grid:render()
    newGame:render()
    exit:render()

    -- returns the x and y position of the cursor
    local cursorX, cursorY = love.mouse.getPosition()

    -- renders when hovered upon
    hover(cursorX, cursorY)

    -- if new game button is pressed (passing cursor position as argument)
    if newGame:pressed(cursorX, cursorY) then
        grid = Grid(8)
        gameState = 'start'
    end

    -- if exit button is pressed (passing cursor position as argument)
    if exit:pressed(cursorX, cursorY) then
        love.event.quit()
    end

    -- draws grid lines
    if gameState == 'victory' then
        love.graphics.setColor(25 / 255, 156 / 255, 53 / 255, 1)
    else
        love.graphics.setColor(69 / 255, 81 / 255, 94 / 255, 1)
    end
    grid:structure()

    -- prints time
    timer()
    time:pressed(cursorX, cursorY)
end
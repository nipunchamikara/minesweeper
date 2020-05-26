Mine = Class{}

function Mine:init(total, x, y)
    self.total = total  

    --stores first block clicked
    self.x = x
    self.y = y

    -- generates mines
    self:generate()
end

-- generates mines and the numbers surrounding the mines
function Mine:generate()
    math.randomseed(os.time())

    local x = 0
    local y = 0 

    for i = 1, self.total do

        local valid = true

        -- makes sure the mines are assigned unique positions
        repeat
            valid = true
            x = math.random(1, grid.rows)
            y = math.random(1, grid.rows)

            -- prevents mines spawned within the 3x3 box around the clicked tile
            for k = math.max(1, self.y - 1), math.min(grid.rows, self.y + 1) do
                for j = math.max(1, self.x - 1), math.min(grid.rows, self.x + 1) do
                    if x == j and y == k then
                        valid = false
                    end
                end
            end

            -- prevents mine from spawing over itself
            if grid.map[(y - 1) * grid.rows + x] == -1 then
                valid = false
            end

        until valid == true
        
        grid.map[(y - 1) * grid.rows + x] = -1

        -- calculates the number of mines around a particular block
        for k = math.max(1, y - 1), math.min(grid.rows, y + 1) do
            for j = math.max(1, x - 1), math.min(grid.rows, x + 1) do
                if grid.map[(k - 1) * grid.rows + j] ~= -1 then
                    grid.map[(k - 1) * grid.rows + j] = grid.map[(k - 1) * grid.rows + j] + 1
                end
            end
        end
    end
end
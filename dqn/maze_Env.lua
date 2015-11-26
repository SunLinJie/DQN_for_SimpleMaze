require 'torch'
require 'image'

local game_env = torch.class('GameMaze')

function game_env:gameInit()
    --original parameters
    self.mazeW = 16
    self.mazeH = 21
    self.x = 1
    self.y = 1
    self.lastX = 1
    self.lastY = 1
    self.beginPoint = {1, 1}
    self.endPoint   = {21, 16}
    
    -- 1 : up, 2 : down, 3 : left, 4 : right
    self.actions = {1, 2, 3, 4}

    -- original image
    self.image = torch.DoubleTensor(3, 21, 16)

    --init terminal and reward
    self.terminal = false
    self.reward = 0
    
    --define maze shape
    --init maze tensor
    local maze = torch.DoubleTensor(21, 16):fill(0)
 
    for m = 5, 10 do
        maze[18][m] = 1
    end

    for n = 6, 17 do
        maze[n][10] = 1
    end

    for j = 11, 14 do 
        maze[6][j] = 1
    end

    --define beginpoint, endpoint and agent
    maze[self.beginPoint[1]][self.beginPoint[2]] = 3
    maze[self.endPoint[1]][self.endPoint[2]] = 4
    maze[self.x][self.y] = 2
    
    self.maze = maze

    return maze
end

function game_env:mazeUpdate(act)
    local x, y = self.x, self.y
    local maze = self.maze
    local lastX, lastY = x, y
    local terminal = self.terminal
    local reward = self.reward
    local w = self.mazeW
    local h = self.mazeH
    local a, b
    
    if terminal then
        return terminal
    end

    -- move to new position
    if act == 1 then
        x = x - 1
    elseif act == 2 then
        x = x + 1 
    elseif act == 3 then
        y = y - 1
    elseif act == 4 then
        y = y + 1
    end
    
    --compute reward per step, when the point isn't terminal we give reward equal to 1,
    --if it is terminal but terminal is target, we give reward equal to 100
    if x < 1 or x > self.mazeH then
        reward = -5
    elseif y < 1 or y > self.mazeW then
        reward = -5
    elseif maze[x][y] == 1 then
        reward = -10
    elseif maze[x][y] == 4 then
        reward = 100
    else 
        a = math.abs(h - x) + math.abs(w - y)
        b = math.abs(h - lastX) + math.abs(w - lastY)

        if a > b then
            reward = -1
        else
            reward = 1
        end
    end
    -- "note"
    self.reward = reward

    -- check x,y out of range
    if x < 1 or x > self.mazeH then
        terminal = true
    end

    if y < 1 or y > self.mazeW then 
        terminal = true
    end 
    
    -- "note"
    self.terminal = terminal

    if terminal then 
        return terminal
    end

    -- check new poistion is or isn't block
    if maze[x][y] == 1 then
        terminal = true
       
    end
    
    if maze[x][y] == 4 then
        terminal = true
	print("Reach the target position, game over!")
    end
    -- "note"
    self.terminal = terminal

    if terminal then
        return terminal
    end   

    maze[x][y] = 2
    maze[lastX][lastY] = 0
    
    maze[self.beginPoint[1]][self.beginPoint[2]] = 3
    maze[self.endPoint[1]][self.endPoint[2]] = 4

    --update x, y
    self.x, self.y = x, y   
    
    return self.reward, self.terminal
end

function game_env:mazeToImage()
    local image1 = torch.Tensor(3, self.mazeH, self.mazeW)
    local maze = self.maze

    for i = 1, self.mazeW do
        for j = 1, self.mazeH do
            if maze[j][i] == 0 then
                -- nothing
                image1[1][j][i] = 1
                image1[2][j][i] = 1
                image1[3][j][i] = 1
            elseif maze[j][i] == 1 then
                -- block
                image1[1][j][i] = 0
                image1[2][j][i] = 0
                image1[3][j][i] = 0
            elseif maze[j][i] == 2 then
                -- robot
                image1[1][j][i] = 1
                image1[2][j][i] = 0
                image1[3][j][i] = 0
            elseif maze[j][i] == 3 then
                -- begining point
                image1[1][j][i] = 1
                image1[2][j][i] = 1
                image1[3][j][i] = 0
            elseif maze[j][i] == 4 then
                -- end point
                image1[1][j][i] = 1
                image1[2][j][i] = 0
                image1[3][j][i] = 1
            end
        end
    end
    
    self.image_ori = image1
    self.image = image.scale(image1, '160x210', 'simple')

    return self.image
end

--init GameEnvironment
function game_env:__init()
    game_env:gameInit()
end

--get actions
function game_env:getActions()
    return self.actions
end

--gain current state: screen, reward, terminal
function game_env:getState()
    return self.image, self.reward, self.terminal
end

function game_env:step(act)   
    game_env:mazeUpdate(act)
    game_env:mazeToImage()
    
    return self.image, self.reward, self.terminal
end

function game_env:newGame()
    game_env:__init()   
    game_env:mazeUpdate(0)
    game_env:mazeToImage()

    return self.image, self.reward, self.terminal
end

function game_env:nextRandomGame()
    game_env:newGame()

    return self.image, self.reward, self.terminal
end

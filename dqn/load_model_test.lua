--test network
require 'cunn'

if not dqn then 
    require 'initenv'
end

local cmd = torch.CmdLine()
cmd:text()
cmd:text('Test Agent in Environment: ')
cmd:text()
cmd:text('Options: ')

cmd:option('-env_params', '', 'string of environment parameters')
cmd:option('-pool_frms', '',
           'string of frame pooling parameters (e.g.: size=2,type="max")')
cmd:option('-actrep', 1, 'how many times to repeat action')
cmd:option('-random_starts', 0, 'play action 0 between 1 and random_starts ' ..
           'number of times at the start of each training episode')

cmd:option('-name', '', 'filename used for saving network and training history')
cmd:option('-network', '', 'reload pretrained network')
cmd:option('-agent', '', 'name of agent file to use')
cmd:option('-agent_params', '', 'string of agent parameters')
cmd:option('-seed', 1, 'fixed input seed for repeatable experiments')

cmd:option('-verbose', 2,
           'the higher the level, the more information is printed to screen')
cmd:option('-threads', 1, 'number of BLAS threads')
cmd:option('-gpu', -1, 'gpu flag')

cmd:text()

local opt = cmd:parse(arg)

--general setup
local game_env, game_actions, agent, opt = setup(opt)

--override print to always flush the output
local old_print = print
local print = function(...)
    old_print(...)
    io.flush()
end

--start a new game
local screen, reward, terminal = game_env:newGame()
local win = image.display({image = screen})

print("Started playing.....")

--play one episode(game)
while not terminal do
    --if action was chosen randomly, Q-value is 0
    agent.bestq = 0

    --choose the best action
    local action_index = agent:perceive(reward, screen, terminal, true, 0.5)

    --play game in test mode(episode don't end when losing a life)
    screen, reward, terminal = game_env:step(game_actions[action_index], false)

    --display screen
    image.display({image = screen, win = win})
end

print("Finished playing")
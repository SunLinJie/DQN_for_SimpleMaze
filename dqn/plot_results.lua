require 'nn'
require 'initenv'
require 'cutorch'
require 'gnuplot'

if #arg < 1 then
  print('Usage: ', arg[0], ' <DQN file>')
  return
end

data = torch.load(arg[1])

--gnuplot.raw('set multiplot layout 2, 3')

gnuplot.epsfigure('Average_reward')
gnuplot.title('Average reward per game during testing')
gnuplot.plot(torch.Tensor(data.reward_history))
gnuplot.plotflush()

gnuplot.epsfigure('total_count_reward')
gnuplot.title('Total count of rewards during testing')
gnuplot.plot(torch.Tensor(data.reward_counts))
gnuplot.plotflush()

gnuplot.epsfigure('Number_games_testing')
gnuplot.title('Number of games played during testing')
gnuplot.plot(torch.Tensor(data.episode_counts))
gnuplot.plotflush()

gnuplot.epsfigure('Average_Q_value')
gnuplot.title('Average Q-value of validation set')
gnuplot.plot(torch.Tensor(data.v_history))
gnuplot.plotflush()

gnuplot.epsfigure('TD_error')
gnuplot.title('TD error (old and new Q-value difference) of validation set')
gnuplot.plot(torch.Tensor(data.td_history))
gnuplot.plotflush()

gnuplot.epsfigure('Seconds_time')
gnuplot.title('Seconds elapsed after epoch')
gnuplot.plot(torch.Tensor(data.time_history))
gnuplot.plotflush()
--gnuplot.figure()
--gnuplot.title('Qmax history')
--gnuplot.plot(torch.Tensor(data.qmax_history))

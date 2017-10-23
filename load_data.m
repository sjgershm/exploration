function data = load_data(experiment)
    
    % Load data from csv files.
    %
    % USAGE: data = load_data(experiment)
    %
    % INPUTS:
    %   experiment - which experiment data to load (1 or 2)
    %
    % Data:
    % Each csv file contains data for a single experiment.
    % - data1.csv is a bandit task with one stochastic arm and one deterministic arm
    % - data2.csv is a bandit task with two stochastic arms
    %
    % Columns in each csv file:
    % 1) subject #
    % 2) block #
    % 3) trial #
    % 4) mu1 (mean reward for arm 1)
    % 5) mu2 (mean reward for arm 2)
    % 6) choice (which arm was selected)
    % 7) reward (points)
    % 8) response time (milliseconds)
    %
    % OUTPUTS:
    % data - structure with the following fields:
    %   .N - # of trials
    %   .C - # of options
    %   .R - [N x 2] mean rewards for each arm
    %   .block - [N x 1] block #
    %   .trial - [N x 1] trial #
    %   .c - [N x 1] choice
    %   .rt - [N x 1] response time
    %
    % Sam Gershman, Oct 2017
    
    M = csvread(['data',num2str(experiment),'.csv'],1);
    
    S = unique(M(:,1));
    
    for s = 1:length(S)
        ix = M(:,1)==S(s) & M(:,8)<20000; % exclude trials on which subjects took longer than 20 seconds to respond
        data(s).R = M(ix,4:5);
        data(s).block = M(ix,2);
        data(s).c = M(ix,6);
        data(s).r = M(ix,7);
        data(s).rt = M(ix,8);
        data(s).trial = M(ix,3);
        data(s).N = sum(ix);
        data(s).C = 2;
    end
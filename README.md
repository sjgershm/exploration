exploration
====

Code and data for:
Gershman, S.J. (under review). Deconstructing the human algorithms for exploration.

To run some of the functions, you will need the MFIT toolbox (github.com/sjgershm/mfit).

Data:
Each csv file contains data for a single experiment.
- data1.csv is a bandit task with one stochastic arm and one deterministic arm
- data2.csv is a bandit task with two stochastic arms

Columns in each csv file:
1) subject #
2) block #
3) trial #
4) mu1 (mean reward for arm 1)
5) mu2 (mean reward for arm 2)
6) choice (which arm was selected)
7) reward (points)
8) response time (milliseconds)
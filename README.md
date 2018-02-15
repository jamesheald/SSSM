# SSSM-GBP1-EM
A switching state-space model of motor adaptation. 

State inference is performed using the generalised pseudo-Bayesian 1 (GPB1) algorithm. Parameter learning is implemented via online expectation-maximisation (EM).

Source code files:

KF - recursive Bayesian estimation in a conditionally linear-Gaussian system using a bank of Kalman filters

MM - moment matching to approximate the true belief state with a single Gaussian

EM - online expectation maximisation to learn cue emission probabilities

Running Run_code.m simulates Experiment 2 of 'Multiple motor memories are learned to control different points on a tool' (Heald et al., Nature Human Behavior, 2018).

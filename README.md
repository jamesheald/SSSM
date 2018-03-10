# SSSM-GBP1-EM
Motor adaptation as online state and parameter estimation in a switching state-space model (Heald et al., *Nature Human Behavior*, 2018). Here I implement state inference using the 1<sup>st</sup> order generalised pseudo-Bayesian (GPB1) algorithm. GPB1 is an assumed density filtering method that approximates the exact posterior of the state (a mixture of Gaussians with *c<sup>t</sup>* components, where *c* is the number of contexts and *t* is the number of trials) with a single Gaussian. The cue emission probabilities are updated using online expectation maximisation, which can be interpreted as a stochastic approximation recursion on the expected complete-data sufficient statistics.

Source code files:

- KF: recursive Bayesian estimation using a bank of Kalman filters
- ADF: assumed density filtering to approximate the exact posterior of the state with a single Gaussian
- EM: online expectation maximisation to learn the cue emission probabilities

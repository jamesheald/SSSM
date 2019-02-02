# SSSM-GBP1-EM
Motor adaptation as online state and parameter estimation in a switching state-space model (Heald et al., *Nature Human Behavior*, 2018). Here, state inference is implemented using the generalised pseudo-Bayesian estimator of order 1 (GPB1), which is an assumed density filtering method that approximates the exact posterior of the state (a mixture of Gaussians with *c<sup>t</sup>* components, where *c* is the number of contexts and *t* is the number of trials) with a single Gaussian. To learn the cue emission probabilities, an online formulation of expectation maximisation is used that can be interpreted as a stochastic approximation recursion on the expected complete-data sufficient statistics.

Source code files:

- KF: recursive Bayesian estimation using a bank of Kalman filters
- ADF: assumed density filtering to approximate the exact posterior of the state with a single Gaussian
- EM: online expectation maximisation to learn the cue emission probabilities

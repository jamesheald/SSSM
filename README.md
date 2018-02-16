# SSSM-GBP1-EM
Motor adaptation as online state and parameter estimation in a switching state-space model (Heald et al., *Nature Human Behavior*, 2018). Here I implement state inference using the generalised pseudo-Bayesian 1 (GPB1) algorithm. GPB1 is an assumed density filtering method that approximates the exact posterior of the state (a mixture of Gaussians with *M<sup>T</sup>* components, where *M* is the number of modes and *T* is the number of trials) with a single Gaussian. I update the estimated cue emission probability parameters using online expectation maximisation.

Source code files:

- KF: recursive Bayesian estimation using a bank of Kalman filters
- MM: moment matching to approximate the true belief state with a single Gaussian
- EM: online expectation maximisation to learn the cue emission probabilities

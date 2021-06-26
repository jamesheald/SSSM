# SSSM - v1.0.0
The switching state-space model (SSSM) [[1](#reference)]

Motor adaptation as online state and parameter estimation in a switching state-space model (Heald et al., *Nature Human Behavior*, 2018). Here, state inference is implemented using the generalised pseudo-Bayesian estimator of order 1 (GPB1), which is an assumed density filtering method that approximates the exact posterior of the state (a mixture of Gaussians with *c<sup>t</sup>* components, where *c* is the number of contexts and *t* is the number of trials) with a single Gaussian. To learn the cue emission probabilities, an online formulation of expectation maximisation is used that can be interpreted as a stochastic approximation recursion on the expected complete-data sufficient statistics.

### Reference

1. __Heald, J. B.__, Ingram, J. N., Flanagan, J. R., & Wolpert, D. M. (2018). Multiple motor memories are learned to control
different points on a tool. *Nature human behaviour*, 2(4), 300-311. ([link to article](https://www.nature.com/articles/s41562-018-0324-5))

## Installation

1. Download the SSSM.m file.
    
## Usage

Instructions for how to use the SSSM can be found on the [SSSM wiki](https://github.com/jamesheald/SSSM/wiki).

## Contact information

Please e-mail me at [jamesbheald@gmail.com](mailto:jamesbheald@gmail.com) if you have any questions.

## License

The COIN model is released under the terms of the GNU General Public License v3.0.

Source code files:

- KF: recursive Bayesian estimation using a bank of Kalman filters
- ADF: assumed density filtering to approximate the exact posterior of the state with a single Gaussian
- EM: online expectation maximisation to learn the cue emission probabilities

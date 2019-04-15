# ElFarolJulia
Basic implementation of _El Farol_ model in [Julia](https://julialang.org/) for [Agent Based Modeling](http://www.geog.leeds.ac.uk/courses/other/crime/abm/general-modelling/index.html).

For details on _El Farol_ model please refer to: 
* Wilensky and Rand (2015) [_Agent Based Modeling_](https://mitpress.mit.edu/books/introduction-agent-based-modeling),
* its [NetLogo](http://ccl.northwestern.edu/netlogo/models/ElFarol) implementation.

Model takes following arguments as input (default values in brackets):
* _num_agents_ (100) - number of agents in simulation,
* _sim_ticks_ (100) - number of iterations in a simulation,
* _crowd_threshold_ (60) - number of agents, over which the bar is overcrowded,
* _memory_size_ (5) - number of previous iterations each agent remembers,
* _num_of_strategies_ (10) - number of random strategies assigned for each agent.

Written in [Julia v.1.0.2](https://github.com/JuliaLang/julia/releases/tag/v1.0.2).

Credits:
* Kraiński Łukasz,
* Nosarzewski Aleksander.

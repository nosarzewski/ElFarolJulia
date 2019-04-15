####################
# Define agent struct
####################
mutable struct Drinker
    ID::Int64
    strategies::Matrix{Float64}  # list of strategies to choose from
    best_strategy::Int64 # index of currently best strategy
    intention::Bool # whether agent intends to go to El Farol in this iteration
    prediction::Int64 # predicted attendance
end

####################
# Auxilary functions
####################

# Function generating 'n' random strategies for 'memory' weeks
function generate_strategies(n::Int64, memory::Int64)
    #weights for each week are random floats from -1 to 1
    strategies_set = 1 .- 2 * rand(n, memory)
    return strategies_set
end

# Function calculating predicted attendance for set of strategies
function predict_attendance(s_set::Matrix{Float64}, timeframe::Vector{Int64})
    #Multiplying attendance vector and weights matrix + constant
    #Return vector of predictions for each strategy
    return round.(Int, 100 .* s_set[:, 1] + s_set[:, 2:end] * timeframe)
end

# Prediction for single strategy
function predict_attendance(strategy::Vector{Float64}, timeframe::Vector{Int64})
    #Multiplying attendance vector and weights vector + constant
    #Return single prediction for given strategy
    return round(Int, strategy[1] * 100 + strategy[2:end]' * timeframe)
end

# Function finding best strategy for given set
function update_best_strategy(s_set::Matrix{Float64}, timeframe::Vector{Int64}, mem_size::Int64)
    #Initialize errors vector with 0
    n = size(s_set, 1)
    errors_vector = zeros(n)
    #Calculate errors 'memory_size' times and sum them
    #Error = abs(attendance_i_week_back - predicted_attendance_i_week_back)
    week = 1
    for i in 1:mem_size
        predicted = predict_attendance(s_set, timeframe[(i+1):(i + mem_size)])
        errors_vector += abs.(timeframe[i] .- predicted)
    end
    #println(errors_vector) #For debugging
    #Return index of minimal error
    return argmin(errors_vector)
end

###########################################
# Generating agents and assigning strategies
###########################################

# Function for setting up an experiment
function setup(n_agents::Int64, n_strategies::Int64, mem_size::Int64)
    #Generating random bar attendance history to start the model
    attendance_history = rand(0:n_agents, mem_size * 2)
    #Initialize vector of agents
    Agents = [Drinker() for i = 1:n_agents]
    #Setting up agents
    for (ind, a) in enumerate(Agents)
        a.ID = ind
        a.strategies = generate_strategies(n_strategies, mem_size + 1)
        a.best_strategy = rand(1:n_strategies, 1)[1]
    end
    #Return initial attendance history vector and array of agents
    return attendance_history, Agents
end

# Function for running experiment
function run_simulation(history::Array{Int64}, Agents::Array{Drinker}, n_ticks::Int64,
                        n_agents::Int64, crowd_thresh::Int64, mem_size::Int64)
    for i in 1:n_ticks
        #Update prediction and agent's decision for current tick
        for a in Agents
            a.prediction = predict_attendance(a.strategies[a.best_strategy, :], history[1:mem_size])
            a.intention = a.prediction <= crowd_thresh
        end
        #Count bar attendance in given tick
        tick_attendance = sum([Agents[j].intention for j = 1:n_agents])
        #Update attendance history
        history = [tick_attendance; history]
        #Update agents' best strategies
        for a in Agents
            a.best_strategy = update_best_strategy(a.strategies, history[1:(2 * mem_size)], mem_size)
        end
    end
    return reverse(history), Agents
end

###########################################
# Base model
###########################################
#Input parameters
struct Input
    num_agents::Int64
    sim_ticks::Int64
    crowd_threshold::Int64
    memory_size::Int64
    num_of_strategies::Int64
end
# Base model constructor
In_base = Input(100, 100, 60, 5, 10)
#Default constructor
Drinker() = Drinker(0, zeros(In_base.num_of_strategies, In_base.memory_size), 0, 0, 0)

# Setting up base experiment
attendance_history_setup, Agents_setup = setup(In_base.num_agents, In_base.num_of_strategies, In_base.memory_size)
# Running experiment
attendance_history, Agents = run_simulation(attendance_history_setup, Agents_setup, In_base.sim_ticks, In_base.num_agents,
                                            In_base.crowd_threshold, In_base.memory_size)

#************************************************************************
# Microbreweri2 Assignment, "Mathematical Programming Modelling" (42112)
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
Months = ["Jan","Feb","Mar","Apr","May",
          "Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
Beers = ["TSP-Stout","Knapsack-Dark","SetPartioning-Light"]

# Prod and store data
BrewCap = 120

StoreCap = 300
Cost = 0.1

# demand from cafes of beers of different types Demand[b,m]
Demand =
    [35 20 15 45 25  65  40  50  35 85 50 55;
     15 10 20 15 15  55  90  80  25 45  5 30;
     5 20 20 35 35  80   60  30  35 20 20 40]
InitialStorage=[25 65 75]

# size of sets
M = length(Months)
B = length(Beers)
#************************************************************************

#************************************************************************
# Model
microbreweri2 = Model(HiGHS.Optimizer)

# production
@variable(microbreweri2, 0 <= x[1:B,1:M])

# storage in the end of the month
@variable(microbreweri2, 0 <= y[1:B,1:M]) 

# production allowed
@variable(microbreweri2, q[1:B,1:M], Bin) 


# Minimize storage cost
@objective(microbreweri2, Min,
           sum( Cost*y[b,m] for m=1:M,b=1:B))

# storage balance constraint
@constraint(microbreweri2, [b=1:B,m=1:M],
            y[b,m] == (m>1 ? y[b,m-1] : InitialStorage[b]) +
            x[b,m] - Demand[b,m])

# limit production and set binary variable
@constraint(microbreweri2, [b=1:B,m=1:M], x[b,m] <= BrewCap*q[b,m])

# limit stored quanties
@constraint(microbreweri2, [m=1:M], sum(y[b,m] for b=1:B) <= StoreCap)

# only produce one type of beer each month
@constraint(microbreweri2, [m=1:M], sum(q[b,m] for b=1:B) <= 1)
#************************************************************************


#************************************************************************
# solve
optimize!(microbreweri2)
println("Termination status: $(termination_status(microbreweri2))")
#************************************************************************

#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(microbreweri2) == MOI.OPTIMAL
    println("RESULTS:")
    println("Objective: $(objective_value(microbreweri2))")
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************


#************************************************************************
println("Successfull end of $(PROGRAM_FILE)")
#************************************************************************

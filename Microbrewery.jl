#************************************************************************
# MicroBreweri Assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
Months = ["Jan","Feb","Mar","Apr","May",
          "Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

# prod and store data
ProdCap = 120

StoreCap = 200
StoreCostPrLiter = 1

# demand from cafes of beers
Demand = [15 30 25 55 75 115 190 210 105 65 20 20]

# size of sets
M = length(Months)
#************************************************************************
    
#************************************************************************
# Model
microbreweri = Model(HiGHS.Optimizer)

@variable(microbreweri, 0 <= x[1:M] <= ProdCap) # production
@variable(microbreweri, 0 <= y[1:M] <= StoreCap) # storage in the end of the month

# Minimize storage cost
@objective(microbreweri, Min,
           sum( StoreCostPrLiter*y[m] for m=1:M))

# storage balance constraint
@constraint(microbreweri, [m=1:M],
            y[m] == (m>1 ? y[m-1] : 0) + x[m] - Demand[m])
print(microbreweri)
#************************************************************************

#************************************************************************
# solve
optimize!(microbreweri)
println("Termination status: $(termination_status(microbreweri))")
#************************************************************************

#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(microbreweri) == MOI.OPTIMAL
  println("RESULTS:")
  println("Objective: $(objective_value(microbreweri))")
  for m = 1:length(Months)
    println(" production $(value(x[m]))  store     : $(value(y[m]))")
  end
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************
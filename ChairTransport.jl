#************************************************************************
# Chair Transport, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
Plants = ["P1", "P2"]            # set of plants
P = length(Plants) # P is the size of the Plants set
Depots = ["D1", "D2", "D3", "D4"]
D = length(Depots)
PlantCapacity = [7500, 8500] # plant capacity in chairs           
DepotRequirement = [3250, 3500, 3500, 3000] # depot capacity in chairs
PDdist = [ 137  92  48 173; # Distance between Plants and Depots
            54  109 111  85]
F=0.0375
#************************************************************************


#************************************************************************
# Model
CT=Model(HiGHS.Optimizer)

@variable(CT, x[1:P, 1:D] >= 0)

@objective(CT, Min, sum( PDdist[p,d] * F * x[p,d] for p=1:P, d=1:D)) # Min cost

@constraint(CT, [p=1:P],sum(x[p,d] for d=1:D)<=PlantCapacity[p]) # Plant Capacity limit

@constraint(CT, [d=1:D],sum(x[p,d] for p=1:P)>=DepotRequirement[d]) # Depot req

print(CT) # print model to screen (only usable for small models)
#************************************************************************

#************************************************************************
# solve
optimize!(CT)
println("Termination status: $(termination_status(CT))")
#************************************************************************

#************************************************************************
if termination_status(CT) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(CT))")
    println("Solution:")
    for p = 1:P
      for d in 1:D
        println("  $(Plants[p]) $(Depots[d]) = $(value(x[p,d]))")
      end
    end
else
    println("No optimal solution available")
end
#************************************************************************

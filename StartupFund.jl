#************************************************************************
# Startup Fund assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
Investments = [1 2 3 4 5 6 7 8 9]
I=length(Investments)

# Data
EstProfitFactor =     [1.7 1.4 1.3 2.1 1.9 1.8 1.5 2.2 1.6]
CapitalRequirements = [ 17  25  19  25  28  23  29  31  18]
Budget = 100
#************************************************************************


#************************************************************************
# Model
Investment = Model(HiGHS.Optimizer)

@variable(Investment, x[1:I], Bin) # 1 if investment is made in i

# Maximize est-profit
@objective(Investment, Max,
           sum(EstProfitFactor[i]*x[i] for i=1:I) )

# budget constraint
@constraint(Investment, 
            sum(CapitalRequirements[i]*x[i] for i=1:I) <= Budget)

print(Investment)
#************************************************************************


#************************************************************************
# solve
optimize!(Investment)
#************************************************************************


#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(Investment) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(Investment))")
    for i in 1:I
        println("Investment $(Investments[i]) $(round(Int8,value(x[i])))")
    end
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************


#************************************************************************
# Jewellery Production 2 assignment, LP
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
Necklaces=["Necklace 1","Necklace 2","Necklace 3","Necklace 4","Necklace 5"]
N=length(Necklaces)
Machines=["Machine 1","Machine 2","Machine 3"]
M=length(Machines)
Profit=[50 45 85 60 55]
AssemblyTime=[12 3 11 9 6]
MachineTime=[
 7  0  0  9  0;
 5  7 11  0  5;
 0  3  8 15  3]
DayMinutes=60*7.5
NoAssemblyWorkers=3
Demand=[25 10 12 15 60]
#************************************************************************

#************************************************************************
# Model
JP = Model(HiGHS.Optimizer)

@variable(JP,x[n=1:N]>=0)

# maximize profit
@objective(JP, Max, sum( Profit[n]*x[n] for n=1:N) )

# Machine capacity
@constraint(JP, [m=1:M],
            sum( MachineTime[m,n]*x[n] for n=1:N) <= DayMinutes
            )

# Assembly capacity
@constraint(JP,
            sum(AssemblyTime[n]*x[n] for n=1:N) <= DayMinutes*NoAssemblyWorkers
            )

# Demand limits
@constraint(JP, [n=1:N],
            x[n] <= Demand[n]
            )


#************************************************************************

#************************************************************************
# Solve
solution = optimize!(JP)
println("Termination status: $(termination_status(JP))")
#************************************************************************

#************************************************************************
if termination_status(JP) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(JP))")
    for n=1:N
        println("Production of necklace $(Necklaces[n]) : ", value(x[n]))
    end
else
    println("No optimal solution available")
end
#************************************************************************

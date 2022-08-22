#************************************************************************
# Class Jobs assignment, LP
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
Children=[1 2 3 4 5]
C=length(Children)
Jobs=[1 2 3 4 5]
J=length(Jobs)
Wish=[
1 3 2 5 5;
5 2 1 1 2;
1 5 1 1 1;
4 5 4 4 4;
3 5 3 5 3]
#************************************************************************

#************************************************************************
# Model
CJ = Model(HiGHS.Optimizer)

@variable(CJ,x[j=1:J,c=1:C]>=0)

# maximize aggregated Wish
@objective(CJ, Max, sum( Wish[j,c]*x[j,c] for j=1:J,c=1:C ) )

# One job pr. child
@constraint(CJ, [c=1:C],
            sum( x[j,c] for j=1:J) == 1
            )

# One child pr. job
@constraint(CJ, [j=1:J],
            sum( x[j,c] for c=1:C) == 1
            )
#************************************************************************

#************************************************************************
# Solve
solution = optimize!(CJ)
println("Termination status: $(termination_status(CJ))")
#************************************************************************

#************************************************************************
if termination_status(CJ) == MOI.OPTIMAL
    println("Optimal objective value: $(objective_value(CJ))")
    for c=1:C
        for j=1:J
            if value(x[j,c])>0.999
                println("Child: ", c, " Doing job: ", j)
            end
        end
    end
else
    println("No optimal solution available")
end
#************************************************************************

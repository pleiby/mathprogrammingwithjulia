#************************************************************************
# GroceriesTSP2, "Mathematical Programming Modelling" (42112)
#************************************************************************
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
C=6 # no of customers
coord = zeros(C,2)

coord[1,1]=0; coord[1,2]=0
coord[2,1]=104; coord[2,2]=19
coord[3,1]=370; coord[3,2]=305
coord[4,1]=651; coord[4,2]=221
coord[5,1]=112; coord[5,2]=121
coord[6,1]=134; coord[6,2]=515

Distance = zeros(Float64,C,C)
for c1 in 1:C
    for c2 in 1:C
        Distance[c1,c2]= sqrt( (coord[c1,1]-coord[c2,1])*(coord[c1,1]-coord[c2,1]) + (coord[c1,2]-coord[c2,2])*(coord[c1,2]-coord[c2,2])  )
    end
end
#************************************************************************

#************************************************************************
# Model
TSP = Model(HiGHS.Optimizer)

@variable(TSP, x[1:C,1:C],Bin)
for c1 in 1:C
    fix(x[c1,c1],0; force = true)
end

@variable(TSP, u[1:C] >= 0)

# Minimize TSP distance
@objective(TSP, Min,
           sum(Distance[c1,c2]*x[c1,c2] for c1=1:C, c2=1:C))

# you enter all cities
@constraint(TSP, city_enter_con[c1=1:C],
            sum(x[c2,c1] for c2=1:C)==1)

# you exit all cities
@constraint(TSP, city_exit_con[c1=1:C],
            sum(x[c1,c2] for c2=1:C)==1)


# counter constraint
@constraint(TSP, counter_con[c1=1:C,c2=2:C,c1!=c2],
            u[c1] + 1 <= u[c2] + C*(1-x[c1,c2])
            )
#************************************************************************

#************************************************************************
# solve
optimize!(TSP)
println("Termination status: $(termination_status(TSP))")
#************************************************************************

#************************************************************************
println("objective = $(objective_value(TSP))")
println("Solve time: $(solve_time(TSP))")
println("u: ", round.(Int64,value.(u)))
#************************************************************************

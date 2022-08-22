#************************************************************************
# Wehicle Routing, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
C=13 # no of customers

# customer coordinates
coord = zeros(C,2)
coord[1,1]=0; coord[1,2]=0
coord[2,1]=104; coord[2,2]=19
coord[3,1]=370; coord[3,2]=305
coord[4,1]=651; coord[4,2]=221
coord[5,1]=112; coord[5,2]=121
coord[6,1]=134; coord[6,2]=515
coord[6,1]=134; coord[6,2]=515;
coord[7,1]=797; coord[7,2]=424;
coord[8,1]=347; coord[8,2]=444;
coord[9,1]=756; coord[9,2]=141;
coord[10,1]=304; coord[10,2]=351;
coord[11,1]=236; coord[11,2]=775;
coord[12,1]=687; coord[12,2]=310;
coord[13,1]=452; coord[13,2]=57;

# distance between customers
Distance = zeros(Float64,C,C)
for c1 in 1:C
    for c2 in 1:C
        Distance[c1,c2]= sqrt( (coord[c1,1]-coord[c2,1])*(coord[c1,1]-coord[c2,1]) + (coord[c1,2]-coord[c2,2])*(coord[c1,2]-coord[c2,2]) )
    end
end

# size of deliveries
q = zeros(C)
q[1]=0;
q[2]=3;
q[3]=9;
q[4]=7;
q[5]=11;
q[6]=11;
q[7]=6;
q[8]=7;
q[9]=7;
q[10]=2;
q[11]=4;
q[12]=2;
q[13]=8;

# number of vans
K=3

# capacity of each of the vans
Q=26
#************************************************************************

#************************************************************************
# Model
VRP = Model(HiGHS.Optimizer)

@variable(VRP, x[1:C,1:C],Bin)
for c in 1:C
    fix(x[c,c],0; force = true)
end
           
@variable(VRP, 0 <= u[1:C] <= Q)

# Minimize VRP distance
@objective(VRP, Min,
           sum(Distance[c1,c2]*x[c1,c2] for c1=1:C, c2=1:C))

# every city is entered by one truck, except the depot on node 1
@constraint(VRP, [c1=2:C],
            sum(x[c2,c1] for c2=1:C) == 1)

# every city is exited by one truck, except the depot on node 1
@constraint(VRP, [c1=2:C],
            sum(x[c1,c2] for c2=1:C) == 1)

# K trucks going out of node 1
@constraint(VRP,
            sum(x[1,c2] for c2=2:C) == K)

# K trucks going in of node 1
@constraint(VRP, 
            sum(x[c2,1] for c2=2:C) == K)

# counter constraint
@constraint(VRP, [c1=2:C,c2=1:C,c1!=c2],
            u[c1] + q[c1] <= u[c2] + Q*(1-x[c1,c2]) )
#************************************************************************

#************************************************************************
# solve
optimize!(VRP)
println("Termination status: $(termination_status(VRP))")
#************************************************************************

#************************************************************************
#print(VRP)
println("objective = $(objective_value(VRP))")
println("Solve time: $(solve_time(VRP))")
#************************************************************************


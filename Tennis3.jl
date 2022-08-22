#************************************************************************
# Tennis 3 Assignment, "Mathematical Programming Modelling" (42112)
# Model, where start and stop can occur at different places
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
#          1    2    3    4    5    6    7    8    9    10   11   12
Points = ["A0" "B0" "D0" "E0" "B1" "C1" "D1" "A2" "B2" "C2" "D2" "E2"]
P=length(Points)
x_pos = [0    4.5  31.5 36   4.5  18   31.5 0    4.5  18   31.5 36] 
y_pos = [0    0    0    0    18   18   18   39   39   39   39   39]
Distance = zeros(P,P)
for p in 1:P
    for pp in 1:P
        Distance[p,pp]= sqrt( (x_pos[p]-x_pos[pp])*(x_pos[p]-x_pos[pp]) + (y_pos[p]-y_pos[pp])*(y_pos[p]-y_pos[pp])  )
    end
end

Lines=zeros(Int8,P,P)
Lines[1,2]=1 #L('A0','B0') = 1;
Lines[1,8]=1 # L('A0','A2') = 1;
Lines[2,5]=1 # L('B0','B1') = 1;
Lines[2,3]=1 # L('B0','D0') = 1;
Lines[3,4]=1 # L('D0','E0') = 1;
Lines[3,7]=1 # L('D0','D1') = 1;
Lines[4,12]=1 # L('E0','E2') = 1;
Lines[5,6]=1 # L('B1','C1') = 1;
Lines[5,9]=1 # L('B1','B2') = 1;
Lines[6,7]=1 # L('C1','D1') = 1;
Lines[6,10]=1 # L('C1','C2') = 1;
Lines[7,11]=1 # L('D1','D2') = 1;
#************************************************************************


#************************************************************************
# Model
tennis = Model(HiGHS.Optimizer)

@variable(tennis, x[1:P, 1:P], Bin)

@variable(tennis, s[1:P], Bin)

@variable(tennis, e[1:P], Bin)

# Minimize walking-distance
@objective(tennis, Min,
           sum(Distance[p,pp]*x[p,pp] for p=1:P, pp=1:P))

# what goes in must come out
@constraint(tennis, [p=1:P],
            sum(x[pp,p] for pp=1:P) + s[p] == sum(x[p,pp] for pp=1:P) + e[p] )

# one start
@constraint(tennis, sum(s[p] for p=1:P) == 1)

# one end
@constraint(tennis, sum(e[p] for p=1:P) == 1)

# force clean lines
@constraint(tennis, [p=1:P,pp=1:P],
            x[p,pp] + x[pp,p] >= Lines[p,pp])

#************************************************************************

#************************************************************************
# solve
optimize!(tennis)
println("Termination status: $(termination_status(tennis))")
#************************************************************************

#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(tennis) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(tennis))")
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************


#************************************************************************
println("Successfull end of $(PROGRAM_FILE)")
#************************************************************************

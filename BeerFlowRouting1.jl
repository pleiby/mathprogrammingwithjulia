#************************************************************************
# Beer Flow Routing 1, "Mathematical Programming Modelling" (42112)
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
Bars=["A","B","C","D","E","F","G"]
B=length(Bars)
X_coor=[ 3.0  9.0 8.0 2.0 6.0 10.0 11.0]
Y_coor=[10.0 10.0 6.0 5.0 2.0  2.0  7.0]
Distance = zeros(Float64,B,B)
for b1 in 1:B
    for b2 in 1:B
        Distance[b1,b2]= sqrt( (X_coor[b1]-X_coor[b2])*(X_coor[b1]-X_coor[b2]) + (Y_coor[b1]-Y_coor[b2])*(Y_coor[b1]-Y_coor[b2])  )
    end
end

Network=zeros(Int64,B,B)

# A-B
Network[1,2]=1
Network[2,1]=1

# A-C
Network[1,3]=1
Network[3,1]=1

# A-D
Network[1,4]=1
Network[4,1]=1

# B-C
Network[2,3]=1
Network[3,2]=1

# C-E
Network[3,5]=1
Network[5,3]=1

# C-F
Network[3,6]=1
Network[6,3]=1

# F-G
Network[6,7]=1
Network[7,6]=1
#************************************************************************

#************************************************************************
# Model
BN = Model(HiGHS.Optimizer)

# flow from node i to node j
@variable(BN, x[i=1:B,j=1:B] >= 0) 

# Minimize path cost
@objective(BN,
           Min, sum( x[i,j] for i=1:B,j=1:B)
           )

@constraint(BN, [i=1:B],
            (i==1 ? 1 : 0) + sum( x[j,i] for j=1:B) ==
            sum( x[i,j] for j=1:B) + (i==B ? 1 : 0) 
            )

@constraint(BN, [i=1:B,j=1:B],
            x[i,j] <= Network[i,j]
            )
#************************************************************************

#************************************************************************
# solve
optimize!(BN)
println("Termination status: $(termination_status(BN))")
#************************************************************************

#************************************************************************
# Report results
if termination_status(BN) == MOI.OPTIMAL
    println("RESULTS:")
    println("BN result: $(objective_value(BN))")
    for i=1:B
        for j=1:B
            if value(x[i,j]) > 0.001
                println("$(Bars[i]) -> $(Bars[j]) val: $(value(x[i,j]))")
            end
        end
    end
else
  println("  No solution")
end
#************************************************************************

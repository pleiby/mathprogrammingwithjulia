#************************************************************************
# Beer Flow Routing, "Mathematical Programming Modelling" (42112)
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
Bars=["A","B","C","D","E","F","G"]
B=length(Bars)
X_coor=[3 9 8 2 6 10 11]
Y_coor=[10 10 6 5 2 2 7]
Distance = zeros(Float64,B,B)
for b1 in 1:B
    for b2 in 1:B
        Distance[b1,b2]= sqrt( (X_coor[b1]-X_coor[b2])*(X_coor[b1]-X_coor[b2]) + (Y_coor[b1]-Y_coor[b2])*(Y_coor[b1]-Y_coor[b2]) )
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

Demand=zeros(Int64,B,B)

# A  
Demand[1,2]=70

# B 
Demand[2,1]=50

# C
Demand[1,3]=80
Demand[2,3]=90

# D
Demand[1,4]=20
Demand[2,4]=50

# E
Demand[1,5]=80
Demand[2,5]=10

# F
Demand[1,6]=20
Demand[2,6]=100

# G
Demand[1,7]=40
Demand[2,7]=50

PipeCap=500

#************************************************************************

#************************************************************************
# Model
BN = Model(HiGHS.Optimizer)

# Flow from node k to node l on edge from node i to node j
@variable(BN, x[k=1:B,l=1:B,i=1:B,j=1:B] >= 0)

# design pipe binary variable
@variable(BN, y[k=1:B,i=1:B,j=1:B], Bin)
for k=1:B
    if sum(Demand[k,l] for l=1:B)==0
        for i=1:B
            for j=1:B
                fix(y[k,i,j],0; force = true)
            end
        end
    end
end

# digging variables: q[i,j]=1, if a digging is done between bar i and bar j
@variable(BN, q[i=1:B,j=1:B], Bin) 
for i=1:B
    for j=1:B
        if i>=j
            fix(q[i,j],0; force = true)
        end
    end
end

# Minimize path cost
@objective(BN,
           #Min, pc
           Min, sum( Distance[i,j]*q[i,j] for i=1:B,j=1:B)
           )

# balance constraint
@constraint(BN, [i=1:B,k=1:B,l=1:B],
            sum( x[k,l,j,i] for j=1:B) - sum( x[k,l,i,j] for j=1:B) ==
            (i==k ? -Demand[k,l] : 0) + (i==l ? Demand[k,l] : 0)
            )

# network design constraint
@constraint(BN, [k=1:B,i=1:B,j=1:B],
            sum( x[k,l,i,j] for l=1:B) <= PipeCap*y[k,i,j]
            )


# network design constraint
@constraint(BN, [k=1:B,i=1:B,j=1:B],
            y[k,i,j] + y[k,j,i] <= q[i,j]+q[j,i]
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
            if value(q[i,j]) > 0.001
                println("q:  $(Bars[i]) <-> $(Bars[j]) val: $(value(q[i,j]))  Distance: (Distance[i,j])") 
                for k=1:B
                    if value(y[k,i,j]) > 0.001
                        println("  beer: $(k) y:  $(Bars[i]) -> $(Bars[j]) val: $(value(y[k,i,j]))  Distance: $(Distance[i,j])")  
                    end
                    if value(y[k,j,i]) > 0.001
                        println("  beer: $(k) y:  $(Bars[j]) -> $(Bars[i]) val: $(value(y[k,j,i]))  Distance: $(Distance[j,i])")     
                    end
                end
            end
        end
    end
else
  println("  No solution")
end
#************************************************************************

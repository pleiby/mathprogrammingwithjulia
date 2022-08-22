#************************************************************************
# Chair Logistics Assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
Plants = ["P1", "P2"]            # set of plants
P = length(Plants) # P is the size of the Plants set
Depots = ["D1", "D2", "D3", "D4", "D5", "D6"]
D = length(Depots)
Retailers = ["R1", "R2", "R3", "R4","R5","R6"]
R = length(Retailers)
PlantCapacity = [7500, 8500] # plant capacity in chairs           
DepotCapacity = [3250, 3500, 3500, 3000, 3750, 3250] # depot capacity in chairs
Ret = [1500 2500 2000 3000 2000 3000] # retailer capacity in chairs
PD_Dist = [ 137  92  48 173  88 109; # Distance between Plants and Depots
            54  109 111  85 128 105]

PR_Dist = [307 260 215 196 148 268;
           234 173 194 264 204 218]

DR_Dist = [ 109  58  65 187 128  88;
            214 163  54  89  26 114;   
            223 173  97  71  29 162;
            81   51 133 239 170 155;
            223 172  62  80  13 124;
            185 135  31 113  54  96  
            ]
TruckCap=40
TruckCostKM=1.5
DepotConstructCost=[   0    0    0    0 5000 5000]
DepotCancelProfit= [5000 5000 5000 5000    0    0]
#************************************************************************

#************************************************************************
# Model
CL = Model(HiGHS.Optimizer)

@variable(CL, xpd[p=1:P, d=1:D] >= 0)
@variable(CL, xpr[p=1:P, r=1:R] >= 0)
@variable(CL, xdr[d=1:D, r=1:R] >= 0)
@variable(CL, ypd[p=1:P, d=1:D] >= 0, Int)
@variable(CL, ypr[p=1:P, r=1:R] >= 0, Int)
@variable(CL, ydr[d=1:D, r=1:R] >= 0, Int)

@variable(CL, q[d=1:D], Bin) # 1 if depot exists

# Minimize transporatation cost
@objective(CL, Min,
           sum( TruckCostKM*PD_Dist[p,d]*ypd[p,d] for p=1:P, d=1:D) +
           sum( TruckCostKM*PR_Dist[p,r]*ypr[p,r] for p=1:P, r=1:R) +
           sum( TruckCostKM*DR_Dist[d,r]*ydr[d,r] for d=1:D, r=1:R) +
           sum( DepotConstructCost[d]*q[d] for d=1:D) -
           sum( DepotCancelProfit[d]*(1-q[d]) for d=1:D)
           )

@constraint(CL, [p=1:P],
            sum(xpd[p,d] for d=1:D) + sum(xpr[p,r] for r=1:R) <= PlantCapacity[p])

@constraint(CL, [d=1:D],
            sum(xdr[d,r] for r=1:R) <= DepotCapacity[d]*q[d])

@constraint(CL, [d=1:D],
            sum(xpd[p,d] for p=1:P) == sum(xdr[d,r] for r=1:R))

@constraint(CL, [r=1:R],
            sum(xpr[p,r] for p=1:P) + sum(xdr[d,r] for d=1:D) == Ret[r])


@constraint(CL,[p=1:P, d=1:D], xpd[p,d] <= TruckCap*ypd[p,d] )

@constraint(CL,[p=1:P, r=1:R], xpr[p,r] <= TruckCap*ypr[p,r] )

@constraint(CL,[d=1:D, r=1:R], xdr[d,r] <= TruckCap*ydr[d,r] )
#************************************************************************


#************************************************************************
# solve
optimize!(CL)
println("Termination status: $(termination_status(CL))")
#************************************************************************


#************************************************************************
# Report results
let
println("-------------------------------------");
if termination_status(CL) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(CL))")
    for d=1:D
        if round.(Int8,value(q[d]))==1
            println("Using Depot: $(Depots[d])")
        else
            println("NOT Using Depot: $(Depots[d])")
        end
    end
else
  println("  No solution")
end
println("--------------------------------------");
end
#************************************************************************



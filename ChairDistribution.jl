#************************************************************************
# Chair Distribution Assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
using Printf
#************************************************************************

#************************************************************************
# PARAMETERS
Plants = ["P1", "P2"]            # set of plants
P = length(Plants) # P is the size of the Plants set
Depots = ["D1", "D2", "D3", "D4"]
D = length(Depots)
Retailers = ["R1", "R2", "R3", "R4","R5","R6"]
R = length(Retailers)
PlantCapacity = [7500, 8500] # plant capacity in chairs           
DepotCapacity = [3250, 3500, 3500, 3000] # depot capacity in chairs
RetailerRequirements = [1500 2500 2000 3000 2000 3000] # retailer capacity in chairs
PDdist = [ 137  92  48 173; # Distance between Plants and Depots
            54  109 111  85]

PRdist = [307 260 215 196 148 268;
           234 173 194 264 204 218]

DRdist = [ 109  58  65 187 128  88;
            214 163  54  89  26 114;   
            223 173  97  71  29 162;
            81   51 133 239 170 155;
            ]
F=0.0375
#************************************************************************

#************************************************************************
# Model
CD = Model(HiGHS.Optimizer)

@variable(CD, xpd[p=1:P, d=1:D] >= 0)
@variable(CD, xpr[p=1:P, r=1:R] >= 0)
@variable(CD, xdr[d=1:D, r=1:R] >= 0)

# Minimize transporatation cost
@objective(CD, Min,
           sum( PDdist[p,d]*F*xpd[p,d] for p=1:P, d=1:D) +
           sum( PRdist[p,r]*F*xpr[p,r] for p=1:P, r=1:R) +
           sum( DRdist[d,r]*F*xdr[d,r] for d=1:D, r=1:R))

@constraint(CD, [p=1:P],
            sum(xpd[p,d] for d=1:D) + sum(xpr[p,r] for r=1:R) <= PlantCapacity[p])

@constraint(CD, [d=1:D],
            sum(xdr[d,r] for r=1:R) <= DepotCapacity[d])

@constraint(CD, [d=1:D],
            sum(xpd[p,d] for p=1:P) == sum(xdr[d,r] for r=1:R))

@constraint(CD, [r=1:R],
            sum(xpr[p,r] for p=1:P) + sum(xdr[d,r] for d=1:D) == RetailerRequirements[r])

print(CD)
#************************************************************************


#************************************************************************
# solve
optimize!(CD)
println("Termination status: $(termination_status(CD))")
#************************************************************************


#************************************************************************
# Report results
let
println("-------------------------------------");
if termination_status(CD) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(CD))")

    
    @printf "Plant transports\n"
    for p=1:P
        @printf "\t%s\n" Plants[p]
        @printf "\t\tDepots\n" 
        for d=1:D
            if value(xpd[p,d])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Depots[d] value(xpd[p,d])
            end
        end
        
        @printf "\t\tRetailers\n" 
        for r=1:R
            if value(xpr[p,r])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Retailers[r] value(xpr[p,r])
            end
        end
        @printf "\n"
    end

    @printf "Depots\n"
    for d=1:D
        @printf "\t%s\n" Depots[d]
        for r=1:R
            if value(xdr[d,r])>0.001
                @printf "\t\t%s\tTransport: %.2f\n" Retailers[r] value(xdr[d,r])
            end
        end

        @printf "\n"
    end
else
  println("  No solution")
end
println("--------------------------------------");
end
#************************************************************************

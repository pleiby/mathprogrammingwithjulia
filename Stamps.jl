#************************************************************************
# Stamp, "Mathematical Programming Modelling" (42112)
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
include("stamp_bid_data.jl")
(B,S)=size(BidSets)
println("Bids: $B   stamps: $S")
#************************************************************************

#************************************************************************
# Model
stamps = Model(HiGHS.Optimizer)

# accept bid or not, yes if x[b]=1
@variable(stamps, x[1:B], Bin)

# Max sales profit
@objective(stamps, Max, sum( BidPrice[b] * x[b] for b=1:B) )  

@constraint(stamps, [s=1:S],
            sum( BidSets[b,s]*x[b] for b=1:B) <= 1 )

print(stamps)
#************************************************************************

#************************************************************************
# solve
optimize!(stamps)
println("Termination status: $(termination_status(stamps))")
#************************************************************************

#************************************************************************
# Report results
let
if termination_status(stamps) == MOI.OPTIMAL
    println("RESULTS:")
    println("Stamps result: $(objective_value(stamps))")
    not_sold::Int8=0
    for s=1:S
        sold=sum(BidSets[b,s]*value(x[b]) for b=1:B)
        println("Stamp: $(s) : $(sold)")
        if sold < 1
            not_sold+=1
        end
    end
    println("Not sold stamps : $(not_sold)")
else
  println("  No solution")
end
end
#************************************************************************


#************************************************************************
println("Successfull end of $(PROGRAM_FILE)")
#************************************************************************

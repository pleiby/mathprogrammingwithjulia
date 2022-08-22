#************************************************************************
# Workplan Teaching Assistant Assignment 1 question, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
include("WorkplanData.jl")
#************************************************************************

#************************************************************************
# Model
taworkplan = Model(HiGHS.Optimizer)

# 1 if ta is working on time t on day d
@variable(taworkplan, x[ta=1:TA,p=1:P,d=1:D],Bin) 

# Minimize summed Inconvenience
@objective(taworkplan, Min,
           sum( Inconvenience[ta,p,d]*x[ta,p,d]
                for ta=1:TA,p=1:P,d=1:D))
           
# satisfy deman for TAs
@constraint(taworkplan, [p=1:P,d=1:D],
            sum( x[ta,p,d] for ta=1:TA) >= Demand[p,d])

# max no of working hours is 52
@constraint(taworkplan, [ta=1:TA],
            sum( x[ta,p,d] for p=1:P,d=1:D) == 52)
#************************************************************************


#************************************************************************
# solve
optimize!(taworkplan)
println("Termination status: $(termination_status(taworkplan))")
#************************************************************************


#************************************************************************
println("-------------------------------------");
if termination_status(taworkplan) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(taworkplan))")

    for ta=1:TA
        println("")
        println("")
        print("TA: $(TA_acronyms[ta])")
        for d=1:D
            print("\t$(d)")
        end
        println("")
        for p=1:P
            print("$(Periods[p])\t")
            for d=1:D
                if round.(Int8,value(x[ta,p,d]))==1
                    print("*\t")
                else
                    print("\t")
                end
            end
            println("")
        end
    end
else
    println("  No solution")
end
println("--------------------------------------");
#************************************************************************

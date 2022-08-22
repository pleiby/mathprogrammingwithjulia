#************************************************************************
# Project Scheduling Assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using Clp
#************************************************************************

#************************************************************************
# PARAMETERS

# Tasks to be performed for the shet building
Tasks = ["Remove Stuff","Shet Demolition","Pipe Work","Electric Work", "Flag Stones","Shet Foundations","Wood Frames","Painting","Roofing","Roofing Felt", "Interior Installations","Insert Stuff","Hand Over"       ]
T=length(Tasks)

# duration time in days to do the job
Duration = [1,3,5,3,7,4, 3,1,1,1,3,1,0]

MaxSpeedUp=[0,1,3,1,4,2,2,0,0,0,2,0,0]

Budget=10000

OverTimePay=[0,500,2000,4000,1000,1000,1500,0,0,0,1500,0,0]

Predecessors=zeros(T,T)
#1

#2
Predecessors[2,1]=1

#3
Predecessors[3,2]=1

#4
Predecessors[4,2]=1

#5
Predecessors[5,3]=1
Predecessors[5,4]=1

#6
Predecessors[6,3]=1
Predecessors[6,4]=1

#7
Predecessors[7,6]=1

#8
Predecessors[8,7]=1

#9
Predecessors[9,7]=1

#10
Predecessors[10,9]=1

#11
Predecessors[11,9]=1

#12
Predecessors[12,9]=1

#13
Predecessors[13,5]=1
Predecessors[13,8]=1
Predecessors[13,10]=1
Predecessors[13,11]=1
Predecessors[13,12]=1

Budget=5000
#Budget=10000
#Budget=5000000
#************************************************************************

#************************************************************************
# Model
schedule = Model(Clp.Optimizer)

@variable(schedule, 0 <= x[t=1:T]) # start time of task t

@variable(schedule, 0 <= y[t=1:T] <= MaxSpeedUp[t] ) # save time

# Minimize storage cost
@objective(schedule, Min, x[T])

# force predecessor relation
@constraint(schedule, [t1=1:T,t2=1:T; Predecessors[t2,t1]==1],
            x[t1] + Duration[t1] - y[t1] <= x[t2]
            )

@constraint(schedule,
            sum( OverTimePay[t]*y[t] for t=1:T) <= Budget
            )

print(schedule)
#************************************************************************


#************************************************************************
# solve
optimize!(schedule)
println("Termination status: $(termination_status(schedule))")
#************************************************************************

#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(schedule) == MOI.OPTIMAL
    println("RESULTS:")
    println("Objective: $(objective_value(schedule))")
    println("sol x: ", value.(x))  
    println("sol y: ", value.(y))  
    for t=1:T
        println("Task: \t", Tasks[t], " starting-day: \t", value(x[t]), " Duration: \t", Duration[t])
    end
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************

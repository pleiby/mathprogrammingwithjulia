#************************************************************************
# Project Scheduling Assignment, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS

# Tasks to be performed for the shet building
Tasks = ["Remove Stuff","Shet Demolition","Pipe Work","Electric Work", "Flag Stones","Shet Foundations","Wood Frames","Painting","Roofing","Roofing Felt", "Interior Installations","Insert Stuff","Hand Over"       ]
T=length(Tasks)

# duration time in days to do the job
Duration = [1,3,5,3,7,4,3,1,1,1,3,1,0]    

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
#************************************************************************

#************************************************************************
# Model
schedule = Model(HiGHS.Optimizer)

@variable(schedule, 0 <= x[t=1:T]) # start time of task t

# Minimize storage cost
@objective(schedule, Min, x[T])

# force predecessor relation
@constraint(schedule, [t1=1:T,t2=1:T; Predecessors[t2,t1]==1],
            x[t1] + Duration[t1] <= x[t2]
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
    for t=1:T
        println("Task: \t", Tasks[t], " starting-day: \t", value(x[t]), " Duration: \t", Duration[t])
    end
else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************

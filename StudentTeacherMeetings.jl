#************************************************************************
# Student Teacher Meeting, "Mathematical Programming Modelling" (42112)

#************************************************************************
# Intro definitions
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# Data
include("StudentTeacherMeetingData_15_6.jl")
#include("StudentTeacherMeetingData_20_6.jl")
#include("StudentTeacherMeetingData_25_10.jl")
#include("StudentTeacherMeetingData_25_8.jl")
#include("StudentTeacherMeetingData_30_10.jl")
#include("StudentTeacherMeetingData_40_10.jl")

# S: no of students   : in data file
# T: no of teachers   : in data file
# TS: no of timeslots : in data
println("Students: $(S) Teachers: $(T)  Timeslots: $(TS)")
total_no_meetings=sum(StudentTeacherMeetings[:,:])
println("Total no. of meetings: $(total_no_meetings)")
#************************************************************************

#************************************************************************
# Model
stmeet = Model(HiGHS.Optimizer)

# 1 if student s has a meeting with teacher t in time ts
@variable(stmeet, x[1:S,1:T,1:TS],Bin) 

for s=1:S
    for t=1:T
        if StudentTeacherMeetings[s,t]==0
            for ts=1:TS
                fix(x[s,t,ts],0; force = true)
            end
        end
    end
end

# last meeting of student s
@variable(stmeet, y[1:S] >= 0) 

# Minimize summed Inconvenience
@objective(stmeet, Min, sum( y[s] for s=1:S ) )
           
# meetings has to occur (or not occur)
@constraint(stmeet, [s=1:S,t=1:T], sum( x[s,t,ts] for ts=1:TS ) == StudentTeacherMeetings[s,t])

# only one meeting pr timeslot for each student s
@constraint(stmeet, [s=1:S,ts=1:TS], sum( x[s,t,ts] for t=1:T ) <= 1)

# only one meeting pr timeslot for each teacher t
@constraint(stmeet, [t=1:T,ts=1:TS], sum( x[s,t,ts] for s=1:S ) <= 1)

# force value of y to last meeting for each student
@constraint(stmeet, [s=1:S,ts=1:TS], ts*sum( x[s,t,ts] for t=1:T ) <= y[s])
#************************************************************************


#************************************************************************
# solve
optimize!(stmeet)
println("Termination status: $(termination_status(stmeet))")
#************************************************************************


#************************************************************************
println("-------------------------------------");
if termination_status(stmeet) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(stmeet))")
    println("Minimal num of meetings: $(sum(StudentTeacherMeetings[:,:]))")
    println("Solve time: $(solve_time(stmeet))")
else
    println("  No solution")
end
println("--------------------------------------");
#************************************************************************


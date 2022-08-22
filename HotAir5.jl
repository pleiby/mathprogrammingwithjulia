#************************************************************************
# HotAir Assignment, Question 5, "Mathematical Programming Modelling" (42112)
using JuMP
using HiGHS
#************************************************************************

#************************************************************************
# PARAMETERS
cities = ["Brownsville", "Dallas", "Austin", "El Paso"]
C=length(cities)
time = [1,2,3]
T=length(time)

# ticket-prices P[cf,ct]
P=[
  0  99  89 139;
109   0  99 169;
109 104   0 129; 
159 149 119   0]

# takeoff cost TOC[cf,ct]
TOC=[
   0  5100  4400  8000;
5100     0 11200  6900;
4400 11200     0  5700;
8000  6900  5700     0]

# passenger demand D[t,cf,ct]
D=zeros(Int16,T,C,C)
D[1,:,:]=
[  # timeperiod 1
   0  50  53  14 ;
  84   0  80  21 ;
  17  58   0  40 ;
  31  79  34   0
   ]
D[2,:,:]=
[  # timeperiod 2
   0  15  53  52 ;
  17   0 134  29 ;
  24 128   0  99 ;
  23  15  30   0
]   
D[3,:,:]=
[  # timeperiod 3
   0   3  16   9 ;
  48   0 104  48 ;
  62  92   0  68 ;
  13  15  21   0    
   ]
# plane starting places
H=[2 1 1 0]
PlaneCapacity=120
#************************************************************************

#************************************************************************
# Model
hotair = Model(HiGHS.Optimizer)

# passengers transported in time-period t from city i to city j
@variable(hotair, x[t=1:T,cf=1:C,ct=1:C] >= 0)
for t=1:T
    for c=1:C
        set_upper_bound(x[t,c,c],0)
    end
end

# planes flying in timeperiod t from city i to city j
@variable(hotair, 0 <= y[t=1:T,cf=1:C,ct=1:C] <= 4, Int)

# planes overnighting in city c
@variable(hotair, 0 <= v[c=1:C] <= 4, Int)

# passengers transported in time-period t from city cf to city cm
# (city midt) and in timepeiod t+1 from city cm to city ct
@variable(hotair, 0 <= u[t=1:T,cf=1:C,cm=1:C,ct=1:C] <= 480, Int)
for t=1:T
    for c1=1:C
        for c2=1:C
                set_upper_bound(u[t,c1,c1,c2],0)
                set_upper_bound(u[t,c1,c2,c2],0)
        end
    end
end
for cf=1:C
    for cm=1:C
        for ct=1:C
            set_upper_bound(u[3,cf,cm,ct],0)
        end
    end
end

# Maximize profit
@objective(hotair, Max,
           sum( P[cf,ct]*x[t,cf,ct] for t=1:T, cf=1:C, ct=1:C) +
           sum( 0.7*P[cf,ct]*u[t,cf,cm,ct]
                for t=1:T, cf=1:C, cm=1:C, ct=1:C) - 
           sum( TOC[cf,ct]*y[t,cf,ct] for t=1:T, cf=1:C, ct=1:C)
           )

# demand limit
@constraint(hotair, [t=1:T,cf=1:C,ct=1:C],
            x[t,cf,ct] <= D[t,cf,ct] )

# discount demand limit
@constraint(hotair, [t=1:T,cf=1:C,ct=1:C],
            sum(u[t,cf,cm,ct] for cm=1:C) <= 0.5*D[t,cf,ct] )

# plain capacity limit
@constraint(hotair, [t=1:T,cf=1:C,ct=1:C],
            x[t,cf,ct] + sum( u[t,cf,ct,c] for c=1:C) +
            (t>1 ? (sum( u[t-1,c,cf,ct] for c=1:C)) : 0) <=
            PlaneCapacity*y[t,cf,ct] )

# where the planes over-night, i.e. starting from in the morning
@constraint(hotair, [cf=1:C],
            sum( y[1,cf,c] for c=1:C) == v[cf] )

# limit the number of overnights
@constraint(hotair, sum( v[c] for c=1:C) == 4 )

# plane balance, what goes in must come out
@constraint(hotair, [t=1:T,c1=1:C],
sum( y[t,c2,c1] for c2=1:C) ==
sum( (t<T ? y[t+1,c1,c2] : y[1,c1,c2]) for c2=1:C) )
#************************************************************************

#************************************************************************
# solve
optimize!(hotair)
println("Termination status: $(termination_status(hotair))")
#************************************************************************

#************************************************************************
# Report results
println("-------------------------------------");
if termination_status(hotair) == MOI.OPTIMAL
    println("RESULTS:")
    println("objective = $(objective_value(hotair))")
    yres=round.(Int64,value.(y))
    xres=round.(Int64,value.(x))
    ures=round.(Int64,value.(u))
    for t=1:T
        println("Time step: $(t)")
        for cf=1:C # from
            for ct=1:C # to
                if yres[t,cf,ct]>0
                    first=sum( ures[t,cf,ct,k] for k=1:C)
                    second=sum( ures[t,k,cf,ct] for k=1:C)
                    
                    print( " Plane: $(yres[t,cf,ct])    \t")
                    print( " Passengers: $(xres[t,cf,ct]) first: $(first)   second: $(second)  \t")
                    print( " $(cities[cf])  - > $(cities[ct] )   \t ")
                    print( " Profit: $((xres[t,cf,ct]*P[cf,ct]) - TOC[cf,ct]) \t Take off Cost: $(TOC[cf,ct])    \t")  
                    println( " Total Ticket sale: $((xres[t,cf,ct]*P[cf,ct]) )     ")  
                end
            end
        end
    end

else
  println("  No solution")
end
println("--------------------------------------");
#************************************************************************

#************************************************************************
println("Successfull end of $(PROGRAM_FILE)")
#************************************************************************

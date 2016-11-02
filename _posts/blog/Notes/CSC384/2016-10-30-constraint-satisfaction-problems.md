---
layout: post
title:  "Constraint Satisfaction Problems"
categories: Blog Notes AI
tags: ["AI", "CSC384", "CSP"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Constraint Satisfaction Problems (Backtracking Search) Overview
	1. CSP v.s Traditional Search Problems
	2. Feature Vectors
	3. Constraint Graph
2. Solving CSPs
	1. Viewing CSP as Search Problem
	2. Backtracking Search Algorithm
	3. Constraint Propagation
		1. Forward Checking
		2. Generalizaed Arc Consistency
		3. Heuristics

<!--more-->
---
## Constraint Satisfaction Problems (Backtracking Search) Overview

### CSP v.s Traditional Search Problems

- CSP does not care about the _sequence of moves_ to reach goal state

### Feature Vectors

- Represent states as __vectors of feature values__
- Formalization
	- A set of __features/variables__ `V1, ... Vn`
	- __Domain__ for each variable `Dom[Vi]`
	- A set of __constraints__ `C1, ..., Cm`
		- __Scope__: a set of variables it operates over
		- Unary, binary, higher-order constraints
	- __State__: assignment of value for each variable
	- __Partial state__: assignment of value for some variables
	- __Goal state__: a state satisfying all __constraints__

### Constraint Graph

- Nodes: __variables__; arcs: __constraints__

## Solving CSPs

- Search through the space of partial assignments
- Order of assignments does not matter
- If we falsify a constraint, we immediately reject the current partial assignment

### Viewing CSP as Search Problem

- __Initial state__: empty assignment
- __Successor function__: a value assigned to any unassigned variable s.t. no constraints return false
- __Goal test__: complete assignment

### Backtracking Search Algorithm

- Similar to DFS

```
BT(Level):
	If all variables assigned:
		PRINT Value of each Variable
		RETURN

	V := PickUnassignedVariable()
	Assigned[V] := TRUE
	for d := each member of Domain(V):
		Value[V] := d
    	ConstraintsOK = TRUE
      	for each constraint C such that
            a) V is a variable of C and
			b) all other variables of C are assigned: 
			If C is not satisfied by the set of current assignments:
				ConstraintsOK = FALSE
				break
      	If ConstraintsOk == TRUE:
			BT(Level+1)
	Assigned[V] := FALSE //UNDO as we have tried all of V’s values return
```

### Constraint Propagation

- Look ahead

#### Forward Checking

- When instantiating a variable, check all constrants with __only one ininstantiated variable__ remaining
- Prune values of that variable that violate the constraint
- Algorithm

	```
	FCCheck(C,x):
		// C is a constraint with all its variables already assigned, except for variable x

		for d := each member of CurDom[x]:
			If making x = d together with previous assignments
        to variables in scope C falsifies C:
    			remove d from CurDom[x]

 		If CurDom[x] = {}:
 			return DWO (Domain Wipe Out)
 		Else:
 			return ok

 	FC(Level):
		If all variables assigned:
        	PRINT Value of each Variable
        	RETURN

		V := PickAnUnassignedVariable()
   		Assigned[V] := TRUE
   		for d := each member of CurDom(V):
			Value[V] := d
        	DWOoccured:= False
        	for each constraint C over V such that
            	a) C has only one unassigned variable X in its scope:
				If (FCCheck(C,X) == DWO):
	            	DWOoccurred:= True
					break
			If(not DWOoccured)
	        	FC(Level+1)
	        RestoreAllValuesPrunedByFCCheck()
		Assigned[V] := FALSE
		return;
	```


#### Generalizaed Arc Consistency

- `C(V1, ..., Vn)` is GAC with regard to `Vi` iff for every value of `Vi`, there exist values of `V1, ..., Vn` that satisfy C
- If for `Vi = d` is not consistent wrt the constraint, `d` is __arc inconsistent__ and can be removed from domain of `Vi`
- A constraint that is GAC may become non-GAC due to pruning of domain values during search
- Algorithm

	```
	GAC_Enforce():
	// GAC-Queue contains all constraints one of whose variables has had its domain reduced

	while GACQueue not empty:
		C = GACQueue.extract()
		for V := each member of scope(C):
			for d := CurDom[V]:
				Find an assignment A for all other variables in scope(C) such that C(A ∪ V=d) = True
				if A not found:
					CurDom[V] = CurDom[V] – d 
				if CurDom[V] = ∅:
	                empty GACQueue
	                return DWO
				else:
					push all constraints C’ s.t. V ∈ scope(C’) and C’ !∈ GACQueue on to GACQueue
	return TRUE

	GAC(Level):
		If all variables are assigned:
			PRINT Value of each Variable
			RETURN

		V := PickAnUnassignedVariable()
		Assigned[V] := TRUE
		for d := each member of CurDom(V):
			Value[V] := d
			Prune all values of V != d from CurDom[V]
			for each constraint C whose scope contains V:
				Put C on GACQueue
			if(GAC_Enforce() != DWO):
				GAC(Level+1)
			RestoreAllValuesPrunedFromCurDoms()

		Assigned[V] := FALSE
		return;
	```
	- May keep track of __supports__ to avoid having to search through all possible assignments and check satisfication
	- Check if current support still valie, i.e. all values it assigns still lie in the variables' current domains

#### Heuristics

- Ordering of variables
	- __Minimum Remaining Values (MRV)__: returns the variable with the most constrained current domain
	- __Degree Heuristic (DH)__: returns variable imposing the most constraints on remaining unassigned variables
- Ordering of values
	- __Least Constraining Value (LCV)__: the best value is the one ruling out the fewest domain values in other variables that share at least one constraint with var


















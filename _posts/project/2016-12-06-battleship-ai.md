---
layout: post
title:  "Battleship AI"
link: "https://github.com/pyliaorachel/battleship-ai"
background_color: "rgba(16, 16, 16, 0.2)"
categories: Project AI
tags: CSP AI
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

<p align="center"><img width="800px" height="400px" src="http://vignette4.wikia.nocookie.net/habbo/images/9/9d/Battleship_Game.png/revision/latest?cb=20120731170300&path-prefix=en" /></p>

[Battleship](https://github.com/pyliaorachel/battleship-ai) is an AI project for identifying battleships hidden in the map given the information of how many targets there are in each row and column.

<!--more-->
---
## Battleship Introduction

A __Battleship Puzzle__ is a board of size `n * n`, with numbers along each row and column indicating the number of grids in this row or column that is occupied by a ship. 

The number of ships of each size is given. Find a placement of the given battleships in the board that matches the number along the columns and rows.

```
# Sample Problem    # Input

  1 3 2 2             ships = [0,1,2,1]       // 1 ship of size 1, 2 ships of size 2, etc.
2 ? ? ? ?             row_targets = [2,1,2,3] // 2 ships occupy row 0, 1 ship occupies row 1, etc.
1 ? ? ? ?             col_targets = [1,3,2,2] // 1 ship occupies column 0, 3 ships occupy row 2, etc.
2 ? ? ? ?
3 ? ? ? ?

# Sample Solution

0 0 2 2              # 2 2 represents a ship of size 2 in left-right direction
0 2 0 0
0 2 0 1
3 3 3 0
```

In this project, the problem is modeled into a [Constraint Satisfaction Problem (CSP)](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem), which is solved by the framework provided in class. How do we design the CSP model to suit the problems' need?

We came up with 3 models, each having its advantages and limitations. Below, how we came up with the models will be described; for more details, e.g. how the state variables/variable domains/constraints are defined, they are well-written in our [report](https://github.com/pyliaorachel/battleship-ai/blob/master/csc384-project.pdf).

## CSP Models

#### Model 2 - Pure CSP

Let me present model 2 first, since this was the first one we came up with. The thought was pretty naive - model each grid on board into a variable, where the variable domain values are integers of any valid ship length. Running the framework should solve the problem well.

A serious problem came up: it was not trivial to separate between ships of the same size in contact with each other. For example:

```
0 0 3 0
3 3 3 3
0 0 3 0
```

is not valid. How to tell though?

We decided to make the domain value look like this:

```
(ship_id,ship_length) e.g. (0,3) => the 0th ship of size 3
```

to uniquely identify each ship of the same length. Now the separation problem could be solved.

Some other limitations:

1. When creating constraints, the constraint scope includes __all variables on board__ to check if ship numbers are consistent with the given input. The large domain hurts the constraint construction time.
2. The method is totally not clever - it wastes a lot of time assigning values to neighbor variables that can't even form a complete ship!

Hence model 1 is created.

#### Model 1 - CSP + Custom Backtracking Search

The key point is we want to assign __a ship__ at a time instead of __a grid__. To achieve this, we had to modify the framework a bit and design our own backtracking search (see [battleship_BT.py](https://github.com/pyliaorachel/battleship-ai/blob/master/battleship_BT.py)). The backtrack steps are as follows:

```
Step 1. Assign a variable (say grid x) with ship size l. The assignments are in top-left to bottom-right direction.
Step 2. Assign all variables starting from grid x towards the right until a ship of size l is formed.
Step 3. Keep going until failure and backtrack to grid x.
Step 4. Assign all variables starting from grid x towards the bottom until a ship of size l is formed.
Step 5. Keep going. If backtrack, assign a ship of different sizes (depends on value ordering heuristic).
Step 6. Valid assignment found. Solved.
```

This approach significantly sped up our program by avoiding pointless assignments during progress. The construction time was also reduced since we don't need a constraint with scope including all variables now! But some drawbacks can still be seen:

1. Writing the customized backtrack search was error-prone. We had to manually assign values to the required variables, reverse the assignments, change directions, check boundaries, etc.
2. Variable ordering heuristics seem to have no power in this model, since the assignment must go in a certain direction, in our case, from top-left to bottom-right.

#### Model 3 - Pure CSP

Although we were pretty happy with the performance of model 2, we still wanted to have a model that was pure CSP (i.e. didn't require modifying the CSP framework) but was more clever than model 2.

We made some changes in the variable definition - a variable now represents __a ship__ instead of __a grid__ in hope of avoiding the useless assignment problem. Multiple ship variables of different sizes and in different directions might overlap on the same grid, and the number of variables significantly grew.

The result was that since the space requirement grew, we got stuck in model construction! The performance in backtracking was believed to be improved though.

### Comparison

|   | Model 1 | Model 2 | Model 3 |
|:-:|:--------|:--------|:--------|
|Type|CSP + Search|CSP|CSP|
|Runtime|Fast. Fast fast.|Slow. Stuck in BT search.|Slow. Stuck in model construction.|
|Space|Exponential.|Exponential. Also exponentially larger than model 1.|Exponential. Even larger than model 2.|
|Advantage|Efficiency.|Easy to implement.|Avoids useless assignments as in model 2 and improves efficiency.|
|Drawback|1. Customizing BT search is error-prone.<br />2. Variable ordering heuristics are useless.|1. Takes time finding satisfying tuples for each constraint due to large scope and domain.<br />2. Many useless assignments since neighbor variable assignments may not even form a legal ship.|Takes more time than model 2 forming satisfying tuples for each constraint due to big scope and many constraints.|

## Playing with Battleship-AI

Feel free to follow the instructions [here](https://github.com/pyliaorachel/battleship-ai) and find out the battleship placements of your peer!








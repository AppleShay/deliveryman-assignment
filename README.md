# Delivery Man Assignment

This repository contains our solution for the **Delivery Man** assignment in the AI course (Uppsala University, Data Science & Data Engineering, Master’s level).  
The task was to implement a controller function `myFunction` that uses **A\*** search to pick up and deliver packages efficiently in a dynamic grid-world with changing road costs.

---

## 📦 Project Structure
- `myFunction.R` – contains the controller (`myFunction`) and helper functions.
- (Other files like `DM.r` were provided by the instructors as the game engine and are not modified here.)

---

## 🚗 How It Works
Each turn, the game engine (`runDeliveryMan`) calls **`myFunction(roads, car, packages)`**, where:
- `roads` = list with `hroads` and `vroads` matrices (traffic costs).
- `car` = list with car state (`x`, `y`, `load`, etc.).
- `packages` = matrix of deliveries (pickup x/y, drop-off x/y, status).

The function must return the `car` object with `car$nextMove` set to one of:
- `2` = down  
- `4` = left  
- `5` = stay  
- `6` = right  
- `8` = up  

---

## 🧠 Functions in `myFunction.R`

### `manhattan(x1, y1, x2, y2)`
- Computes Manhattan distance between two points.  
- Used as the heuristic `h(n)` in A*.

### `DIRS`
- A lookup table mapping human-readable directions to keypad codes:  
  - Up = 8, Down = 2, Left = 4, Right = 6, Stay = 5.

### `neighbors_with_costs(x, y, roads, dim)`
- Generates all valid neighbors from `(x,y)` with their move cost and direction code.  
- Reads costs from `roads$hroads` and `roads$vroads`.

### `.pop_best(frontier)`
- Utility function for A*: selects and removes the node with the smallest `f` value from the frontier.

### `astar_first_move(start, goal, roads)`
- Runs A* search from `start` to `goal`.  
- Expands nodes by `f(n) = g(n) + h(n)`.  
- Uses Manhattan distance as the heuristic.  
- Returns **only the first move** of the optimal path (since traffic changes every turn).

### `.choose_target(car, packages)`
- Decides where the car should head:  
  - If carrying a package (`car$load > 0`) → target its **drop-off**.  
  - Else → go to the **nearest pickup** (by Manhattan distance).

### `myFunction(roads, car, packages)`
- Main controller submitted for grading.  
- Chooses a target with `.choose_target()`.  
- Plans a path with `astar_first_move()`.  
- Sets `car$nextMove` to the best first step.  
- Returns the updated `car` object.

---

## 📊 Performance
Using `testDM(myFunction, n=500, verbose=1)`, my solution achieved:
- **Mean score:** ~171 turns (requirement ≤ 180 ✅)
- **Std Dev:** ~38 (requirement ≤ 39 ✅)
- **Runtime:** ~33 seconds for 500 games (requirement ≤ 250s ✅)

This comfortably passes the grading threshold.

---

## ▶️ Running
In RStudio:

```r
source("myFunction.R")
runDeliveryMan(myFunction, doPlot=TRUE)   # Visualize one game
testDM(myFunction, verbose=1)             # Evaluate on 500 games

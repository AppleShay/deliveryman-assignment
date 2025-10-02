manhattan <- function(x1,y1,x2,y2) abs(x1-x2) + abs(y1-y2)
DIRS <- list(U=8, D=2, L=4, R=6, S=5)

# neighbors and costs from a node (x,y)
neighbors_with_costs <- function(x, y, roads, dim) {
  out <- list()
  # Right: cost uses hroads[x, y]
  if (x < dim) out <- c(out, list(list(nx=x+1, ny=y, cost=roads$hroads[x, y], code=DIRS$R)))
  # Left: cost uses hroads[x-1, y]
  if (x > 1)   out <- c(out, list(list(nx=x-1, ny=y, cost=roads$hroads[x-1, y], code=DIRS$L)))
  # Up: cost uses vroads[x, y]
  if (y < dim) out <- c(out, list(list(nx=x, ny=y+1, cost=roads$vroads[x, y], code=DIRS$U)))
  # Down: cost uses vroads[x, y-1]
  if (y > 1)   out <- c(out, list(list(nx=x, ny=y-1, cost=roads$vroads[x, y-1], code=DIRS$D)))
  out
}

# pop node with smallest f from a list-based frontier
.pop_best <- function(frontier) {
  fs <- sapply(frontier, `[[`, "f")
  i <- which(fs == min(fs))
  if (length(i) > 1) {
    hs <- sapply(frontier[i], `[[`, "h")
    i <- i[which.min(hs)]
  }
  list(best = frontier[[i]], rest = frontier[-i])
}


# A* that returns ONLY the first move code (2/4/5/6/8)
astar_first_move <- function(start, goal, roads) {
  dim <- nrow(roads$vroads) # board size
  if (start$x == goal$x && start$y == goal$y) return(DIRS$S)
  
  h0 <- manhattan(start$x, start$y, goal$x, goal$y)
  start_node <- list(x=start$x, y=start$y, g=0, h=h0, f=h0, firstMove=NA_integer_)
  frontier <- list(start_node)
  
  # best g seen per cell (dim x dim)
  best_g <- matrix(Inf, nrow=dim, ncol=dim)
  best_g[start$x, start$y] <- 0
  
  while (length(frontier) > 0) {
    popped <- .pop_best(frontier); n <- popped$best; frontier <- popped$rest
    
    if (n$x == goal$x && n$y == goal$y) {
      return(if (is.na(n$firstMove)) DIRS$S else n$firstMove)
    }
    
    for (nb in neighbors_with_costs(n$x, n$y, roads, dim)) {
      g2 <- n$g + nb$cost
      if (g2 + 1e-9 < best_g[nb$nx, nb$ny]) {
        best_g[nb$nx, nb$ny] <- g2
        h2 <- manhattan(nb$nx, nb$ny, goal$x, goal$y)
        firstMove <- if (is.na(n$firstMove)) nb$code else n$firstMove
        child <- list(x=nb$nx, y=nb$ny, g=g2, h=h2, f=g2+h2, firstMove=firstMove)
        frontier <- c(frontier, list(child))
      }
    }
  }
  DIRS$S  # should rarely happen
}

# pickup==dropoff (finishes instantly, kills some long-tail cases)
.choose_target <- function(car, packages) {
  if (car$load > 0) return(list(x=packages[car$load,3], y=packages[car$load,4]))
  idx <- which(packages[,5]==0)
  if (!length(idx)) return(list(x=car$x, y=car$y))
  
  same <- idx[packages[idx,1]==packages[idx,3] & packages[idx,2]==packages[idx,4]]
  if (length(same)) return(list(x=packages[same[1],1], y=packages[same[1],2]))
  
  d <- abs(packages[idx,1]-car$x) + abs(packages[idx,2]-car$y)
  nearest <- idx[d==min(d)]
  if (length(nearest)>1) {
    drop_d <- abs(packages[nearest,1]-packages[nearest,3]) + abs(packages[nearest,2]-packages[nearest,4])
    k <- nearest[which.min(drop_d)]
  } else k <- nearest
  list(x=packages[k,1], y=packages[k,2])
}



myFunction <- function(roads, car, packages) {
  goal <- .choose_target(car, packages)
  move <- astar_first_move(list(x=car$x, y=car$y), goal, roads)
  car$nextMove <- move
  car$mem <- list()
  return(car)
}

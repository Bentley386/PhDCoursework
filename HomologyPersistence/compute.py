import dionysus as d
import numpy as np
from scipy.spatial.distance import squareform

# This code computes persistence barcodes 
# for the 9 cycle (C_9) graph with the graph metric.

# We have enumerated the vertices as {0,1,...,7,8}

# Construct the distance matrix
distMat = np.zeros((9,9))
for i in range(9):
    for j in range(9):
        # The distance between i and j is simply the minimum 
        # of two different paths we can take
        dist1 = max(i,j) - min(i,j)
        dist2 = min(i,j) + (9-max(i,j))
        distMat[i,j] = min(dist1,dist2)
# This transforms the distance matrix
# into a vector form that the library requires
distVect = squareform(distMat)

# fill_rips function makes a Vietoris-Rips filtratrion 
# First parameter is the distance matrix.
# Second parameter is the integer of up to which skeleton to compute 
# (here 10-skeleton, which is sufficient as we only have 9 points)
# Third parameter is the maximal radius up to which to compute
# the filtration. (Here 4 as larger distances do not appear).
f = d.fill_rips(distVect,10,4) 
p = d.homology_persistence(f) 
dgms = d.init_diagrams(p,f)
print("Starting to print the barcodes. \
      Homological degrees that do not have any are omitted.")
for i, dgm in enumerate(dgms):
    if len(dgm) == 0:
        continue
    print(f"Printing all the barcodes for homological degree {i}:")
    for pt in dgm: 
        print(pt) 

# Beginning of the coastal terrain generatino project 

# Importing the necessary libraries
import numpy as np # Numerical computation library
import random # For potential random generations 
import math # Mathematical functions 
############################################################################################################################
# Creating the coordinate grid 



# Creating the x and y arrays ranging from 0 to 2000 with a step of 1
# This creates a square grid of 2000x2000 points
x = np.arange(0, 2000, 1) # x coordinates from 0 to 1999
y = np.arange(0, 2000, 1) # y coordinates from 0 to 1999

# Creating a 2D grid from the x and y arrays
# meshgrid transforms the 1D arrays into 2D matrices
# X and Y will be matrices where each cell contains its coordinates
X, Y = np.meshgrid(x, y)


# Terrain generation function with geomorphological characteristics
def generer_terrain_avec_collines(X, Y, hauteur_max=100, facteur_lissage=0.001):
    """
    Generates terrain with controlled topographic variations

    Parameters : 
    - X, Y: Coordinate matrices
    - hauteur_max: Maximum height of terrain 
    - smoothing_factor: Controls altitude progression 

    Returns :
    - z : Height matrix
    """

    # Calculate the distance to the origin for each point 
    # Use the square root to obtain the Euclidean distance
    distance = np.sqrt(X**2 + Y**2)

    # Creation of a progressive base altitude 
    # log1p(x) = ln(1+x), for a smoother progression 
    # Altitude increases with distance from origin 
    altitude_base = hauteur_max * np.log1p(distance * facteur_lissage)

    # Create multi-frequency terrain variations
    # Combine different trigonometric functions to create relief 
    variations_terrain = (
        # Large low-frequency ripples 
        # Creates smooth, wide variations
        5 * np.sin(X * 0.01) * np.cos(Y * 0.01) +

        # Medium-frequency variations 
        # Adds medium-sized details
        3 * np.sin(X * 0.02) * np.sin(Y * 0.02) + 

        # Small variations at high frequency 
        # Introduces finer, more irregular details 
        2 * np.cos(X * 0.05) * np.sin(Y * 0.05)
    )

# Modulation of variations according to base altitude
# Variations will be greater far from the coastline 
# This creates a more pronounced relief effect away from the origin 
    z = altitude_base + variations_terrain * (altitude_base / hauteur_max)

    return z

# Calculates terrain altitude
# Uses previously defined function
z = generer_terrain_avec_collines(X, Y)

# Ensures there are no negative altitude values
# Any negative value will be reset to 0 
z = np.maximum(z, 0)

# Transformation of 3D data into a point array 
# vstack vertically stacks X, Y, z
# flatten() transforms 2D matrices into 1D arrays
# .T transposes result to column format
altitudes = np.vstack((X.flatten(), Y.flatten(), z.flatten())).T

# Altitude display (optional)
print (altitudes)


import csv # To export as a CSV file

# Export data as CSV file
# Saves data for later use
with open("altitudes_région_cotière.csv", "w", newline="") as file:
    # Creating a CSV writter
    writer = csv.writer(file)

    # Write headers (optional but recommended)
    writer.writerow(["X", "Y", "Z"])  

    # Write all altitude data
    writer.writerows(altitudes)

# Confirmation of file generation
print("Fichier CSV généré avec succès !")

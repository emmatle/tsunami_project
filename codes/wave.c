#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>

// Structure to represent a 3D GPS point with coordinates x, y, and altitude z
struct GpsPointxyz {
    double x;   // x coordinate (longitude)
    double y;   // y coordinate (latitude)   
    float z;    // Altitude z
};

// Function to display the coordinates of a GPS point
// Useful for debugging and data verification
void afficherxyz(struct GpsPointxyz * cart){
    // Prints the coordinates with controlled precision
    printf("coordonnées GPS cart : x : %.5f, y : %.5f, z : %.2f\n",cart->x, cart->y, cart->z);

};

// Function to read and extract coordinates from a text line (CSV)
int lireLigne(char * ligne, struct GpsPointxyz * point) {
    // Use sscanf to extract latitude, longitude, and altitude (x, y, and z)
    if (sscanf(ligne, "%lf,%lf,%f", &point->x, &point->y, &point->z) != 3) { 
    // Returns -1 if the information cannot be read correctly (fewer than 3 values extracted)
        return -1;
    }
    // Returns 0 to indicate that the information has been read correctly
    return 0;
};

// Function to read an entire file of GPS coordinates
int lireFichier(char * nomFichier, struct GpsPointxyz * tableauARemplir, int longueur) {
    // Open the file in read mode
    FILE * file = fopen(nomFichier, "r");
    if (file == NULL) return -1; //Return -1 if the file opening fails

    // Variable to temprarily store each line
    int n = 0; // Counter for the number of lines read
    char buffer[100];

    // Read the file line by line
    while (fgets(buffer, 100, file) != NULL) {
        // Stops if the maximum number of lines is reached 
        if (n >= longueur) break;

        // Attemps to read each line
        int ok = lireLigne(buffer, &tableauARemplir[n]);
        if (ok==0) n = n + 1; // Increments if the reading is successful
    }

    // Close the file anr return the number of lines read 
    fclose(file);
    return n;

};


// Prototype of the wave height calculation function
// Forward declaration for the compiler 
double waveheight(double initial_wave_height, double pente, double dist, double dist_max, double tauxDeCroissance , double sensibilitePente, double facteurHauteur);

// Function that will calculate the wave height.
// Takes into account several parameters to simulate wave propagation
// tauxDecroissance => controls the rate of decrease in height
// sensibilitePente => Slope sensitivity factor
double waveheight(double initial_wave_height, double pente,double dist,double dist_max,double tauxDeCroissance,double sensibilitePente, double facteurHauteur) {
    
    // If the distance exceeds tha maximum distance, return zero
    if (dist > dist_max){
        return 0;
    }


    // Normalization of the distance with a more gradual curve
    // Using a square root to soften the decay
    double distanceNormalisee = sqrt(dist / dist_max); 

    // Calculation of the slope impact with a sigmoid function that gradually reduces the effect of the slope
    double reductionPente = 1.0 / (1.0 + exp(-sensibilitePente * fabs(pente)));


    // Complex wave height calculation, takes into account:
    // - Initial height
    // - A multiplicative height factor
    // - Distance-based reduction
    // - Slope impact
    // - Exponential decay
    double wave_height = initial_wave_height * 
    facteurHauteur * // Potential increase in height
    (1.0 - distanceNormalisee) * // Distance-based reduction
    (1.0 - 0.5 * reductionPente) * // Reduced slope impact 
    exp(-tauxDeCroissance * distanceNormalisee); // Smoothed exponential attenuation

    // Returns 0 if the calculated height is very close to zero
    return (wave_height < 0.01) ? 0.0 : wave_height;

};

// Function to save the calculated points to a file
// Useful for export and later visualization (in Matlab)
int save_points_to_file(const char *filename, struct GpsPointxyz * point, int nombrePoints){
    // Open the file in wrtie mode
    FILE *file = fopen(filename, "w"); 
    if (file == NULL) return -1; // Stops if the file opening fails

    // Writes each point to the file
    for (int i = 0; i<nombrePoints; i++){
        fprintf(file, "%.6f %.6f %.6f\n",
        point[i].x,
        point[i].y,
        point[i].z);
    }
    fclose(file);
    return 0;
}

// Calculates the maximum distance between the origin point and all ohter points
double calculerDistanceMaximale(struct GpsPointxyz * points, int nbPoints){
    double max_distance = 0;
    // Loops through all the points starting from the second one
    for(int i = 1; i<nbPoints; i++) {
        // Calculation of the 3D Euclidean distance 
        double dist = sqrt(
            pow(points[i].x - points[0].x, 2) +
            pow(points[i].y - points[0].y, 2) + 
            pow(points[i].z - points[0].z, 2)
        );
        // Update of the maximum distance
        if (dist >max_distance) {
            max_distance = dist;
        }
    }
    return max_distance;
}

// Main function of the program
int main(){
    // Configuration parameters for the wave simulation

    // Variables for slope calculation
    double dist = 0 ; 
    double alt = 0 ;
    double pente = 0; 
    double dist_origine = 0;

    // Wave height parameters
    double min = 10 ; // Minimum height 
    double max = 30 ; // Maximum height
    double tauxDeCroissance = 0.02; // Controls the reduction of the height
    double sensibilitePente = 1.0; // Slope influence on height
    double facteurHauteur = 2.0; // Height multiplier 
    

    // Random generation of the initial wave height
    //need to initializes the random number generator with a seed value
    srand(time(NULL));
    double initial_wave_height = min + ((double)rand() / RAND_MAX) * (max - min);


    // Dynamic memory allocation for a large number of points
    struct GpsPointxyz *points = (struct GpsPointxyz *)malloc(4000000 * sizeof(struct GpsPointxyz));
    if (points == NULL) {
        printf("Erreur d'allocation mémoire.\n");
        return -1;
    }
    
    // Reading the GPS data file
    int nbPoints = lireFichier("altitudes_région_cotière.csv", points,4000000);
    // Just checking that the file has been successfully imported
    if (nbPoints <= 0) {
        printf("Erreur lors de la lecture du fichier.\n");
        free(points);
        return -1;
    }

    // Calculation of the maximum distance for wave propagation
    double distanceMaximale = calculerDistanceMaximale(points, nbPoints);

    // Simulation of the wave height for each point
    for (int i = 0 ; i < nbPoints ; i++){
        // Calculation of the slope between two consecutive points
        alt = points[i+1].z-points[i].z;

        // Calculation of the distance between the points
        dist = sqrt((points[i].x-points[i+1].x)*(points[i].x-points[i+1].x) + (points[i].y-points[i+1].y)*(points[i].y-points[i+1].y) + (points[i].z-points[i+1].z)*(points[i].z-points[i+1].z));
        
        // Distance relative to the origin point
        dist_origine = sqrt((points[i].x - points[0].x)*(points[i].x - points[0].x) + (points[i].y - points[0].y)*(points[i].y - points[0].y) + (points[i].z -points[0].z)*(points[i].z -points[0].z));
        

        // Handling division by zero
        if (dist == 0) {
            printf("Erreur : Distance nulle entre deux points (i = %d).\n", i);
            continue; // Move to the next point
        }

        // Calculation of the slope
        pente = alt/dist;
       
       // Using the absolute value of the slope
       double absolute_pente = fabs(pente);
        
        // Calculation and update of the wave height for each point
        points[i].z = waveheight(initial_wave_height, absolute_pente, dist_origine, distanceMaximale, tauxDeCroissance, sensibilitePente, facteurHauteur);
        
    }
    
    // Saving the calculated points to a file
    int result = save_points_to_file("wave_height_xy.txt", points, 4000000);
    if (result == 0) {
        printf("Points saved successfully.\n");
    } else {
        printf("Error saving points: %d\n", result);
    }
    
    // Releasing the allocated memory
    free(points);
    return 0;
}

//gcc -Wall wave.c -o wave -lm
//./wave


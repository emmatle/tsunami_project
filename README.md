# Computational Methods and Tools - Project : Tsunami modeling

## Project description 

This program models a coastal terrain with infrastructures located on it, as well as a wave (tsunami) that hits the terrain. It then categorizes the infrastructures into various categories (whether they are completely, partially, or not at all flooded).

The program will : 
1. Randomly model the coastal terrain and then output the model as a text file (CSV). (with the code name "*altitudes.py*" and the generated text file is named "*altitudes_région_cotière.csv*") 
2. Reads the previously created file ("*altitudes_région_cotière.csv*") and models a wave based on it ("*wave.c*") and finally outputs the wave model as a CSV text file ("*wave_heigth_xy*")
3. Retrieves the two text files ("*altitudes_région_cotière.csv*" and "*wave_height_xy*") to model infrastructures of different sizes on the terrain, then compares the terrain's altitudes with the wave's height, classifies the infrastructures into different categories, and outputs a 3D graph of this classification ("*comparaison.m*")

## Project structure 
je pense que cette partie correspond aux dossiers que l'on fera sur GitHup => donc à remplir après mais je vais faire une supposition
- "*Internal data*" contains files used for passing information between C, Python and Matlab. They are automatically edited by the program and should not be manually modified. 
- "*codes*" contains program code. 
- "*results*" contains saved .png files of graphs

### Inputs and Outputs 

Inputs: 
- There aren't any, since no external files are introduced.

Internal files: 
- "*Internal data/altitudes_région_cotière_100.csv*" is a csv file.
- "*Internal data/altitudes_région_cotière_50.csv*" is a csv file
- "*Internal data/wave_height_xy_alt100_5-10.txt*" is a text file.
- "*Internal data/wave_height_xy_alt100_5-10.tkt*"
- "*Internal data/wave_height_xy_alt100_10-30.tkt*"
- "*Internal data/wave_height_xy_alt100_30-40.tkt*"
- "*Internal data/wave_height_xy_alt100_40-70.tkt*"
- "*Internal data/wave_height_xy_alt50_10-30.tkt*"

Outputs:
- "*Results*" contains sevaral image files, (...) parce qu'on leur a toujours pas donner de nom 

**Overview :**
- Python generates and send values to C through a text file. 
- The simulation (of the wave) is handled by C. This will generate a new file.
- Python and C send values to Matlab through two text files (one each). It will directly output the results as graphs.
- Matlab also handles the outpu and visualisation.

**Structure**: In the directory "*Code/*" are located:
- "*altitude.py*"
    - Model a coastal terrain.
    - Writes all the values of our modeling in the form of a text file "*Internal data/altitudes_régions_cotières.csv*".
- "*code.c*"
    - Reads in the text file of the terrain located in "*Internal data/altitudes_régions_cotières.csv*".
    - Model the tsunami wave.
    - Exports results into the CSV "*Internal data/wave_height_xy*".
- "*comparaison.m*"
    - Reads in the CSV "*Internal data/altitudes_régions_cotières.csv*" and "*Internal data/wave_height_xy*"
    - Model the flooding of the terrain and infrastructures 
    - Plots results in a separate window 
    - You can find the results on "*Results*"




## Instructions 
To rerpoduce results in the report, steps should be followed :
1.1 Open the "*altitudes.py*" 
1.2 Navigate to the makefile to ensure the Python interpreter selected is yours.
1.3 Run the python code it should produce two csv files : 
    --> "*altitudes_région_cotière_100.csv*"  
    --> "*altitudes_région_cotière_50.csv*"

2.1 Open the "*wave.c*"
2.2 Navigate to the makefile to ensure the gcc version selected is yours.
2.3 You can run the file and type :
    ```
    gcc -Wall wave.c -o wave -lm
    ```
    ./wave
    ```
the code should return you 5 text files :
    --> "*wave_height_xy_alt100_5-10.tkt*"
    --> "*wave_height_xy_alt100_10-30.tkt*"
    --> "*wave_height_xy_alt100_30-40.tkt*"
    --> "*wave_height_xy_alt100_40-70.tkt*"


## Requirements 
Versions of Python and C used are as follows.
````
????



## Credits => pas besoin de crédits puisqu'on a utilisé aucun fichier extérieur ...

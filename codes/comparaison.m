%% want to create a matrix with infrastructures 

% Define matrix size
rows = 2000; % Number of rows
cols = 2000; % Number of columns

% Initialize the matrix with zeros
infrastructures_matrix = zeros(rows, cols);

% Define the number of infrsatructure to assign
n = 150;
% Ensure n is inferior to the number of elements of the matrix 
if n > rows * cols
   error('The number of points exceeds the total number of elements in the matrix.');
end

%we modelize in our matrix our infrastructure by vertical cylinder, height and radius chosen randomly ----------

% Define the range of infrastructure height that would be chosen randomly
a = 5; % Lower bound
b = 15; % Upper bound

% Define the radius range for the circular region of the cylinder 
radius_min = 3; % Minimum radius
radius_max = 9; % Maximum radius



%We want our infrastuctures to be placed randomly on our matrix 
% Generate n unique random indices
randIndices = randperm(rows * cols, n);
[randRows, randCols] = ind2sub([rows, cols], randIndices);

% Generate n random heights for infrastructures between a and b, as a row vector 
randomValues = a + (b - a) * rand(1, n);

%---------------------------------------------------------
%%Our final goal will be to do a classification of the infrastructures 
%Track the masks of the infrastructures created  
infrastructure_masks = cell(1, n);

%%to prevent overlap due to the random generation of index and radius
% Initialize logical matrix whith false value to track the masks of occupied regions 
occupied_mask = false(rows, cols);
%---------------------------------------------------------

%For cylindrical infrastructure with height associated to points within a circular region of radius selected  ------------------------------------
%Loop through each of the n selected index to which we will associate a cylinder infrastructure 
for i = 1:n

    %this assure that we dont go on the next i iteration before creating an infrastructures that do not overlap another 
    while true 
        % Generate a random radius within the defined range
        radius = radius_min + (radius_max - radius_min) * rand;
    
        % Get the center of the circle
        centerRow = randRows(i);
        centerCol = randCols(i);

% we delimitate a circle of radius generated aroound the random index selected 

        % Create a grid of coordinates
        [X, Y] = meshgrid(1:cols, 1:rows);
        % Compute the distance of each point from the center
        distances = sqrt((X - centerCol).^2 + (Y - centerRow).^2);

        % Find the indices within the circle stored in a logical mask that associate true for each indice 
        circleMask = distances <= radius;

        % The 'any' function checks if this circle overlaps with any existing infrastructure
        % if no overlap detected we accept this infrastructure
        if ~any(occupied_mask(circleMask))

            %we store its mask in the occupied_mask logical matrix using the logical or operator 
            occupied_mask = occupied_mask | circleMask;

        %------------------------------------------------------------
            % Store the mask for later classification
            infrastructure_masks{i} = circleMask;
        %------------------------------------------------------------

            % We Assign the random value to all indices within the circle 
            infrastructures_matrix(circleMask) = randomValues(i);
        
            %Exit the while loop to go to the creation of the next infrastructure 
            break;
        end
    end
end


%disp(infrastructures_matrix);

%------------------------------------------------------------------------------
%%On importe les altitudes et la vague generee

%ici je vais creer la matrice des altitudes a partir du fichier csv cree sur python 

%importer un fichier csv sur matlab 
altitudes_data = readmatrix('altitudes_région_cotière.csv', 'NumHeaderLines', 1);

% extract the value of each colum 
x = altitudes_data(:, 1); % Extract X values (1st column)
y = altitudes_data(:, 2); % Extract Y values (2nd column)
z = altitudes_data(:, 3); % Extract Z values (3rd column)

nb_elements_z = numel(z);
matrix_size = floor(sqrt(nb_elements_z));

if mod(matrix_size,1) == 0
    altitudes_matrix= reshape(z, [matrix_size, matrix_size]);
end


%maintenant je cree la matrice avec la hauteur de la vague a partir du fichier texte crée sur C 

% importer un fichier text sur matlab 
wave_height_data = readmatrix('wave_height_xy.txt');

% pourrait creer une fonction qui cree une matrice a partir dun fichier pour alléger lecriture du code 
zwave = wave_height_data(:, 3); % Extract Z values (3rd column)

nb_elements_zwave = numel(zwave);
matrix_size = floor(sqrt(nb_elements_zwave));

if mod(matrix_size,1) == 0
    wave_height_matrix= reshape(zwave, [matrix_size, matrix_size]);
end


% comparer les matrices 
difference_matrix = (infrastructures_matrix)-(wave_height_matrix);


%-----------------------------------------------------------------
%% faire le plot avec la cartte representant une variation daltitude 

%version 2D
%imagesc(1:2000, 1:2000, altitudes_matrix); % Specify x and y ranges
%colorbar; % We Add a color scale
%xlabel('X');
%ylabel('Y');
%title('2D Colormap of Altitudes');

%version 3D
% First Graph : Altitudes
figure(1)
[X, Y] = meshgrid(1:2000, 1:2000); % Create a grid for X and Y
surf(X, Y, altitudes_matrix, 'EdgeColor', 'none'); % Create a smooth surface
colorbar; % Add a color scale
xlabel('X');
ylabel('Y');
zlabel('Altitude');
title('3D Surface of Altitudes');

% Second Graph : Wave Height
figure(2)
[X, Y] = meshgrid(1:2000, 1:2000); % Create a grid for X and Y
surf(X, Y, wave_height_matrix, 'EdgeColor', 'none'); % Create a smooth surface
colorbar; % Add a color scale
xlabel('X');
ylabel('Y');
zlabel('Wave Height');
title('3D Surface of Wave Heights');
%--------------------------------------------------------------------


%% We create a classification for our infrastructures based on that comparison 
classification_matrix = zeros(size(difference_matrix));

%now we can use the vector infrastructure_masks to access the infracstructures 
for i = 1:n

    %extract the infrastructure i from the vector 
    % Extract the mask for the current infrastructure
    circleMask = infrastructure_masks{i};

    %values in the difference_matrix for the infrsatructure region 
    differences_in_region = difference_matrix(circleMask);
    
    % Get the associated infrastructure height
    infrastructure_height = randomValues(i);

    %as the infrastructures point are on a relief we have to consider the higher point and lower to compare 
    min_difference = min(differences_in_region);
    max_difference = max(differences_in_region);

    % Define a threshold to classify the infrastructure that are partially submerged and safe 
        seuil = infrastructure_height/10; 


    %apply the criteria for classification 

    % submerged more than 60 percent of its height : critical condition 
    if max_difference < (seuil*3) || min_difference < (seuil*3)
       classification_matrix(circleMask) = 1;

    % submerged between 30 percent and 60 percent of its height : recuperable but damaged 
    elseif (max_difference >= (seuil*3) || min_difference >= (seuil*3))&&(max_difference < (seuil*6) || min_difference < (seuil*6))
       classification_matrix(circleMask) = 2;

    % submerged less than 30 percent of its height : SAFE 
    else
       classification_matrix(circleMask) = 3;
    end
    
end

%---------------------------------------------------------------------
%%Overlay infrastructures classified on altitude in a 3D visualization


% Create a color map for the classified infrastructures
%this map use the R (red), G (green), B (blue) system to create colors 

infraColorMap = [1, 0, 0; % Red for 1 (critical dubmerssion)
                 1, 1, 0; % Yellow for 2 (partially submerged)
                 0, 1, 0]; % Green for 3 (slightly submerged)

% Grid generated for plotting
[X, Y] = meshgrid(1:cols, 1:rows); 

figure;

% Plot altitudes in grayscale
surf(X, Y, altitudes_matrix, 'EdgeColor', 'none');
colormap(flipud(gray));
%with high altitudes darker

%we use this to continue adding element on our plot that has now altitudes represented
hold on;

%% Overlay infrastructures as cylinders colored following their classification 

%initialize the points forming the circular base of each cylinder 
theta = linspace(0, 2*pi, 50); %function that generates 50 evenly spaced angles from 0 to 2π



for i = 1:n

    %%% We find once again the geometric propieties (position, radius, height) of our infrastructures using the mask 
    circleMask = infrastructure_masks{i};

    %%Find a point within the circular mask to approximate the center of the infrastructure we generated in our matrix 
    [centerRow, centerCol] = find(circleMask, 1); % function that returns its position 


    %%then we need to find the RADIUS associated to that center 
    %area of the base of the cylinder 
    area_base_cylinder = sum(circleMask(:));
    %using the definition of a circle area we find the radius 
    radius = sqrt(area_base_cylinder / pi); 

    %%then we get the Infrastructure HEIGHT
    height = randomValues(i); 



    %%%now we generate the 3D geometry of the cylinder for the plot 

    %% We calculate the 50 points cartesian coordinates forming the cylinder base 
    x_cylinder = radius * cos(theta) + centerCol;
    y_cylinder = radius * sin(theta) + centerRow;


    %% Create the vertical cylinder ptofile 
    
    %our cylinder are generated on top of our altitudes we need to find the heigh of the cylinder base 
    z_base = altitudes_matrix(centerRow, centerCol);

    %we use once again this function to generate 10 equally spaced points along a vertical dimension 
    z_cylinder = linspace(z_base, z_base + height, 10);
     
    % Create a 3D grid to generate the cylinder surface geometry
    %we combine the circular base 
    [X_cyl, Z_cyl] = meshgrid(x_cylinder, z_cylinder);
    %to its vertical profile 
    Y_cyl = repmat(y_cylinder, size(Z_cyl, 1), 1);
    Z_cyl = repmat(z_cylinder(:), 1, size(X_cyl, 2));



    %%% We associate the geometric cylinder generated to its color for classification 
    
    %%we focus on the center point of the cylinder to define its class 
    
    %we go find the number associated during classification stored in the classification matrix 
    color_idx = classification_matrix(centerRow, centerCol);
    
    %we find the associated color in the color map 
    cyl_color = infraColorMap(color_idx, :);

    %%if our classification does not encapsulate all the point there could be an error at this point of the code if the center did not have an class number 
    % Check that the color index is valid (1, 2, or 3)
    if any(color_idx == [1, 2, 3])
        % Plot the 3D cylinder with this function using its grid coordinates and  the color of its class
        surf(X_cyl, Y_cyl, Z_cyl, 'FaceColor', cyl_color, 'EdgeColor', 'none');
    else
        % Print a warning if the color index is not valid and we made a mistacke during the classification 
        disp(['Warning: Invalid classification index at (', num2str(centerRow), ',', num2str(centerCol), ')']);
    end
end


%% Enhance visualization 
%colorbar('Ticks', [1, 2, 3], 'TickLabels', {'Fully Submerged', 'Partially Submerged', 'Not Affected'});
%add a title 
title('3D Visualization of Altitudes and Infrastructure Classification');
%add names for the axis 
xlabel('X');
ylabel('Y');
zlabel('Altitude');

%% Add legend for classification colors
hold on;
%those are called dummy marker we make sure that they do not appear on the plot itself with the coordinates set to "NaN"
h1 = scatter3(NaN, NaN, NaN, 100, [1 0 0], 'filled'); % Red
h2 = scatter3(NaN, NaN, NaN, 100, [1 1 0], 'filled'); % Yellow
h3 = scatter3(NaN, NaN, NaN, 100, [0 1 0], 'filled'); % Green
%automatically placing the legend in the best position 
legend([h1, h2, h3], {'Fully Submerged', 'Partially Submerged', 'Not Affected'}, 'Location', 'best');

hold off;



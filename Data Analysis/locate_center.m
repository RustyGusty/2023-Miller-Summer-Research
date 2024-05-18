function center = locate_center(image)
    % Find the center of a diffraction pattern
    % Inputs:
    % image: 2D array of the diffraction pattern
    % Outputs:
    % center: 1x2 array of the center of the diffraction pattern

    % Find background color
    rounded_image = round(image, -1); % Round to the nearest 10 to reduce noise
    bg_color = mode(rounded_image(:)); % Find the most common color, set that as the background color
    
end

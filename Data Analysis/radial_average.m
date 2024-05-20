function data = radial_average(dirname, filename)
    % Load the data
    [img, header] = readSPE(dirname, filename);
    data = 0;
    for i = 1 : size(img, 3)
        figure;
        imagesc(img(:, :, i));
    end

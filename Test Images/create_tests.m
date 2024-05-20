function create_tests()
    background = uint16([1 1 1; 0 2 0; 0 0 3]);
    imwrite(background, 'background.tif');
    image = uint16([0 0 0; 0 1 0; 0 0 0]);
    imwrite(image + background, 'image.tif');
    imwrite(uint16(eye(3)), 'wrong_background.tif');
end
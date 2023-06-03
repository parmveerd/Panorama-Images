function pan = panorama (im2g, im1, im2, matchedPt1, matchedPt2)
    n=2;
    tforms(2) = projective2d(eye(3));
    tforms(n) = estimateGeometricTransform2D(matchedPt2, matchedPt1,... 
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 5000);
    tforms(n).T = tforms(n).T * tforms(n-1).T;

    ImageSize = zeros(2,2);
    ImageSize(2,:) = size(im2g);
  
    for i = 1:numel(tforms)
            [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 ImageSize(i,2)], [1 ImageSize(i,1)]);
    end
    
    avgXLim = mean(xlim, 2);
    
    [~, idx] = sort(avgXLim);
    
    centerIdx = floor((numel(tforms)+1)/2);
    
    centerImageIdx = idx(centerIdx);
    Tinv = invert(tforms(centerImageIdx));
    
    for i = 1:numel(tforms)
        tforms(i).T = tforms(i).T * Tinv.T;
    end
    
    for i = 1:numel(tforms)           
        [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 ImageSize(i,2)], [1 ImageSize(i,1)]);
    end
    
    maxImageSize = max(ImageSize);
   
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
   
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    
    pan = zeros([height width 3], 'like', im2);
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  
    
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
   
    i=1;
    I = im1;
    
    warpedImage = imwarp(I, tforms(1), 'OutputView', panoramaView);
    
    mask = imwarp(true(size(I,1),size(I,2)), tforms(1), 'OutputView', panoramaView);
    pan = step(blender, pan, warpedImage, mask);
    
    i=2;
    I = im2;
    
    warpedImage = imwarp(I, tforms(2), 'OutputView', panoramaView);
    
    mask = imwarp(true(size(I,1),size(I,2)), tforms(2), 'OutputView', panoramaView);
    pan = step(blender, pan, warpedImage, mask);
    
    imshow(pan);
end
function [matchedPt1, matchedPt2] = match (corners, corners2)
    [row,col] = find(corners);
    temp = [col,row];
    pts1 = ORBPoints(temp);
    [row,col] = find(corners2);
    temp = [col,row];
    pts2 = ORBPoints(temp);
    
    [features1, valid_pt1] = extractFeatures(corners, pts1);
    [features2, valid_pt2] = extractFeatures(corners2, pts2);
    indexPairs = matchFeatures(features1, features2);
    matchedPt1 = valid_pt1(indexPairs(:,1),:);
    matchedPt2 = valid_pt2(indexPairs(:,2),:);
    %%c = showMatchedFeatures(im1, im2, matchedPt1, matchedPt2);
end
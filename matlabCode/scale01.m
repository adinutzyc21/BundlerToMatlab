function pts=scale01(pts1)
    min1=pts1(1,3);
    max1=pts1(end,3);
    pts=(pts1-repmat(min1,length(pts1),3))./repmat(max1-min1,size(pts1,1),3);
end
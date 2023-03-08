function support = morphological_operation(img,se1,se2)

% poisson thresholding
t1_norm = imadjust(img);
t1_poi = poisson_tresh(t1_norm);
t2 = t1_norm>t1_poi;

% close-open
a0 = imdilate(t2,se1);
a1 = imerode(a0,se1);
a2 = imerode(a1,se2);
a3 = imdilate(a2,se2);

% open-close
b0 = imerode(t2,se1);
b1 = imdilate(b0,se1);
b2 = imdilate(b1,se2);
b3 = imerode(b2,se2);

% average and gaussian filtering
ave = 0.5.* a3 + 0.5.*b3 ;
[~,threshold] = edge(ave,'sobel');
ave = imgaussfilt(ave,0.5);
ave_bin = imbinarize(ave,threshold);

support=ave_bin;

end
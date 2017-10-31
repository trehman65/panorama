close all

numOfPoints = 4;
im1=imread('im1.jpg');
im2=imread('im2.jpg');

subplot(1,2,1)
imshow(im1);
[x1 y1] = ginput(numOfPoints)
subplot(1,2,2)
imshow(im2);
[x2 y2] = ginput(numOfPoints)


%points in homogeneous coordinates
im1Points = [x1 y1 repmat(1,numOfPoints,1)]';
im2Points = [x2 y2 repmat(1,numOfPoints,1)]';

close;

N = length(im1Points);
A = zeros(3*N,9);
 
 for n = 1:N
     X = im1Points(:,n)';
     x = im2Points(1,n);
     y = im2Points(2,n);
     w = im2Points(3,n);
     
     A(3*n-2,:) = [ zeros(1,3) -X y*X];
     A(3*n-1,:) = [ X zeros(1,3) -x*X];
     A(3*n ,:) = [-y*X x*X zeros(1,3) ];
 
 end
 
[U,S,V] = svd(A,0);

H = reshape(V(:,9),3,3)';

p=H*X';

p=p/p(end)

[h w c] = size(im2);

oldcornerPts=[ 1 1 w w ; 1 h 1 h ; 1 1 1 1 ];
%in order to generate a grid for the warped image we need to apply
%the transform to the corner points
cornerPts = H\oldcornerPts;
cornerPts = cornerPts./repmat(cornerPts(3,:),3,1)



%since the minimum distance that we have is 1 pixel, find the minimum
%and the maximum points for both axes and fit a grid with 1 pixel intervals
[X_grid,Y_grid] = ndgrid( min( cornerPts(1,:) ) : 1 : max( cornerPts(1,:) ),...
 min( cornerPts(2,:) ) : 1 : max( cornerPts(2,:) )); 
[numRow numCol] = size(X_grid);

% inverse mapping im2points = H * im1points
im2points = H * [ X_grid(:) Y_grid(:) ones(numRow*numCol,1) ]';
im2points = im2points./repmat(im2points(3,:),3,1); %normalize homogeneous coordinates

xI = reshape( im2points(1,:),numRow,numCol)';
yI = reshape( im2points(2,:),numRow,numCol)';


im2= im2double(im2);
imWarped = zeros(numCol,numRow,3);

%interpolate the point values for each color channel
imWarped(:,:,1) = interp2(im2(:,:,1), xI, yI);
imWarped(:,:,2) = interp2(im2(:,:,2), xI, yI);
imWarped(:,:,3) = interp2(im2(:,:,3), xI, yI);


%assign minimum corners as the offset of the image
cornerPts = round(cornerPts)
offset = [ min( cornerPts(1,:)) min( cornerPts(2,:) ) ];


imWarped=double(round(255*imWarped));
imshow(imWarped)



[h1 w1 c1] = size(im1);
cornerPts1=[ 1 1 w1 w1 ; 1 h1 1 h1 ; 1 1 1 1 ];

min1 = min( min(cornerPts1(1,:)), min(cornerPts(1,:)) );
max1 = max( max(cornerPts1(1,:)), max(cornerPts(1,:)) );

min2 = min( min(cornerPts1(2,:)), min(cornerPts(2,:)) );
max2 = max( max(cornerPts1(2,:)), max(cornerPts(2,:)) );


R=zeros(max2-min2,max1-min1,3,class(im1));


[h w c]=size(imWarped);


for i =1:h1
    for j =1:w1

        R(i-min2+1,j-min1+1,:) = im1(i, j,:);
    end
end

for i =1:h
    for j =1:w
     
        if isnan(imWarped(i,j))
         else
            R(i-min2+offset(2)+1,j-min1+1+offset(1),:) = imWarped(i,j,:);
         end
     
    end
end

 
figure 
imshow(R)














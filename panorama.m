function []=panorama(pathToView1, pathToView2,numberOfPoints)


clc
close all

view1=imread(pathToView1);
view2=imread(pathToView2);



subplot(1,2,1)
imshow(view1);
[x1 y1] = ginput(numberOfPoints)

subplot(1,2,2)
imshow(view2);
[x2 y2] = ginput(numberOfPoints)

view1Points = [x1 y1 repmat(1,numberOfPoints,1)]';
view2Points = [x2 y2 repmat(1,numberOfPoints,1)]';

close;


N = length(view1Points);
A = zeros(3*N,9);
 
 for i = 1:N
     
     X = view1Points(:,i)';
     x = view2Points(1,i);
     y = view2Points(2,i);
     
     A(3*i-2,:) = [ zeros(1,3) -X y*X];
     A(3*i-1,:) = [ X zeros(1,3) -x*X];
     A(3*i ,:) = [-y*X x*X zeros(1,3) ];
 
 end
 
[U,S,V] = svd(A,0);

H = reshape(V(:,9),3,3)';

%testing H
% p=H*X';
% 
% p=p/p(end)


[h w c] = size(view2);

view2corners=[ 1 1 w w ; 1 h 1 h ; 1 1 1 1 ];
view2cornersInView1 = H\view2corners;
view2cornersInView1 = view2cornersInView1./repmat(view2cornersInView1(3,:),3,1)

minX=min( view2cornersInView1(1,:) );
minY=min( view2cornersInView1(2,:) );
maxX=max( view2cornersInView1(1,:) );
maxY=max( view2cornersInView1(2,:) );

[X_grid,Y_grid] = ndgrid( minX : 1 : maxX, minY : 1 : maxY); 

[numRow numCol] = size(X_grid);


im2points = H * [ X_grid(:) Y_grid(:) ones(numRow*numCol,1) ]';
im2points = im2points./repmat(im2points(3,:),3,1); %normalize homogeneous coordinates

xI = reshape( im2points(1,:),numRow,numCol)';
yI = reshape( im2points(2,:),numRow,numCol)';


view2= im2double(view2);
imWarped = zeros(numCol,numRow,3);

%interpolate the point values for each color channel
imWarped(:,:,1) = interp2(view2(:,:,1), xI, yI);
imWarped(:,:,2) = interp2(view2(:,:,2), xI, yI);
imWarped(:,:,3) = interp2(view2(:,:,3), xI, yI);


%assign minimum corners as the offset of the image
view2cornersInView1 = round(view2cornersInView1)
offset = [ min( view2cornersInView1(1,:)) min( view2cornersInView1(2,:) ) ];

imshow(imWarped)
imWarped=double(round(255*imWarped));




[h1 w1 c1] = size(view1);
cornerPts1=[ 1 1 w1 w1 ; 1 h1 1 h1 ; 1 1 1 1 ];

min1 = min( min(cornerPts1(1,:)), min(view2cornersInView1(1,:)) );
max1 = max( max(cornerPts1(1,:)), max(view2cornersInView1(1,:)) );

min2 = min( min(cornerPts1(2,:)), min(view2cornersInView1(2,:)) );
max2 = max( max(cornerPts1(2,:)), max(view2cornersInView1(2,:)) );


R=zeros(max2-min2,max1-min1,3,class(view1));


[h w c]=size(imWarped);


for i =1:h
    for j =1:w
     
        if isnan(imWarped(i,j))
         else
            R(i-min2+offset(2)+1,j-min1+1+offset(1),:) = imWarped(i,j,:);
         end
     
    end
end

for i =1:h1
    for j =1:w1

        R(i-min2+1,j-min1+1,:) = view1(i, j,:);
    end
end

 
figure 
imshow(R)


end








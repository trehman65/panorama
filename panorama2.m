
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
im1Points = [x1 y1 repmat(1,numOfPoints,1)]'
im2Points = [x2 y2 repmat(1,numOfPoints,1)]'

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

H=H/H(end);





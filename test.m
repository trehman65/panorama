

close all
image1=imread('im1.jpg');

[h w c]=size(image1);

imageCopy=zeros(h,w,3,'uint8');


for i=1:h
    for j=1:w
        for k=1:3
            imageCopy(i,j,k)=image1(i,j,k);
        end
    end
end

imshow(rgb2gray(imageCopy))
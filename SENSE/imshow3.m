function imshow3(img,range,shape)
% imshow3(img, [ range, [shape )
%
% function to display series of images as a montage.
% 
% img - a 3D array representing a series of images
% range - window level (similarly to imshow
% shape - a 2x1 vector representing the shape of the motage
%
% Example: 
% 		im = repmat(phantom(128),[1,1,6]);
%		figure;
%		imshow3(im,[],[2,3]);
%
% (c) Michael Lustig 2012

%%
if ~isreal(img)
tmp=abs(img);
else
tmp=(img);    
end
clear img
img=reshape(tmp,size(tmp,1),size(tmp,2),[]);
[im_x, im_y ,im_z]=size(img);
if nargin<3 || isempty(shape)
shape(2)=ceil(sqrt(im_z));
shape(1)=ceil(im_z/shape(2));
end
if shape(1)*shape(2)>im_z
   img(:,:,im_z+1:shape(1)*shape(2)) =zeros(im_x ,im_y,shape(1)*shape(2)-im_z);
end
% implay(img./max(img(:)))
%%
img = img(:,:,:);
[sx,sy,nc] = size(img);

if nargin < 2 
	range = [min(img(:)), max(img(:))];
end

if isempty(range)==1
	range = [min(img(:)), max(img(:))];
end


	img = reshape(img,sx,sy*nc);
	img = permute(img,[2,3,1]);
	img = reshape(img,sy*shape(2),shape(1),sx);
	img = permute(img,[3,2,1]);
	img = reshape(img,sx*shape(1),sy*shape(2));


%imagesc(img,range); colormap(gray(256));axis('equal');

figure,imshow(img,range);

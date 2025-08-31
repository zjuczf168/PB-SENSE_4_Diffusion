function [img_recon] = recon_Sense(kspace,sens_map)


[N(1), N(2), N(3), num_chan]= size(sens_map);  % x*y*z*coil


img_recon = zeros(N) ;


lsqr_iter = 100;
lsqr_tol = 1e-3;
mask = zeros(N(1),N(2),N(3), num_chan);
mask=squeeze((abs(kspace)))>0;
% mask(:,ky_idx,1,:) =1;
% kspace = kspace.*mask;

% 
param = [];
param.N = N ;
param.num_chan = num_chan;
param.lambda = 1e-3;
param.sens = sens_map;
param.m3d = kspace~=0;
param.fft_scale = 1/sqrt(prod(N));
% tflag = 'transp';
% in = cat(1, kspace(:), zeross([prod(N),1]));
% 
tic
% res = lsqr(@apply_sense3D, cat(1, kspace(:), zeross([prod(N),1])), lsqr_tol, lsqr_iter, [], [], [], param);
res = lsqr(@apply_sense2D, cat(1, kspace(:), zeross([prod(N),1])), lsqr_tol, lsqr_iter, [], [], [], param);
% res = lsqr(@apply_sense3D, kspace(:), lsqr_tol, lsqr_iter, [], [], [], param);
toc

img_recon = reshape(res, N);



end
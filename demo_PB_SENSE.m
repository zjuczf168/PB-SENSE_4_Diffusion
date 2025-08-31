clear
load DTI_1b0_16b800_5sh.mat

[nFE, nPE,  nCoil, nDir] = size(b1ksp);

nSH = 5;% the number of shots
Rs  = 1;% SENSE factor
R   = Rs*nSH;% acceleration factor of each shot
Kdata_msh = zeros(nPE/nSH, nFE, nCoil, nSH, nDir);

for sh = 1:nSH
    Kdata_msh(:,:,:,sh,:) = permute(squeeze(b1ksp(:,(sh-1)*Rs+1:nSH*Rs:end,:,:)),[2 1 3  4 5]);

end

%% SENSE RECON
k0_sample = zeros(nPE, nFE,nCoil, nDir);
k0_sample(1:R:end,:,:,:) = squeeze(Kdata_msh(:,:,:,1,:));   % undersampled data 
[img_recon] = recon_Sense(permute(k0_sample,[1 2 4 3]),permute(repmat(sensemap,[1 1 1 size(k0_sample,4)]),[2 1 4 3]));

%--------------------------------------------------------------------------
%% BM4D-SENSE based on POCS
smap = repmat(permute(sensemap,[2 1 3]),[1 1 1 size(img_recon,3)]);% size: nPE, nFE, nCoil, nDir
I11 = img_recon; % initial value
mask = zeros(nPE, nFE,nCoil, nDir);
mask(k0_sample~=0) = 1; % sampling mask

cont = 1;
for kp = 1:40 
    I_temp = I11;
% normalization
    min_r = 1*min(real(I11(:)));
    I11_r = real(I11) - min_r;
    scl_r = max(I11_r(:));
    I11_r = I11_r /scl_r;

    min_i = 1*min(imag(I11(:)));
    I11_i = imag(I11) - min_i;
    scl_i = max(I11_i(:));
    I11_i = I11_i /scl_i;

    min_abs = 1*min(abs(I11(:)));
    I11_abs = abs(I11) - min_abs;
    scl_abs = max(I11_abs(:));
    I11_abs = I11_abs /scl_abs;            

% real and imaginary-based denoising for phase
    [I11_r_de] = bm4d(I11_r,'Gauss',0,'mp');%   BM4D denoising  
    [I11_i_de] = bm4d(I11_i,'Gauss',0,'mp');%   BM4D denoising  
             
% magnitude-based denosing
    [I11_abs_de] = bm4d((I11_abs),'Rice',0,'mp');
    
    I11_r_de(isnan(I11_r_de)) = 0;            
    I11_i_de(isnan(I11_i_de)) = 0; 
    I11_abs_de(isnan(I11_abs_de)) = 0;

    I11_de = double(I11_r_de/1 * scl_r + min_r + 1i * (I11_i_de/1 * scl_i +  min_i));% for image phase
    I11_de = (I11_abs_de/1* scl_abs+ min_abs).*I11_de./(abs(I11_de)+eps);  
    
%   pocs-sense
    imtemp = permute(repmat(I11_de,[1 1 1 nCoil]),[1 2 4 3]);
    ktemp = fft2c(smap.*imtemp);
    ktemp = ktemp.*(1-mask) + k0_sample;

    I11 = squeeze(sum(ifft2c(ktemp).*conj(smap),3));
    cont = cont + 1; 

    if norm(abs(I11(:))-abs(I_temp(:)))/norm(abs(I_temp(:)))<0.002
      break; 
     
    end
            
end





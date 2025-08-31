function res = ifftc(x,dim)
% res = fftc(x,dim)
if nargin < 2
    dim = 2;
end

res = 1/sqrt(size(x,dim))*fftshift(ifft(ifftshift(x,dim),[],dim),dim);



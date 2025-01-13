function [Yest, results] = local_background2(Y, ssub, rr, ACTIVE_PX, sn, thresh, p_cutoff)
%% approximate the background with locally-linear embedding
%% inputs:
%   Y: d1*d2*T 3D matrix, video data
%   rr: scalar, average neuron size
%   ssub: spatial downsampling factor
%   ACTIVE_PX:  indicators of pixels to be approximated
%   sn:  noise level for each pixel
%   thresh: threshold for selecting frames with resting states
%   p_cutoff: pick neighbors whose corr. coefficients with the center pixel
%   are smaller than quantiles of p_cutoff.
%% outputs:
%   Yest: d1*d2*T 3D matrix, reconstructed video data
%   results: struct variable {weights, ssub}
%       weights: d1*d2 cell, each element is a 2*J matrix. Row 1 has the indice of the
%       ring neighbors and row 2 has the corresponding weights.
%       ssub:    scalar, spatial downsampling factor

%% Author: Pengcheng Zhou, Carnegie Mellon University,2016

%% input arguments
[d1, d2, T] = size(Y);

% center the fluorescence intensity by its mean
Ymean = mean(Y, 3);
Y = Y - Ymean+1;

% average neuron size
if ~exist('rr', 'var')|| isempty(rr)
    rr = 15;
end
% spatial downsampling
if ~exist('ssub', 'var') || isempty(ssub)
    ssub = 1;
end

%downsample the data
if ssub>1
    Y = imresize(Y, 1./ssub);
    [d1s, d2s, ~] = size(Y);
    rr = round(rr/ssub)+1;

    if ~exist('sn', 'var')||isempty(sn)
        sn = reshape(get_noise_fft(reshape(Y, d1s*d2s, [])), d1s, d2s);
    else
        sn = imresize(sn, 1./ssub);
    end
else
    d1s = d1;
    d2s = d2;
    if ~exist('sn', 'var')||isempty(sn)
        sn = reshape(get_noise_fft(reshape(Y, d1s*d2s, [])), d1s, d2s);
    end
end

% threshold for selecting frames with resting state
if ~exist('thresh', 'var') || isempty(thresh)
    thresh = 3;
end

if ~exist('p_cutoff', 'var') || isempty(p_cutoff)
    p_cutoff = 1;
end

%% threshold the data
csub = (-rr):(rr);      % row subscript
rsub = csub.';      % column subscript
R = sqrt(rsub.^2+csub.^2);
neigh_kernel = (R>=rr) & (R<rr+1);  % kernel representing the selected neighbors
Yconv = imfilter(Y, neigh_kernel)./imfilter(ones(d1s, d2s), neigh_kernel);
ind_event = (Y-Yconv./sn)> thresh; % frames with larger signal
Y(ind_event) = Yconv(ind_event); % remove potential calcium transients

% pixels to be approximated
if exist('ACTIVE_PX', 'var') && ~isempty(ACTIVE_PX)
    ACTIVE_PX = reshape(double(ACTIVE_PX), d1, d2);
    ACTIVE_PX = (imresize(ACTIVE_PX, 1/ssub)>0);
else
    ACTIVE_PX = true(d1s,d2s);
end

%% determine neibours of each pixel
[r_shift, c_shift] = find(neigh_kernel);
r_shift = r_shift - rr -1;
c_shift = c_shift - rr - 1;

csub = 1:d2s+ permute(c_shift,[2,3,1]);
rsub = (1:d1s).'+ permute(r_shift,[2,3,1]);
% remove neighbors that are out of boundary
csub(csub<1|csub>d2s)=NaN;
rsub(rsub<1|rsub>d2s)=NaN;

%% run approximation
warning('off','MATLAB:nearlySingularMatrix');
warning('off','MATLAB:SingularMatrix');
% gamma = 0.001; % add regularization
Y = reshape(Y, d1s*d2s, []);
Yest = zeros(size(Y));
weights = cell(d1s, d2s);

for m=1:length(ACTIVE_PX)
    px = ACTIVE_PX(m);
    ind_nhood = sub2ind([d1s,d2s], rmmissing(rsub(px, :)), rmmissing(csub(px, :)));
    % ind_nhood(isnan(ind_nhood)) = [];
    %     J = length(ind_nhood);

    tmp_ind = ~ind_event(px, 2:end);
    X = Y(ind_nhood, tmp_ind);
    y = Y(px, tmp_ind);
    tmpXX = X*X';
    tmpXy = X*y';
    if p_cutoff<1
        temp = tmpXy./diag(tmpXX);
        idx = (temp < quantile(temp, p_cutoff));
        tmpXX = tmpXX(idx, idx);
        tmpXy = tmpXy(idx);
        ind_nhood = ind_nhood(idx);
    end
    w = (tmpXX+eye(size(tmpXX))*sum(diag(tmpXX))*(1e-5)) \ tmpXy;
    Yest(px, :) = w'*Y(ind_nhood, :);
    weights{px} = [ind_nhood; w'];
end
results.weights = weights;
results.ssub = ssub;
results.dims = [d1s, d2s];

ind = 1:(d1s*d2s);
ind(ACTIVE_PX) = [];
if ~isempty(ind)
    temp = imfilter(Y, ones(3, 3)/9, 'replicate');
    Yest(ind, :) = temp(ind, :); % without approximation
end
Yest = reshape(Yest, d1s, d2s, []);
warning('on','MATLAB:nearlySingularMatrix');
warning('on','MATLAB:SingularMatrix');
%% return the result
if ssub>1 %up sampling
    Yest = imresize(Yest, [d1, d2]);
end
%
% clear Y;
Ybaseline = Ymean-mean(Yest,3); % medfilt2(Ymean, [3,3]); % - median(Yest, 3);
Yest = bsxfun(@plus, Yest, Ybaseline);
results.b0 = Ybaseline;

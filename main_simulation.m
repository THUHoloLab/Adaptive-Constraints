% ========================================================================
% Introduction
% ========================================================================
% This code provides a simple demonstration of using adaptive
% constraints generated by morphological operations to reconstruct the
% complex-valued object
% ========================================================================
% The code is written by Danlin Xu, 2022
% The version of Matlab for this code is R2021a
% ========================================================================
%%
% =========================================================================
% Data generation
% =========================================================================

clear;clc
close all

% load test image
load('amplitude_cell.mat','amplitude');
load('phase_THU.mat','phase');
object = amplitude.*exp(1i.*phase);

% physical parameters
wavelength = 500e-9; %m
pixel_size = 5.86e-6; %m
z = 0.060;% recording distance m 
[m,n] = size(object);
nullpixels = 250;%padding value

% propagation
prop = Propagator(wavelength,pixel_size,m,n,z);

% in-line hologram
U_in = ifft2(ifftshift(fftshift(fft2(object)).*prop));
Hologram_in = abs(U_in).^2;%%同轴全息图的强度

% back propagation 
Hologram_in_back = ifft2(ifftshift(fftshift(fft2(sqrt(Hologram_in))).*conj(prop)));
amplitude_in = abs(Hologram_in_back);   
phase_in = angle(Hologram_in_back);
amplitude_in = amplitude_in(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
phase_in = phase_in(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
figure(1),subplot('position',[0 0 1 1]),imshow(amplitude_in,[]);
figure(2),subplot('position',[0 0 1 1]),imshow(phase_in,[]);

%%
% =========================================================================
% Iteration process
% =========================================================================

Iterations = 300;
r0 = object(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
sensor_plane2 = zeros(m,n);

% initialization
measured = sqrt(Hologram_in);
phase_h1 = zeros(m,n);

% structual elements
SE1 = strel('disk',1); 
SE2 = strel('square',2);

% evolutions of adaptive constraints
figure
for tt = 1:Iterations
    
    fprintf('Iteration: %d\n', tt)
    
    
    sensor_plane1 = measured.* exp(1i.*phase_h1);
    
    % backward propagation
    object_plane1 = ifft2(ifftshift(fftshift(fft2(sensor_plane1)).*conj(prop))); %% object plane  
    amplitude_o1 = abs(object_plane1); 
    phase_o1 = angle(object_plane1);
    
    % update the object plane
    o1 = 1-amplitude_o1;
    S1 = morphological_operation(o1,SE1,SE2);
    amplitude_updated = 1-o1.*S1;
    
    S2 = morphological_operation(phase_o1,SE1,SE2); 
    phase_updated = phase_o1.*S2;    
    subplot(1,2,1),imshow(S1,[]); subplot(1,2,2),imshow(S2,[]); 
    
    object_plane2 = amplitude_updated.*exp(1i.*phase_updated); %%update the object field
    
    if tt == Iterations
        k1 = object_plane2;
    end
    
    % foreward propagation
    sensor_plane2 = ifft2(ifftshift(fftshift(fft2(object_plane2)).*prop));
    amplitude_h1 = abs(sensor_plane2);
    phase_h1 = angle(sensor_plane2); 
   
    % calculate MSE
    r = object_plane2(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
    MSE_amp(tt) = (sum(sum((abs(r)-abs(r0)).^2)))./(sum(sum((abs(r0)-1).^2)));
    MSE_pha(tt) = (sum(sum((angle(r)-angle(r0)).^2)))./(sum(sum((angle(r0)).^2)));
end

%%
% =========================================================================
% Display results
% =========================================================================

recons = k1;
rec_amp = abs(recons); 
rec_pha = angle(recons);

% crop image
crop_amp = rec_amp(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
crop_pha = rec_pha(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
crop_constraint1 = S1(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);
crop_constraint2 = S2(nullpixels+1:m-nullpixels,nullpixels+1:n-nullpixels);

% visualize the reconstructed image
figure(3),subplot('position',[0 0 1 1]),imshow(crop_amp,[]);
figure(4),subplot('position',[0 0 1 1]),imshow(crop_pha,[]);

% visualize adaptive constraints
figure(5),subplot('position',[0 0 1 1]),imshow(crop_constraint1,[]);hold on; visboundaries(crop_constraint1);
figure(6),subplot('position',[0 0 1 1]),imshow(crop_constraint2,[]);hold on; visboundaries(crop_constraint2);

% visualize the MSE curves
tt = linspace(1,Iterations,Iterations);
figure(7),plot(tt,(MSE_amp),'r','Linewidth',3);set(gca,'FontName','Arial','FontSize',26);title('Amplitude');
figure(8),plot(tt,(MSE_pha),'r','Linewidth',3);set(gca,'FontName','Arial','FontSize',26);title('Phase');

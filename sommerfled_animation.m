%==========================================================================
% ANIMATION OF INCIDENT PLANE WAVE PACKET APPROACHING A HALF-PLANE
%==========================================================================
close all; clear; clc;

%--- 1. Set Up Grid and Physics Parameters ---
N = 400;                     % Grid resolution (higher is slower animation)
x_vec = linspace(-10, 10, N);
y_vec = linspace(-12, 12, N); % Y goes from negative to positive
[X, Y] = meshgrid(x_vec, y_vec);

k = 2 * pi;                  % Wavenumber (lambda = 1)
omega = 2 * pi;              % Angular frequency (for time propagation)
c = omega / k;               % Wave speed (c = 1 in this normalization)
sigma_y = 1.5;               % Standard deviation (length) of the packet
sigma_x = 4.0;               % Width of the packet

% Polar coordinates for the diffraction term (relative to the edge at 0,0)
[phi, r] = cart2pol(X, Y);
theta = pi/2;                % Normal incidence (traveling up)

% u represents the distance parameter for the exact Sommerfeld solution
u = sqrt(2 * k * r) .* cos((phi - theta) / 2);

%==========================================================================
%--- 2. Optimization: Pre-calculate the Steady-State Geometry ---
% We use a customized complex erfc approximation for speed and compatibility.
%==========================================================================
F_u = complex_erfc_vectorized(exp(-1i*pi/4) * u);
SteadyStateGeometry = 0.5 * exp(-1i * k * Y) .* F_u;

% Force the incident wave to be undisturbed for Y < 0 (before the plane)
SteadyStateGeometry(Y < 0) = exp(-1i * k * Y(Y < 0));

%==========================================================================
%--- 3. Animation Setup ---
%==========================================================================
T_max = 24;                  % Maximum time
dt = 0.1;                    % Time step
t_steps = 0:dt:T_max;

figure('Name', 'Sommerfeld Problem: Wave Packet Animation', ...
       'Color', 'w', 'Units', 'Normalized', 'Position', [0.1 0.1 0.8 0.8]);
   
ax = axes('Parent',gcf);
hold on;
axis equal tight;
grid on;
title('Animation of a Plane Wave Packet Approaching a Half-Plane');
xlabel('x'); ylabel('y (Direction of Propagation)');
zlabel('Field Amplitude');
view(0, 90); % Start with top-down view
colormap('parula'); % Excellent for visualization
colorbar;

% Initializing the dynamic graphic handle
% Using real part of the field to show wave crests
h_plot = surf(ax, X, Y, real(SteadyStateGeometry), 'EdgeColor', 'none'); 

% Add the Half-Plane barrier as a black line at y=0
plot3(ax, [-10 0], [0 0], [5 5], 'k', 'LineWidth', 5);

% Limit the Z-axis for consistent scaling
zlim([-1.5 1.5]);
% Set fixed color limits: [min max]
% Since the wave amplitude is normalized to 1, -1 to 1 is ideal.
clim(ax, [-1, 1]);
%==========================================================================
%--- 4. Animation Loop ---
%==========================================================================
for t = t_steps
    % 1. Shift the envelope in time
    y_center = -10 + (c * t); 
    
    % 2. Define the spatial envelope (Gaussian packet)
    % This makes the plane wave finite in length (Y) and width (X)
    envelope = exp(-( (Y - y_center).^2 / (2 * sigma_y^2) )) .* ...
               exp(-( X.^2 / (2 * sigma_x^2) ));
    
    % 3. Calculate the dynamic field:
    % (Steady State Geometry) * (Moving Envelope) * (Time Carrier)
    dynamic_field = SteadyStateGeometry .* envelope .* exp(-1i * omega * t);
    
    % 4. Update the graphic object
    set(h_plot, 'ZData', real(dynamic_field));
    
    % (Optional) Update title with time
    title(sprintf('Wave Packet Time: %.1f', t));
    
    drawnow; % Refresh graphics immediately
end

%==========================================================================
%--- Custom Sub-Function: Vectorized Complex ERFC ---
% Replaces built-in to handle toolbox errors and speed up animation.
%==========================================================================
function w = complex_erfc_vectorized(z)
    t = 1 ./ (1 + 0.5 * abs(z));
    % Abramowitz and Stegun (7.1.26) high-precision approximation
    w = t .* exp(-z.^2 -1.26551223 + t.*(1.00002368 + t.*(0.37409196 + ...
          t.*(0.09678418 + t.*(-0.18628806 + t.*(0.27886807 + ...
          t.*(-1.13520398 + t.*(1.48851587 + t.*(-0.82215223 + ...
          t.*0.17087277)))))))));
    
    % Continuity correction for the left half-plane
    idx = real(z) < 0;
    if any(idx(:))
        w(idx) = 2 - w(idx);
    end
end
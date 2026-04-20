function plotUrbanSignalHeatmap(tx_pos, tx_power_dbm, freq_hz, resolution)
    % plotUrbanSignalHeatmap - Generates a 2D map of signal loss dynamically
    
    x_vec = 0.1 : resolution : 19.9;
    y_vec = 0.1 : resolution : 19.9;
    
    [X, Y] = meshgrid(x_vec, y_vec);
    signal_map = NaN(size(X)); 
    
    wb = waitbar(0, 'Ray-tracing urban grid... Please wait.');
    total_rows = size(X, 1);
    
    for row = 1:total_rows
        for col = 1:size(X, 2)
            rx_x = X(row, col);
            rx_y = Y(row, col);
            
            % Skip if inside a building
            if mod(floor(rx_x), 2) == 0 && mod(floor(rx_y), 2) == 0
                continue; 
            end
            
            % Pass dynamic variables to the loss estimator
            [rx_signal, ~] = estimateUrbanSignalLoss(tx_pos, [rx_x, rx_y], tx_power_dbm, freq_hz);
            signal_map(row, col) = rx_signal;
        end
        waitbar(row / total_rows, wb);
    end
    close(wb);
    
    % --- PLOTTING ---
    figure('Name', 'Urban Diffraction Heatmap', 'Position', [100, 100, 800, 700]);
    levels = linspace(-120, -40, 50); 
    contourf(X, Y, signal_map, levels, 'LineColor', 'none');
    
    colormap('turbo'); 
    c = colorbar;
    c.Label.String = 'Received Signal Strength (dBm)';
    clim([-120, -40]); 
    
    hold on;
    % Overlay buildings
    for x_start = 0:2:18
        for y_start = 0:2:18
            rectangle('Position', [x_start, y_start, 1, 1], ...
                      'FaceColor', [0.1 0.1 0.1], 'EdgeColor', 'w', 'LineWidth', 1);
        end
    end
    
    % Dynamically plot the Cell Tower based on input
    plot(tx_pos(1), tx_pos(2), 'r^', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    text(tx_pos(1), tx_pos(2) - 0.5, 'TX', 'Color', 'r', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    
    axis equal; xlim([0 20]); ylim([0 20]);
    xlabel('Grid X (10 m increments)'); ylabel('Grid Y (10 m increments)');
    title(sprintf('Theoretical Urban Propagation (%.1f GHz)', freq_hz/1e9));
    grid on; hold off;
end
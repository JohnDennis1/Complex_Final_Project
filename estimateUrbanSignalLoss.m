function [rx_signal_dbm, path_loss_db] = estimateUrbanSignalLoss(tx_pos, rx_pos, tx_power_dbm, freq_hz)
    % estimateUrbanSignalLoss - Centerline-Locked Waveguide Model
    
    grid_scale = 10; % 1 unit = 10 meters
    c = 3e8; 
    
    tx_x = tx_pos(1); tx_y = tx_pos(2);
    rx_x = rx_pos(1); rx_y = rx_pos(2);

    % Map TX and RX to the EXACT centerline of their respective streets
    % (e.g., 1.8 becomes 1.5, 3.1 becomes 3.5)
    ctx_x = floor(tx_x/2)*2 + 1.5;
    ctx_y = floor(tx_y/2)*2 + 1.5;
    crx_x = floor(rx_x/2)*2 + 1.5;
    crx_y = floor(rx_y/2)*2 + 1.5;

    is_tx_vert = mod(floor(tx_x), 2) ~= 0;
    is_tx_horz = mod(floor(tx_y), 2) ~= 0;
    is_rx_vert = mod(floor(rx_x), 2) ~= 0;
    is_rx_horz = mod(floor(rx_y), 2) ~= 0;

    min_path_loss = inf; 

    % ==========================================
    % ROUTE 0: Pure Line of Sight
    % ==========================================
    if (is_tx_vert && is_rx_vert && floor(tx_x) == floor(rx_x)) || ...
       (is_tx_horz && is_rx_horz && floor(tx_y) == floor(rx_y))
        
        dist_m = max(0.1, norm(rx_pos - tx_pos) * grid_scale);
        loss = 20*log10(dist_m) + 20*log10(freq_hz) + 20*log10(4*pi/c);
        min_path_loss = min(min_path_loss, loss);
    end

    % ==========================================
    % ROUTE 1: One Turn (Waveguiding)
    % ==========================================
    % Path A: Vert then Horz
    if is_tx_vert && is_rx_horz
        ix = [ctx_x, crx_y]; % Locked perfectly to intersection center
        d1_m = norm(ix - tx_pos) * grid_scale;
        d2_m = norm(rx_pos - ix) * grid_scale;
        
        fspl = 20*log10(max(0.1, d1_m + d2_m)) + 20*log10(freq_hz) + 20*log10(4*pi/c);
        penalty = 10 + 10*log10((d2_m/10) + 1); % Smooth logarithmic fading
        min_path_loss = min(min_path_loss, fspl + penalty);
    end

    % Path B: Horz then Vert
    if is_tx_horz && is_rx_vert
        ix = [crx_x, ctx_y];
        d1_m = norm(ix - tx_pos) * grid_scale;
        d2_m = norm(rx_pos - ix) * grid_scale;
        
        fspl = 20*log10(max(0.1, d1_m + d2_m)) + 20*log10(freq_hz) + 20*log10(4*pi/c);
        penalty = 10 + 10*log10((d2_m/10) + 1);
        min_path_loss = min(min_path_loss, fspl + penalty);
    end

    % ==========================================
    % ROUTE 2: Two Turns (Deep Shadow)
    % ==========================================
    if is_tx_vert && is_rx_vert
        for y_cross = 1.5 : 2 : 19.5
            ix1 = [ctx_x, y_cross];
            ix2 = [crx_x, y_cross];
            
            d1_m = norm(ix1 - tx_pos) * grid_scale;
            d2_m = norm(ix2 - ix1) * grid_scale;
            d3_m = norm(rx_pos - ix2) * grid_scale;

            fspl = 20*log10(max(0.1, d1_m + d2_m + d3_m)) + 20*log10(freq_hz) + 20*log10(4*pi/c);
            penalty = 20 + 10*log10((d2_m/10) + 1) + 10*log10((d3_m/10) + 1);
            min_path_loss = min(min_path_loss, fspl + penalty);
        end
    end

    if is_tx_horz && is_rx_horz
        for x_cross = 1.5 : 2 : 19.5
            ix1 = [x_cross, ctx_y];
            ix2 = [x_cross, crx_y];
            
            d1_m = norm(ix1 - tx_pos) * grid_scale;
            d2_m = norm(ix2 - ix1) * grid_scale;
            d3_m = norm(rx_pos - ix2) * grid_scale;

            fspl = 20*log10(max(0.1, d1_m + d2_m + d3_m)) + 20*log10(freq_hz) + 20*log10(4*pi/c);
            penalty = 20 + 10*log10((d2_m/10) + 1) + 10*log10((d3_m/10) + 1);
            min_path_loss = min(min_path_loss, fspl + penalty);
        end
    end

    % Final Calculation
    path_loss_db = min_path_loss;
    rx_signal_dbm = tx_power_dbm - path_loss_db;
end
function loss_db = calculateKnifeEdgeLoss(d1, d2, h, freq_hz)
    % Calculates diffraction loss for a single edge using ITU-R P.526
    c = 3e8; 
    lambda = c / freq_hz; 
    
    % Fresnel-Kirchhoff diffraction parameter (nu)
    nu = h * sqrt((2 / lambda) * (1 / d1 + 1 / d2));
    
    if nu < -0.7
        loss_db = 0;
    else
        loss_db = 6.9 + 20 * log10(sqrt((nu - 0.1)^2 + 1) + nu - 0.1);
    end
end
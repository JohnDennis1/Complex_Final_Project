function [sorted_corners, total_pen_length] = getDiffractionCorners(tx_pos, rx_pos)
    % Finds building corners and tracks total penetration through buildings
    corners = [];
    total_pen_length = 0; 
    
    for x_start = 0:2:18
        for y_start = 0:2:18
            building_corners = [
                x_start, y_start;           
                x_start+1, y_start;         
                x_start+1, y_start+1;       
                x_start, y_start+1          
            ];
            
            % Grab the new pen_length output!
            [intersect, pen_length] = doesLineIntersectBox(tx_pos, rx_pos, x_start, x_start+1, y_start, y_start+1);
            
            if intersect
                % Add the concrete depth to our running total
                total_pen_length = total_pen_length + pen_length;
                
                min_dist = inf;
                best_corner = [];
                
                for i = 1:4
                    c = building_corners(i, :);
                    dist = pointToLineDistance(c, tx_pos, rx_pos);
                    if dist < min_dist
                        min_dist = dist;
                        best_corner = c;
                    end
                end
                corners = [corners; best_corner];
            end
        end
    end
    
    if ~isempty(corners)
        distances_from_tx = sum((corners - tx_pos).^2, 2);
        [~, sort_idx] = sort(distances_from_tx);
        sorted_corners = corners(sort_idx, :);
    else
        sorted_corners = [];
    end
end
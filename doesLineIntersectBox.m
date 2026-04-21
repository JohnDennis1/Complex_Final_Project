function [intersect, pen_length] = doesLineIntersectBox(p1, p2, xmin, xmax, ymin, ymax)
    % Ray-AABB intersection algorithm to find penetration length
    dx = p2(1) - p1(1);
    dy = p2(2) - p1(2);
    
    tmin = 0; 
    tmax = 1;
    
    % Check X boundaries
    if dx ~= 0
        tx1 = (xmin - p1(1))/dx;
        tx2 = (xmax - p1(1))/dx;
        tmin = max(tmin, min(tx1, tx2));
        tmax = min(tmax, max(tx1, tx2));
    elseif p1(1) < xmin || p1(1) > xmax
        intersect = false; pen_length = 0; return;
    end
    
    % Check Y boundaries
    if dy ~= 0
        ty1 = (ymin - p1(2))/dy;
        ty2 = (ymax - p1(2))/dy;
        tmin = max(tmin, min(ty1, ty2));
        tmax = min(tmax, max(ty1, ty2));
    elseif p1(2) < ymin || p1(2) > ymax
        intersect = false; pen_length = 0; return;
    end
    
    % If a valid intersection range exists inside the segment
    if tmax > tmin
        intersect = true;
        % Calculate the physical length of the ray inside the box
        pen_length = (tmax - tmin) * norm([dx, dy]);
    else
        intersect = false;
        pen_length = 0;
    end
end
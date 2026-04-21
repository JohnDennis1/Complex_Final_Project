function dist = pointToLineDistance(pt, line_start, line_end)
    % Standard perpendicular distance from point to line
    numerator = abs((line_end(1)-line_start(1))*(line_start(2)-pt(2)) - (line_start(1)-pt(1))*(line_end(2)-line_start(2)));
    denominator = norm(line_end - line_start);
    dist = numerator / denominator;
end
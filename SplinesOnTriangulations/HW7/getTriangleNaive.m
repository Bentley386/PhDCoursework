function triVerts = getTriangleNaive(ptCloud)
% Given a point cloud (matrix of points) return vertices of a triangle that
% enclose all these points

% start by constructing a circle enclosing all points
center = mean(ptCloud); %naively the circle center is just the mean
maxRadius = -1;
for i = 1:size(ptCloud,1)
    maxRadius = max([maxRadius,norm(ptCloud(i,:)-center)]);
end
maxRadius = maxRadius + 0.001; %just to be safe let's put all points inside
triVerts = [center(1)-maxRadius, center(2)-maxRadius;
            center(1)+maxRadius*(1+sqrt(2)),center(2)-maxRadius;
            center(1)-maxRadius, center(2)+maxRadius*(1+sqrt(2))]; %triangle whose inscribed circle is our circle
end


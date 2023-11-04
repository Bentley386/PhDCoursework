function triVerts = getEnclosingTriangle(ptCloud)
% Description:
%  For given collection of points, find the minimal area triangle
%  enclosing them.
%
% Input parameter:
%  ptCloud    a ?x2 table containing the points that need to be enclosing.
%
% Output parameter:
%  triVerts   a 3x2 table, with the vertices of the triangle

k = convhull(ptCloud); %row indices of points, arranged counterclockwise
k(end) = []; %convhull repeats a point
k = flip(k); %we want clockwise order
polygon = NaN(size(k,1),2); %convex hull coordinates (instead of indices)
for i=1:size(k,1)
    polygon(i,:) = ptCloud(k(i),:);
end

N = size(k,1);

A = NaN(2,2); %candidate for edge A of triangle
B = NaN(2,2);
C = NaN(2,2);

vertexA = NaN(1,2); %candidate for vertex A of triangle
vertexB = NaN(1,2);
vertexC = NaN(1,2);
minArea = 1000000;


%Optimal triangle has two edges flush with polygon (flush means that the
%triangle edge is overlapping with polygon edge). Third edge can be either
%also flush or it touches one of the polygon vertices in the middle.

for a=1:N
    A = [polygon(a,:) ; polygon(prev(a),:)]; %first triangle edge is flush with polygon
    for b = 1:N
        B = [polygon(b,:) ; polygon(prev(b),:)]; %second triangle edge flush with polygon
        for c = 1:N
            if a==b || a==c || b==c
                continue;
            end
            C = [polygon(c,:) ; polygon(prev(c),:)]; % third side also flush
            checkValid();
            if c == prev(a) || c == prev(b)
                continue;
            end
            mat = [eye(2), (A(1,:)-A(2,:)).', zeros(2,1) ;
                   -eye(2), zeros(2,1), (B(1,:)-B(2,:)).'];
            rhs = [(A(1,:)-C(1,:)).' ; (B(1,:)-C(1,:)).'];
            v = mat\rhs; %vertex midpoint
            v = v(1:2).';
            C = [polygon(c,:) ; polygon(c,:)+v]; %third edge not flush, but touching at midpoint
            checkValid();
        end
    end
end

triVerts = [vertexA ; vertexB ; vertexC];

    function result = prev(ind)
        % previous vertex
        result = ind - 1;
        if result < 1
            result = N;
        end
    end
    
    function ptInt =  intersectionTwoLines(A1,A2,B1,B2)
        mat = [(A2-A1).', (B2-B1).'];
        rhs = (B1-A1).';
        sol = mat\rhs;
        ptInt = A1 + sol(1)*(A2-A1);
    end
    function checkValid()
        vertA = intersectionTwoLines(A(1,:),A(2,:),B(1,:),B(2,:));
        vertB = intersectionTwoLines(A(1,:),A(2,:),C(1,:),C(2,:));
        vertC = intersectionTwoLines(C(1,:),C(2,:),B(1,:),B(2,:));
        coords = NaN(size(ptCloud,1),3);
        for i=1:size(ptCloud)
            coords(i,:) = barycentricMap([vertA ; vertB ; vertC], ptCloud(i,:).').'; 
        end
        %coords = barycentricMap([vertA ; vertB; vertC], centerPt.');
        if all((coords <= 1),'all') && all((coords >= 0),'all') % center point is inside the triangle - good
            aa = norm(vertA-vertB); %TODO maybe use triangleArea function here...
            bb = norm(vertA-vertC);
            cc = norm(vertB-vertC);
            s = 0.5*(aa+bb+cc);
            area = sqrt(s*(s-aa)*(s-bb)*(s-cc)); %right now getting area with heron formula
            if area < minArea
                minArea = area;
                vertexA = vertA;
                vertexB = vertB;
                vertexC = vertC;
            end
        end
    end
end
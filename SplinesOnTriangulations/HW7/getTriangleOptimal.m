function triVerts = getTriangleOptimal(ptCloud)
% Optimal enclosing triangle
% Brute force algorithm for lowest area triangle
% using the fact that two of the triangle sides are flush with convex hull,
% while the third one is eihther flush or its midpoint touches the polygon.
% might fail on special cases when some sides of convex hull are parallel

k = convhull(ptCloud); %row indices of points, arranged counterclockwise
k(end) = []; %convhull repeats a point
k = flip(k); %we want clockwise order
polygon = zeros(size(k,1),2);
for i=1:size(k,1)
    polygon(i,:) = ptCloud(k(i),:);
end

N = size(k,1);

A = zeros(2,2);
B = zeros(2,2);
C = zeros(2,2);

vertexA = zeros(1,2);
vertexB = zeros(1,2);
vertexC = zeros(1,2);
minArea = 1000000;

for a=1:N
    A = [polygon(a,:) ; polygon(prev(a),:)];
    for b = 1:N
        B = [polygon(b,:) ; polygon(prev(b),:)];
        for c = 1:N
            if a==b || a==c || b==c
                continue;
            end
            C = [polygon(c,:) ; polygon(prev(c),:)]; % third side also flush
            %fprintf("checking flush edge\n");
            checkValid();
            if c == prev(a) || c == prev(b)
                continue;
            end
            %third side touches polygon at a point
            % side is then tangent
            mat = [eye(2), (A(1,:)-A(2,:)).', zeros(2,1) ;
                   -eye(2), zeros(2,1), (B(1,:)-B(2,:)).'];
            rhs = [(A(1,:)-C(1,:)).' ; (B(1,:)-C(1,:)).'];
            v = mat\rhs; %vertex midpoint
            v = v(1:2).';
            C = [polygon(c,:) ; polygon(c,:)+v];
            %fprintf("Checking vertex %d %d \n",polygon(c,1),polygon(c,2));
            checkValid();
        end
    end
end

triVerts = [vertexA ; vertexB ; vertexC];

    function result = next(ind)
        % next vertex
        result = ind + 1;
        if result > N
            result = 1;
        end
    end

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
        coords = zeros(size(ptCloud,1),3);
        for i=1:size(ptCloud)
            coords(i,:) = barycentricMap([vertA ; vertB ; vertC], ptCloud(i,:).').';
        end
        %coords = barycentricMap([vertA ; vertB; vertC], centerPt.');
        if all((coords <= 1),'all') && all((coords >= 0),'all') % center point is inside the triangle - good
            aa = norm(vertA-vertB);
            bb = norm(vertA-vertC);
            cc = norm(vertB-vertC);
            s = 0.5*(aa+bb+cc);
            area = sqrt(s*(s-aa)*(s-bb)*(s-cc));
            if area < minArea
                minArea = area;
                vertexA = vertA;
                vertexB = vertB;
                vertexC = vertC;
            end
        end


    end

end
function triVerts = getTriangleOptimalUnfinished(ptCloud)
% Optimal enclosing triangle
% ptCloud is a matrix of points
% Mostly finished copying algorithm from O. Parvu and D. Gilbert, Implementation of linear minimum area enclosing triangle algorithm
% Unfortunately found out very late that there is missing/ambigous information in
% their pseudocode so couldn't finish



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

middlePoint = zeros(1,2);
gammaPoint = zeros(1,2);
angle = 0;

vertexA = zeros(1,2);
vertexB = zeros(1,2);
vertexC = zeros(1,2);
flag = "";

a = 2;
b = 3;
c = 1
for cntr=1:N
    c = cntr;
    C = [polygon(c,:) ; polygon(prev(c),:)];
    advanceBToRight();
    moveAIfLowAndBIfHigh();
    searchForBTangency();
    updateSidesCA();
    if isNotBTangency()
        updateSidesBA();
    else
        updateSideB();
    end

    if isLocalMinimalTriangle();
        updateTriangle();
    end
end

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
    
    function dist = h(p)
        % p index of point in convex hull
        P1 = C(1,:);
        P2 = C(2,:);
        P0 = polygon(p,:);
        dist = abs((P2(1)-P1(1))*(P1(2)-P0(2)) - (P1(1)-P0(1))*(P2(2)-P1(2))) / norm(P2-P1);
    end

    function advanceBToRight()
        while h(next(b)) > h(b)
            b = next(b);
        end
    end

    function moveAIfLowAndBIfHigh()
        while h(b) > h(a)
            if gamma(a, gammaPoint) && intersectsBelow(gammaPoint,b)
                b = next(b);
            else
                a = next(a);
            end
        end
    end

    function searchForBTangency()
        while gamma(b, gammaPoint) && intersectsBelow(gammaPoint,b) && (h(b) >= h(prev(a)))
            b = next(b);
        end
    end

    function updateSidesCA()
        C(1,:) = polygon(prev(c),:);
        C(2,:) = polygon(c,:);
        A(1,:) = polygon(prev(a),:);
        A(2,:) = polygon(a,:);
    end

    function bool = isNotBTangency()
        if (gamma(b, gammaPoint) && intersectsAbove(gammaPoint,b)) || (h(b) < h(prev(a)))
            bool = 1;
        else
            bool = 0;
        end
    end

    function updateSidesBA()
        B(1,:) = polygon(prev(b),:);
        B(2,:) = polygon(b,:);

        if middlePointOfSideB() && h(middlePoint) < h(prev(a))
            A(1,:) = polygon(prev(a),:);
            A(2,:) = findVertexCOnSideB();
            flag = "SIDE_A_TANGENT";
        else
            flag = "SIDES_FLUSH";
        end
    end

    function updateSideB()
        gamma(b, gammaPoint);
        B(1,:) = gammaPoint;
        B(2,:) = polygon(b,:);
        flag = "SIDE_B_TANGENT";
    end

    function bool = isLocalMinimalTriangle()
        if (notIntersect(A,B)) || (notIntersect(A,C)) || (notIntersect(B,C))
            bool = 0;
        else
            vertexA = intersection(B,C);
            vertexB = intersection(A,C);
            vertexC = intersection(A,B);
            bool = isValidMinimalTriangle();
        end
    end

    function bool = isValidMinimalTriangle()
        midpointA = (vertexB + vertexC)/2;
        midpointB = (vertexA + vertexC)/2;
        midpointC = (vertexA + vertexB)/2;

        if flag == 'SIDE_A_TANGENT'
            validA = (midpointA == polygon(prev(a),:));
        else
            validA = inSegment(midpointA,A(1,:),A(2,:));
        end

        if flag == 'SIDE_B_TANGENT'
            validB = (midpointB == polygon(b,:));
        else
            validB = inSegment(midpointB, B(1,:),B(2,:));
        end

        validC = inSegment(midpointC,C(1,:),C(2,:));

        bool = validA && validB && validC;
    end

    function bool = middlePointOfSideB()
        if notIntersect(B,C) || notIntersect(A,B)
            bool = 0
        else
            vertexA = intersection(B,C);
            vertexC = intersection(A,B);
            middlePoint = (vertexA+vertexC)/2;
            bool = 1;
        end
    end

    function bool = intersectsBelow(gammaPoint,index)
        angle = angleOfLine(polygon(index,:), gammaPoint);
        bool = (intersects(angle,index) == "BELOW");
    end

    function bool = intersectsAbove(gammaPoint, index)
        angle = angleOfLine(gammaPoint, polygon(index,:));
        bool = (intersects(angle,index) == 'ABOVE');
    end

    function typeInt = intersects(angle, index)
        anglePred = angleOfLine(polygon(prev(index),:),polygon(index,:));
        angleSucc = angleOfLine(polygon(next(index),:),polygon(index,:));
        angleC = angleOfLine(polygon(prev(c),:),polygon(c,:));

        if isAngleBtwPredAndSucc( angleC, anglePred, angleSucc)
            if isAngleBtwNonReflex(angle, anglePred, angleC) || (angle == anglePred)
                typeInt = intersectsAboveOrBelow(prev(index),index);
            elseif isAngleBtwNonReflex(angle, angleSucc, angleC) || (angle == angleSucc)
                typeInt = intersectsAboveOrBelow(next(index),index)
            end
        elseif isAngleBtwNonReflex( angle, anglePred, angleSucc) || ((angle == anglePred) && (angle ~= angleC)) || ((angle == angleSucc) && (angle ~= angleC))
            typeInt = 'BELOW';
        else
            typeInt = 'CRITICAL';
        end
    end

    function typeInt = intersectsAboveOrBelow( succOrPredIndex,index)
        if h(succOrPredIndex) > h(index)
            typeInt = 'ABOVE';
        else
            typeInt = 'BELOW';
        end
    end

    function angle = angleOfLine(p1,p2)
        y = p2(2) - p1(2);
        x = p2(1) - p1(1);
        angle = atan(y,x) * 180 / pi;
        if angle < 0
            angle = angle + 360;
        end
    end

    function bool = isAngleBtwPredAndSucc( angle, anglePred, angleSucc)
        if isAngleBtwNonReflex(angle, anglePred, angleSucc)
            bool=1;
        elseif isOppositeAngleBtwNonReflex(angle,anglePred, angleSucc)
            angle = oppositeAngle(angle);
            bool = 1;
        else
            bool = 0;
        end
    end

    function bool = isAngleBtwNonReflex(angle, angle1, angle2)
        if abs(angle1-angle2) > 180
            if angle1 > angle2
                bool = ((angle1 < angle) && (angle <= 360)) || ((0 <= angle) && (angle < angle2));
            else
                bool = ((angle2 < angle) && (angle <= 360)) || ((0 <= angle) && (angle < angle1));
            end
        else
            if mod(angle1-angle2,180) > 0
                bool = (angle2 < angle) && (angle < angle1);
            else
                bool = (angle1 < angle) && (angle < angle2);
            end
        end
    end

    function bool = isOppositeAngleBtwNonReflex(angle, angle1, angle2)
        oppAngle = oppositeAngle(angle);
        bool = isAngleBtwNonReflex(oppAngle, angle1, angle2);
    end

    function oppAngle = oppositeAngle(angle)
        if angle > 180
            oppAngle = angle - 180;
        else
            oppAngle = angle + 180;
        end
    end

    function bool = gamma(index, gammaPoint)
        if ~findGammaIntersectionPoints(index, polygon(a,:),polygon(prev(a),:), polygon(c,:),polygon(prev(c),:), intersectionPoint1, intersectionPoint2)
            bool = 0
        else
            if sameSideOfLine(C,intersectionPoint1,polygon(next(c),:))
                gammaPoint = intersectionPoint1;
            else 
                gammaPoint = intersectionPoint2;
            end
            bool = 1;
        end
    end

    function resPt = findVertexCOnSideB()
        if sameSideOfLine(C, intersectionPoint1, polygon(next(c),:))
            resPt = intersectionPoint1;
        else
            resPt = intersectionPoint2;
        end
    end


end
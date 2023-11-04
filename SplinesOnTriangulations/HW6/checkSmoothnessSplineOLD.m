function checkSmoothnessSplineOLD(tri,f,d1f,d2f)
% Checks smoothness of a spline over triangulation (assuming the spline is
% constructed from given function and its derivatives)
% tri - triangulation object
% spline - bezier-bernstein coefficients for each triangle
% THIS IS OLD VERSION OF THE FUNCTION THAT COMPUTES INTERPOLATION FOR EACH
% TRIANGLE SEPERATELY AGAIN. USE checkSmoothnessSpline instead!

pts = tri.Points;
npts = size(pts,1);
fprintf("The spline is smooth in the triangle interiors. Checking for order of smoothness on each edge...\n");
E = edges(tri);
for e = 1:size(E,1)
    p1 = E(e,1);
    p2 = E(e,2);
    p3 = NaN;
    p4 = NaN;
    for i=1:npts
        if i==p1 || i==p2
            continue
        end
        if isConnected(tri,p1,i) && isConnected(tri,p2,i)
            if isnan(p3)
                p3 = i;
            else
                p4 = i;
            end
        end
    end
    if isnan(p4)
        continue
    end
    t1 = [pts(p1,:);pts(p2,:);pts(p3,:)];
    t2 = [pts(p1,:);pts(p2,:);pts(p4,:)];
    alpha1 = zeros(3,3);
    alpha2 = zeros(3,3);
    for i=1:3
        alpha1(i,1) = f(t1(i,1),t1(i,2));
        alpha1(i,2) = d1f(t1(i,1),t1(i,2));
        alpha1(i,3) = d2f(t1(i,1),t1(i,2));
        alpha2(i,1) = f(t2(i,1),t2(i,2));
        alpha2(i,2) = d1f(t2(i,1),t2(i,2));
        alpha2(i,3) = d2f(t2(i,1),t2(i,2));        
    end

    b1 = interpolation(t1,alpha1);
    b2 = interpolation(t2,alpha2);
    r = -1;
    while r<3
        breq = coeffSmoothness(t1,t2,r+1,b1);
        b2temp = b2;
        b2temp(isnan(breq)) = nan;
        if isequaln(breq,b2temp)
            r = r+1;
        else
            break
        end
    end

    fprintf("Degree of smoothness along edge %d is C^%d\n",e,r);
end
end


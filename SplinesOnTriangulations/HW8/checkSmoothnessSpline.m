function es = checkSmoothnessSpline(tri,spline)
% Checks smoothness of a spline over triangulation (assuming the spline is
% constructed from given function and its derivatives)
% tri - triangulation object
% spline - bezier-bernstein coefficients for each triangle

pts = tri.Points;
cl = tri.ConnectivityList;
npts = size(pts,1);
fprintf("The spline is smooth in the triangle interiors. Checking for order of smoothness on each edge...\n");
E = edges(tri);
es = [];
for e = 1:size(E,1)
    p1 = E(e,1);
    p2 = E(e,2);
    eAs = edgeAttachments(tri,p1,p2);
    eAs = eAs{1};
    if size(eAs,2) == 1
        continue
    end
    tri1 = eAs(1);
    tri2 = eAs(2);
    triangle1 = cl(tri1,:);
    triangle2 = cl(tri2,:);
    triangle1(triangle1 == p1 | triangle1 == p2) = [];
    p3 = triangle1;
    triangle2(triangle2 == p1 | triangle2 == p2) = [];
    p4 = triangle2;

    % triangle vertices in spline might not be ordered such that first two
    % correspond to matching edge..
    t1 = [pts(p1,:);pts(p2,:);pts(p3,:)];
    t2 = [pts(p1,:);pts(p2,:);pts(p4,:)];
    t10 = [pts(cl(tri1,1),:); pts(cl(tri1,2),:); pts(cl(tri1,3),:)];
    t20 = [pts(cl(tri2,1),:); pts(cl(tri2,2),:); pts(cl(tri2,3),:)];
    b1 = changeBasis(t10,t1,squeeze(spline(tri1,:,:)));
    b2 = changeBasis(t20,t2,squeeze(spline(tri2,:,:)));

    r = -1;
    while r<3
        breq = coeffSmoothness(t1,t2,r+1,b1);
        b2temp = b2;
        b2temp(isnan(breq)) = nan;
        b2temp(isnan(b2temp)) = 0;
        breq(isnan(breq)) = 0;
        yn = abs(breq - b2temp) <= 0.00000000000001;
        if all(yn)
            r = r+1;
        else
            break
        end
    end
    if r==3
        es = [es, e];
    end
    fprintf("Degree of smoothness along edge %d is C^%d\n",e,r);
end
end

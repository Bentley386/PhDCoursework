function checkSmoothnessSpline(tri,spline)
% Checks smoothness of a spline over triangulation (assuming the spline is
% constructed from given function and its derivatives)
% tri - triangulation object
% spline - bezier-bernstein coefficients for each triangle

pts = tri.Points;
cl = tri.ConnectivityList;
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
    if isnan(p4) % outer edge
        continue
    end
    % triangle vertices in spline might not be ordered such that first two
    % correspond to matching edge..
    t1 = [pts(p1,:);pts(p2,:);pts(p3,:)];
    t2 = [pts(p1,:);pts(p2,:);pts(p4,:)];
    tri1 = pointLocation(tri,(t1(1,:)+t1(2,:)+t1(3,:))/3);
    tri2 = pointLocation(tri,(t2(1,:)+t2(2,:)+t2(3,:))/3);
    t10 = [pts(cl(tri1,1),:); pts(cl(tri1,2),:); pts(cl(tri1,3),:)];
    t20 = [pts(cl(tri2,1),:); pts(cl(tri2,2),:); pts(cl(tri2,3),:)];
    b1 = changeBasis(t10,t1,squeeze(spline(tri1,:,:)));
    b2 = changeBasis(t20,t2,squeeze(spline(tri2,:,:)));

    r = -1;
    while r<2
        breq = coeffSmoothness(t1,t2,r+1,b1);
        b2temp = b2;
        b2temp(isnan(breq)) = nan;
        if isequaln(breq,b2temp)
            r = r+1;
        else
            break
        end
    end

    fprintf("Degree of smoothness along edge %d is C^%d (only checking until C^2)\n",e,r);
end
end

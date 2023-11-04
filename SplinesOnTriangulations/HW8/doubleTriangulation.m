function tri = doubleTriangulation(tri0)
% refine a triangulation by bisecting each edgge.
% tri0 original triangulaton
% returns a triangulation obtained by splitting each edge into two equally
% long parts

pts = tri0.Points;
cl = tri0.ConnectivityList;

newpts = zeros(0,2);
newtriangles = zeros(0,3);

for i=1:size(cl,1)
    p1 = pts(cl(i,1),:);
    p2 = pts(cl(i,2),:);
    p3 = pts(cl(i,3),:);
    tripts = [p1;
        p2;
        p3; 
        (p1(:)+p2(:)).'/2;
        (p1(:)+p3(:)).'/2;
        (p2(:)+p3(:)).'/2]; %all 6 points of "new" triangles
    pointindices = zeros(6); %indices of the 6 points to prevent duplication
    for j=1:6
        if ismember(tripts(j,:),newpts,'rows')
            pointindices(j) = find(ismember(newpts,tripts(j,:),'rows'));
        else
            newpts = [newpts ; tripts(j,:)];
            pointindices(j) = size(newpts,1);
        end
    end
    pti = pointindices; %like a typedef, faster typing
    newtriangles = [newtriangles;
        pti(1) pti(4) pti(5); %p1 p12 p13
        pti(2) pti(6) pti(4);%p2 p23 p21
        pti(3) pti(6) pti(5);%p3 p32 p31
        pti(4) pti(5) pti(6)];%p12 p23 p13
end
tri = triangulation(newtriangles,newpts);
end


function pts = getPointCloud(tri,idx)
% From a given triangulation and point index,
% return list of points that such {x} such that for each edge[vi,vj]
% the point 2/3 vi + 1/3 vj is in it.

pts0 = tri.Points;
cl0 = tri.ConnectivityList;

neighTrias = vertexAttachments(tri,idx);
neighTrias = neighTrias{1}; % prev method returns cell array
neighVerts = dictionary(idx,1); %dictionary of vertex indices acts as a set
for tria = neighTrias
    for vert = cl0(tria,:)
        neighVerts(vert) = 1;
    end
end

pt0 = pts0(idx,:);
ptIndices = neighVerts.keys();
pts = zeros(size(ptIndices,1),2);
for i = 1:size(ptIndices,1)
    pts(i,:) = 2/3*pt0 + 1/3 * pts0(ptIndices(i),:);
end

end


function pts = getPointCloud(tri,idx)
% Description:
%  For a given vertex,
%  return the points that are needed to construct its spline basis. 
%
% Input parameters:
%  tri      The triangulation object. 
%  idx      Vertex index we would like to construct the basis for.
%
% Output parameter:
%  pts     a ?x2 table, consisting of 2/3v_idx + 1/3 vj
%           for each neighbouring vertex vj.

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


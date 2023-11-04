function res = boundaryEdge(tri,startID,endID)
% Description:
%  Check if the given edge of the triangulation is on the boundary of
%  the domain.
%
% Input parameters:
%  tri      The triangulation object. 
%  startID  Point index of the first vertex.
%  endID    Point index of the second vertex.
%
% Output parameter:
%  res      1 if [startID,endId] (or reversed) edge is boundary, else 0.

neightris = edgeAttachments(tri,startID,endID);
neightris = neightris{1}; %edgeAttachments returns as cell array
if size(neightris,2) == 1
    res = 1;
else
    res = 0;
end
end


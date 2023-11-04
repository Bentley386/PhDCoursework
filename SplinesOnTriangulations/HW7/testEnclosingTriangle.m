points = rand(20,2);

triPts = getTriangleNaive(points);
triPts2 = getTriangleOptimal(points);

k = convhull(points);
k(end) = []; %convhull repeats a point
k = flip(k); %we want clockwise order
polygon = zeros(size(k,1),2);
for i=1:size(k,1)
    polygon(i,:) = points(k(i),:);
end

figure
subplot(1,2,1);
scatter(points(:,1),points(:,2),'red');
hold;
scatter(polygon(:,1),polygon(:,2),'blue');
%scatter(triPts(:,1),triPts(:,2),'green');
triplot([1,2,3],triPts(:,1),triPts(:,2),'green');
title('Naivno');

subplot(1,2,2);
scatter(points(:,1),points(:,2),'red');
hold;
scatter(polygon(:,1),polygon(:,2),'blue');
%scatter(triPts2(:,1),triPts2(:,2),'green');
triplot([1,2,3],triPts2(:,1),triPts2(:,2),'green');
title('Optimalno');
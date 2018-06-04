function [path] = RandomSubject(N,M,len,dist,id)
    %This function, given a range of numbers, and length, generates a vector of
    %x and y coordinates within the bounds of the range specified. Each point
    %is within a small range of the point preceding it. This simulates a
    %movement along a NxM grid that can be used to generate a random subject
    %for eye tracking.
    %N - x-range of grid
    %M - y-range of grid
    %len - length of output vector, i.e. number of samples
    %dist - maximum euclidean distance of each point from the point previous to
    %it
    %id - the identifying number assigned to the subject generated
    
    path = zeros(len,2);
    %Generate first point
    path(1,:) = [randi(N), randi(M)];
    %keeps a buffer of the last k points, to ensure all points within each
    %k-length sub-vector are unique
    tab = zeros(6,2);
    tab(1) = path(1,:);
    k = 2;
    %Generate next len - 1 points
    for i = 2:len
        xdist = randi(dist); ydist = dist-xdist;
        %Create subrange around previous point in which new point may arise
        lowx = max(N(1),path(i-1,1)-xdist); highx = min(N(2),path(i-1,1)+xdist);
        lowy = max(M(2),path(i-1,2)-ydist); highy = min(M(2),path(i-1,2)+ydist);
        n = [lowx,highx];m = [lowy,highy];
        %Generate new point close to old point
        path(i,:) = [randi(n), randi(m)];
        %Add point to tabu
        k = mod(k,6);
        tab(k) = path(i,:);
    end 
    save(strcat("Random",int2str(id),'mat'),path);
end


function r_set = getRandomSet(Num, lb, ub)
% Get a random set of unmbers between an interval
% Num <- Number of elements needed. ub <- Upper bound (Maximum). lb <- Lower bound (minimum)
    random_set   = unique(randperm(ub));
    random_range = random_set(random_set > lb);
    r_set        = random_range(1:Num);
end


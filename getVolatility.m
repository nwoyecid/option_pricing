function [vol] = getVolatility(S0, N, M, sw)
% Calculate Market Volatility
% S0 = stock prices, N = Number of days, M = number of strike prices, sw = shifting window
% Calculate Volatility
vol = zeros(N-sw, M);
tau =  252;
for q = 1: M
    for t = 1:(N-sw)
        % Calculate the percentage change over the past N trading days
        log_change = log(S0(t+1:t+sw, q)./S0(t:t+sw-1, q));
        % Get standard deviation of that change
        stdev = std(log_change);
        % Now normalize to annual volatility
        vol(t,q) = stdev*sqrt(tau);     
        % Shift quarter (sliding window)
        % sw = sw + 1;
    end
end
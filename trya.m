clear all; clc; close all;

a_price = 3205;
a_day = 150;
Rate = 0.06;
a_time = 0.28; %(223-a_day)/222;
c_option = [308,227,155,108,60];
p_option = [19,34,61,101,158];
Limit = 10;
strike_p = 200:50:3500;
strike_p2 = 3400:50:5500;
for i = 1:length(strike_p)    
    call_impVolt(i) = blsimpv(a_price, strike_p(i), Rate, a_time, c_option(5), Limit, 0, [], {'Call'});
   end

for i = 1:length(strike_p)
    put_impVolt(i)  = blsimpv(a_price, strike_p(i), Rate, a_time, p_option(5), Limit, 0, [], {'Put'} );
end

figure; 
plot(strike_p, call_impVolt, 'b');
xlabel('Strike price '); ylabel('Impled volatility'); 
    title('Call Option Volatility Smile ');
    
    
figure; plot(strike_p, put_impVolt, 'b'); % hold; scatter(a_strike, put_impVol); hold off;
xlabel('Strike price '); ylabel('Impled volatility'); title('Put Option Volatility Smile ');

% 
% for i = 1:20-5
%     fprintf(' First %f to %f and %f to %f\n', i+1, i+5, i, i+5-1)
% end
% % X = load('c2925');
% 
% 
%  clc       
% Price =  3480;
% Price2 = 3517.5000;
% 
% 
% strike = 2925;
% Rate = 0.06;
% tau = 252;
% time = (223-50)/tau;
% 
% % Calculate Volatility
% log_change = log(Price./Price2);
% % Get standard deviation of that change
% stdev = std(log_change);
% % Now normalize to annual volatility
% vol = stdev*sqrt(tau)
% 
% vol = 0.8377;
% [cc,pp] = blsprice(Price, strike, Rate , time, vol)
% limit = 10;
% value = cc-1;
% imp_vol = blsimpv(Price, strike, Rate, time, value, limit, 0, [], {'Call'})
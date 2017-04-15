% clear; close all; clc;
%% load the data
stocks = load('stock.mat');
% stock_label = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325', 'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};
% call_label  = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325'};
% put_label   = {'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};
% 
% %% Prepare all data matrix
% [N, M]              = size(getfield(stocks, stock_label{1}));
% [nc, mc]            = size(stock_label);
% [np, mp]            = size(stock_label);
% option_matrix       = [];
% call_option_matrix  = zeros(N, mc);
% put_option_matrix   = zeros(N, mp);
% 
% for p = 1: length(stock_label)
%    option_price(:,p)= stocks.(stock_label{p})(:,2);
%    market_price(:,p)= stocks.(stock_label{p})(:,3);
%    option_type(p)   = stock_label{p}(1:1);
%    strike_price(p)  = str2num(stock_label{p}(2:5));   
% end
% 
% [row, col]          = size(option_price);
% quarter             = round(row/4);
% tau                 = 252;
% Rate = 0.06;
% 
% %%  Random set of 30 days
% random_set          = getRandomSet(30, round(row/4), row);
% for q = 1: col
%     random_market_price_matrix(:, q) = (market_price(random_set, q));
%     random_option_price_matrix(:, q) = (option_price(random_set, q));
% end
% 
% t = 100;
% time = (tau - t)/tau;
% Price = market_price(t,q);
% [Call(t,q),Put(t,q)] = blsprice(Price, strike_price(q), Rate , time, volatility(t-quarter,q));
% time2 = (tau - random_set)/tau;
% 
% implied_volatility(:,q) = blsimpv(random_market_price_matrix(:,q), strike_price(q), Rate, time2(:,q), Value, 0.5, 0, [], Clas);
% 
%  
% % time2   = (tau - random_set)/tau;
% % for q = 1 : col  
% %     quarter     = round(row/4);
% %     if(option_type(q)=='c')
% %         Value   = Call(random_set,q);
% %         Clas    = {'Class'};
% %     else
% %         Value   = Put(random_set,q);
% %         Clas    = {'Put'};
% %     end
% %     implied_volatility(:,q) = blsimpv(random_market_price_matrix(:,q), strike_price(q), Rate, time2(:,q), Value, 0.5, 0, [], Clas);
% % end
clc;
Rate = 0.06;
Price = 3013;
time = (252 - 222)/252;
volatility = 0.141974762082100;
strike_price = 2925;
[C,P] = blsprice(Price, strike_price, Rate , time, volatility)
%[127.791671752930]
Value = C;
Clas    = {'Call'};
implied_volatility = blsimpv(Price, strike_price, Rate, time, Value, 0.5, 0, [], Clas)


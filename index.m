clear; close all; clc;
%% load the data
stocks = load('stock.mat');
stock_label = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325', 'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};
call_label  = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325'};
put_label   = {'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};
%%
[N, M] = size(getfield(stocks, stock_label{1}));
[nc, mc] = size(stock_label);
% [np, mp] = size(stock_label);
option_matrix = [];
call_option_matrix = zeros(N, mc);
put_option_matrix  = zeros(N, mc);

for p = 1: length(stock_label)
   option_price(:,p)  = stocks.(stock_label{p})(:,2);
   market_price(:,p)  = stocks.(stock_label{p})(:,3);
   option_type(p)   = stock_label{p}(1:1);
   strike_price(p)  = str2num(stock_label{p}(2:5));   
end

[r, c]      = size(option_price);
quarter     = round(r/4);
% volatility  = zeros(r-quarter, c);
tau = 252;
Rate = 0.06;
maturity = 223;
Limit = 10;

% Calculate Volatility
for q = 1: length(strike_price)
    quarta = quarter;
    for t = 1:r-quarta
        % Calculate the percentage change over the past N trading days
        log_change = log(market_price(t+1:quarta-1, q)./market_price(t:quarta-2, q));
        % Get standard deviation of that change
        stdev = std(log_change)

        % Now normalize to annual volatility
        volatility(t,q) = stdev*sqrt(tau);
%         time = (maturity - t)/tau;
%         Price = market_price(t);
        % Calculate call and put options
        %[Call(t,q),Put(t,q)] = blsprice(market_price(t+quart, q), strike_price(q), Rate , time, volatility(t,q))
       
        % Shift quarter (sliding window)
        quarta = quarta + 1;
    end
end

%% Calculate Call and Put

for q = 1: length(strike_price)
    for t = quarter+1:r
        time = (maturity - t)/tau;
        time = 0.25;
        Price = market_price(t,q);
%         fprintf('%.6f\n',time);
        [Call(t-quarter,q),Put(t-quarter,q)] = blsprice(Price, strike_price(q), Rate , time, volatility(t-quarter,q));
    end
end

for q = 1: length(strike_price) 
    if(option_type(q)=='c')
        opt = Call(:,q);
        opti = 'Call';
    else
        opt = Put(:,q);
        opti = 'Put';
    end
    figure; plot(quarter+1:r, opt); hold on;
            plot(quarter+1:r, stocks.(stock_label{q})(quarter+1:end,2)); hold off;
            title([opti ' Option: ' option_type(q)'' num2str(strike_price(q)) ]); xlabel('Time'); ylabel('Option Price');
            legend('Estimated', 'True price');
end

%% 2. 
% Random set of 30 days
random_set = getRandomSet(30, round(r/4), r);
for q = 1: length(strike_price)
    random_market_price_matrix(:, q) = (market_price(random_set, q));
    random_option_price_matrix(:, q) = (option_price(random_set, q));
end

%% % implied volatility
% time2 = (tau - random_set)/tau;
% for q = 1 : length(strike_price)  
%     quarter     = round(r/4);
%     if(option_type(q)=='c')
%         Value = Call(random_set-quarter,q);
%         Clas = {'Class'};
%     else
%         Value = Put(random_set-quarter,q);
%         Clas = {'Put'};
%     end
%     implied_volatility(:,q) = blsimpv(random_market_price_matrix(:,q), strike_price(q), Rate, time2(:,q), Value, 0.5, 0, [], Clas);
% end

% Calculate Implies Volatility

counter = 0;
for q = 1: length(strike_price)
    for t = 1:length(random_set)
        day = random_set(t);
        time2 = (maturity - day)/tau;
        time2 = 0.25;
        Price = random_market_price_matrix(t,q);
        if(option_type(q)=='c')
            Clas = {'Call'};
%             Value = Call(day-quarter,q);
        else
            Clas = {'Put'};
%            Value = Put(day-quarter,q);
        end
         Value = random_option_price_matrix(t,q);
        implied_volatility(t,q) = blsimpv(Price, strike_price(q), Rate, time2, Value, Limit, 0, [], Clas);
        if isnan(implied_volatility(t,q))
            counter = counter + 1;
            fprintf('%d %s day(%d)-> %.4f : (%.1f, %.1f, %.1f, %.4f \n',counter, Clas{1}, random_set(t),implied_volatility(t,q), Price, strike_price(q), Value, time2);
        end
    end
end

%    % implied volatility vs volatility plot
for q = 1: length(strike_price)    
    if(option_type(q)=='c')
        opt = Call(:,q);
        opti = 'Call';
    else
        opt = Put(:,q);
        opti = 'Put';
    end
    figure; scatter(implied_volatility(:,q), volatility(random_set-quarter,q));
            title('Implied Volatility '); xlabel('Impled volatility'); ylabel('Historical Volatility');
            title([opti ' Option: ' option_type(q)'' num2str(strike_price(q)) ]);
%     legend('Implied Volatility', 'Historical Volatility');
end


%% At different strike prices
% Choose a day
a_day = getRandomSet(1, round(r/4), r);
% a_day = 100;
a_time = (maturity - a_day)/tau;
% a_time = 0.25;
a_Price = market_price(a_day,1);
a_option = option_price(a_day,1);

% Compute implied volatilities for different strike prices
for q = 1: length(strike_price) 
%     Call_value = Call(a_day-quarter, q);
%     Put_value  = Put(a_day-quarter, q);
%     call_implied_volatility = [Call_value Put_value];
    a_Price    = market_price(a_day,q);
    a_option   = option_price(a_day,q);
    if(q<=5)
        call_implied_volatility(q) = blsimpv(a_Price, strike_price(q), Rate, a_time, a_option, Limit, 0, [], {'Call'});
    else
        put_implied_volatility(q-5) = blsimpv(a_Price, strike_price(q), Rate, a_time, a_option, Limit, 0, [], {'Put'});
    end
end
close all;

figure; plot(strike_price(1:5), call_implied_volatility)
title('Strike price '); xlabel('Impled volatility'); ylabel('Call Option Volatility Smile ');

figure; plot(strike_price(6:10), put_implied_volatility)
title('Strike price '); xlabel('Impled volatility'); ylabel('Put option Volatility Smile ');

%% 4
clc
k =100;% round(100 * rand() +1);
h =1;% round(5 * rand()+1);
[StockPrice, OptionPrice] = binprice(market_price(k,1), strike_price(h), Rate, 0.25, 0.05,  implied_volatility(h), 1)
[Call_b,Put_b] = blsprice(market_price(k,1), strike_price(h), Rate , time, implied_volatility(h));

dt = 0.01:0.01:0.2;
time = 0.25;
i = 0;
for delta =0.01:0.01:0.2
    i=i+1;
    [StockPrice, OptionPrice] = binprice(market_price(k,1), strike_price(h), Rate, time, delta,  implied_volatility(h), 1);
    abs_diff(i) = abs(OptionPrice(1,1) - Call_b);
    fprintf('%.2f => Call = %.4f and Binomial = %.4f and Difference = %.4f  \n',delta,  Call_b, OptionPrice(1,1), abs_diff(i))
end
plot(dt, abs_diff); xlabel('delta'); ylabel('Absolute difference');
title('Approximation of Binomial Lattice Method to Black-Scholes')

[P, L] = LatticeEurCall(market_price(k,1),strike_price(h),Rate,223,implied_volatility(h),5);

%%




2.875972518054474e+03
        
% Computational Finance - Put and Call Option Assignment
clear; close all; clc;

%% load the data
stocks = load('stock.mat');
stock_label = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325', 'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};
% call_label  = {'c2925', 'c3025', 'c3125', 'c3225', 'c3325'};
% put_label   = {'p2925', 'p3025', 'p3125', 'p3225', 'p3325'};

%% Variable definitions
[N, M]      = size(getfield(stocks, stock_label{1})); %#ok<GFLD>
T           = 223; % Time of Maturity
tau         = 222; %N+1; % 252
[n, m]      = size(stock_label);
Rate        = 0.06;
quarter     = round(N/4);
Limit       = 10;

%% Data preparation in Matrix
for col = 1: m
   option_price(:,col)  = stocks.(stock_label{col})(:,2);
   stock_price(:,col)   = stocks.(stock_label{col})(:,3);
   option_type(col)     = stock_label{col}(1:1);
   strike_price(col)    = str2num(stock_label{col}(2:5));   
end

%% Calculate Historical Volatility
volatility  = getVolatility(stock_price, N, m/2, quarter);

%% Calculate Call and Put Options
Call    = zeros (N - quarter, m/2);
Put     = Call;
for q = 1: m/2
    i = 1;
    for t = quarter+1:N
        time = (T - t)/tau; %  time = 0.25;
        Price = stock_price(t,q);  % fprintf('%.6f\n',time);
        [Call(i,q), Put(i,q)] = blsprice(Price, strike_price(q), Rate , time, volatility(i,q));
        i = i+1;
    end
end

% Plot graph 
for q = 1: m 
    if(option_type(q)=='c')
        opt     = Call(:,q);
        label   = 'Call';
    else
        opt     = Put(:,q-5);
        label   = 'Put';
    end    
    figure; plot(quarter+1:N, opt); hold on;
            plot(quarter+1:N, stocks.(stock_label{q})(quarter+1:N, 2)); hold off;
            title([label ' Option: ' option_type(q)'' num2str(strike_price(q)) ]); xlabel('Time'); ylabel('Option Price');
            legend('Estimated', 'True price');
            
%     figure; scatter(opt, option_price(quarter+1:end,q)); title('Approximations');
end


%% 2. A Random set of 30 days
rs      = getRandomSet(30, quarter+1, N);
random_stock    = zeros(30,m);
random_option   = random_stock;

for q = 1: m
    random_stock(:, q) = (stock_price(rs, q));
    random_option(:,q) = (option_price(rs, q));
end

%% % implied volatility

ImpVol = zeros(30,m);
counter = 0;
for q = 1: m
    for t       = 1:length(rs)
        day     = rs(t);
        time    = (T - day)/tau; %0.25;
        Price   = random_stock(t,q);
        if(option_type(q) == 'c')
            Klass = {'Call'};
            Value = Call(day-quarter,q);
        else
            Klass = {'Put'};
            Value = Put(day-quarter,abs(q-5));
        end
        Value = random_option(t,q);
        % Estimate Implied Volatility
        ImpVol(t,q) = blsimpv(Price, strike_price(q), Rate, time, Value, Limit, 0, [], Klass);
        
        
        if isnan(ImpVol(t,q))
            counter = counter + 1;
            fprintf('%d %s day(%d)-> %.4f : (%.1f, %.1f, %.1f, %.4f \n',counter, Klass{1}, rs(t),ImpVol(t,q), Price, strike_price(q), Value, time);
        end
    end
end

%% implied volatility vs volatility plot
for q = 1:5
    opt = Call(:,q);
    figure; scatter(ImpVol(:,q), volatility(rs-(quarter+1),q));
     title('Implied Volatility '); xlabel('Impled volatility'); ylabel('Historical Volatility');
     title([ 'Call Option: ' option_type(q)'' num2str(strike_price(q)) ]);
end
for q = 1:5
    opt = Put(:,q);
    figure; scatter(ImpVol(:,q+5), volatility(rs-(quarter+1),q));
     title('Implied Volatility '); xlabel('Impled volatility'); ylabel('Historical Volatility');
     title([ 'Put Option: ' option_type(q+5)'' num2str(strike_price(q)) ]);
end
% for q = 1: m   
%     if(option_type(q)=='c')
%         opt = Call(:,q);
%         label = 'Call';
%     else
%         opt = Put(:,q-5);
%         label = 'Put';
%     end
%     figure; scatter(ImpVol(:,q), volatility(rs-quarter,q));
%             title('Implied Volatility '); xlabel('Impled volatility'); ylabel('Historical Volatility');
%             title([label ' Option: ' option_type(q)'' num2str(strike_price(q)) ]);
% %     legend('Implied Volatility', 'Historical Volatility');
% end


%% At different strike prices (Volatility smile)
% Choose a day

a_day       = 111; round((200-round(N/4)).*rand() + round(N/4));  % getRandomSet(1, round(N/4), N) % a_day = 100; %187 150; 85 for both
a_time      = 0.28; (T - a_day)/tau;  % a_time = 0.25;
a_price     = stock_price(a_day,4);
a_option    = option_price(a_day,4);

% strike_p    = strike_price(1:5);
% a_option    = Call(a_day-quarter, 4);
% a_option = [Call(a_day-quarter, 1:5) Put(a_day-quarter, 1:5)];
% a_option    = option_price(a_day,:);
% a_strike    = 2075:50:2525;
% b_option    = zeros(1,5);
% a_price     = stock_price(a_day,:);
% b_option(1:5)= option_price(a_day,1);
% % a_option = [Call(a_day-quarter, 1:5) Put(a_day-quarter, 1:5)];
% call_impVol = blsimpv(a_price, a_strike, Rate, a_time, a_option, Limit, 0, [], {'Call'});
% put_impVol  = blsimpv(a_price, a_strike, Rate, a_time, a_option, Limit, 0, [], {'Put'} );
% 
% figure; plot(a_strike, call_impVol, 'b');% hold; scatter(a_strike, call_impVol); hold off;
% xlabel('Strike price '); ylabel('Impled volatility'); title('Call Option Volatility Smile ');
% 
% figure; plot(a_strike, put_impVol, 'b'); % hold; scatter(a_strike, put_impVol); hold off;
% xlabel('Strike price '); ylabel('Impled volatility'); title('Put Option Volatility Smile ');

strike_p = 225:100:4025;
for i = 1:length(strike_p)
    % True price
    c_option    = option_price(a_day,4);
    p_option    = option_price(a_day,9);
    % Black-Scholes price 
    c_option    = Call(a_day-quarter,4);
    p_option    = Put(a_day-quarter,4);
    
    call_impVolt(i) = blsimpv(a_price, strike_p(i), Rate, a_time, c_option, Limit, 0, [], {'Call'});
    put_impVolt(i)  = blsimpv(a_price, strike_p(i), Rate, a_time, p_option, Limit, 0, [], {'Put'} );
end

figure; subplot(1,2,1); plot(strike_p, call_impVolt, 'b');
% xlabel('Strike price '); ylabel('Impled volatility'); 
    title('Call Option Volatility Smile ');
    subplot(1,2,2); plot(strike_p, put_impVolt, 'b'); % hold; scatter(a_strike, put_impVol); hold off;
xlabel('Strike price '); ylabel('Impled volatility'); title('Put Option Volatility Smile ');
%% 4 Binomial Lattice
close all;
k       = 171; %round(100 * rand() + 1);    % a random day
h       = 3; %round(5 * rand()+1);        % random column for strike price
a_time  = (T - k)/tau;      % a_time = 0.25;
price   = stock_price(k,3);
strike  = strike_price(h);
value   = option_price(k,h);

imp_vol         = blsimpv (price, strike, Rate, a_time, value);
% [nCall, nPut]   = blsprice(price, strike, Rate , a_time, imp_vol);

NN = 100:100:10000;
TT = 0.52;
absDiff = zeros(length(NN), 1);
for i = 1:length(NN)
    [nPr(i), L, dt(i)]  = LatticeEurCall(price, strike, Rate, TT, imp_vol, i);  % Binomial Lattice
    [nCall(i), nPut(i)] = blsprice(price, strike, Rate , TT, imp_vol);  % Black-Scholes
    absDiff(i) = abs(nCall(i) - nPr(i));
%     dt(i) = TT/i;
end
figure; 
    plot(dt, absDiff); xlabel('time step'); ylabel('Absolute difference');
    title('Approximation of Binomial Lattice Method to Black-Scholes');
    
figure; 
    plot(NN, absDiff); xlabel('Number of iterations'); ylabel('Absolute difference');
    title('Approximation of Binomial Lattice Method to Black-Scholes');
    
figure; 
    plot(NN, nPr); hold on; plot(NN, nCall);  
    legend('Binomial Lattice','Black-Scholes'); 
    xlabel('Number of time steps'); ylabel('Value of Option');
    title('Approximation of Binomial Lattice Method to Black-Scholes');
    
    
    
    
    
    
    
    
    
    
    
    
% LP = zeros(length(NN),1)';
% LP(1:end) = nCall;
% figure; plot(NN, LP); hold on; plot(NN, Pr); xlabel('delta'); ylabel('Price');
% title('Approximation of Binomial Lattice Method to Black-Scholes');
% 

%        
% delta   = 0.01:0.01:0.2;
% abs_diff = zeros(length(delta), 1);
% for i = 1:length(delta)
%     [StockPrice, OptionPrice] = binprice(price, strike, Rate, a_time, delta(i),  imp_vol, 1);
%     abs_diff(i) = abs(nCall - OptionPrice(1,1));
% end
% figure; plot(delta, abs_diff); xlabel('delta'); ylabel('Absolute difference');
% title('Approximation of Binomial Lattice Method to Black-Scholes')


% for delta =0.01:0.01:0.2
%     i=i+1;
%     [StockPrice, OptionPrice] = binprice(market_price(k,1), strike_price(h), Rate, time, delta,  implied_volatility(h), 1);
%     abs_diff(i) = abs(OptionPrice(1,1) - Call_b);
%     fprintf('%.2f => Call = %.4f and Binomial = %.4f and Difference = %.4f  \n',delta,  Call_b, OptionPrice(1,1), abs_diff(i))
% end




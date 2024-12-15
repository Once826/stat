% Read data from CSV files
SP500 = readtable('SP500.csv');
DAX = readtable('DAX.csv');
FTSE100 = readtable('FTSE100.csv');

USD_GBP = readtable('USD_GBP.csv');
USD_EUR = readtable('USD_EUR.csv');

% Convert dates to datetime format
SP500.Date = datetime(SP500.Date, 'InputFormat', 'dd/MM/uuuu');
DAX.Date = datetime(DAX.Date, 'InputFormat', 'dd/MM/uuuu');
FTSE100.Date = datetime(FTSE100.Date, 'InputFormat', 'dd/MM/uuuu');

USD_GBP.Date = datetime(USD_GBP.Date, 'InputFormat', 'dd/MM/uuuu');
USD_EUR.Date = datetime(USD_EUR.Date, 'InputFormat', 'dd/MM/uuuu');

% Retain only necessary columns and fix price formatting
SP500.Price = str2double(regexprep(SP500.Price, ',', ''));
DAX.Price = str2double(regexprep(DAX.Price, ',', ''));
FTSE100.Price = str2double(regexprep(FTSE100.Price, ',', ''));

SP500.Open = str2double(regexprep(SP500.Open, ',', ''));
DAX.Open = str2double(regexprep(DAX.Open, ',', ''));
FTSE100.Open = str2double(regexprep(FTSE100.Open, ',', ''));

SP500.High = str2double(regexprep(SP500.High, ',', ''));
DAX.High = str2double(regexprep(DAX.High, ',', ''));
FTSE100.High = str2double(regexprep(FTSE100.High, ',', ''));

SP500.Low = str2double(regexprep(SP500.Low, ',', ''));
DAX.Low = str2double(regexprep(DAX.Low, ',', ''));
FTSE100.Low = str2double(regexprep(FTSE100.Low, ',', ''));

SP500TT = table2timetable(SP500(:, {'Date', 'Price', 'Open', 'High', 'Low'}), 'RowTimes', 'Date');
DAXTT = table2timetable(DAX(:, {'Date', 'Price', 'Open', 'High', 'Low'}), 'RowTimes', 'Date');
FTSE100TT = table2timetable(FTSE100(:, {'Date', 'Price', 'Open', 'High', 'Low'}), 'RowTimes', 'Date');
USD_GBPTT = table2timetable(USD_GBP(:, {'Date', 'Price', 'Open', 'High', 'Low'}), 'RowTimes', 'Date');
USD_EURTT = table2timetable(USD_EUR(:, {'Date', 'Price', 'Open', 'High', 'Low'}), 'RowTimes', 'Date');

% Rename 'Price' to 'Close'
SP500TT = renamevars(SP500TT, 'Price', 'Close');
DAXTT = renamevars(DAXTT, 'Price', 'Close');
FTSE100TT = renamevars(FTSE100TT, 'Price', 'Close');
USD_GBPTT = renamevars(USD_GBPTT, 'Price', 'Close');
USD_EURTT = renamevars(USD_EURTT, 'Price', 'Close');


% % Plot candlestick charts for indices
figure;
plotCandlestick(SP500TT, 'S&P 500');

figure;
plotCandlestick(DAXTT, 'DAX');

figure;
plotCandlestick(FTSE100TT, 'FTSE 100');

% Synchronize datasets into a single timetable
combinedData = synchronize(SP500TT, DAXTT, FTSE100TT, USD_GBPTT, USD_EURTT, 'union', 'linear');

% Calculate ratios
combinedData.SP500_FTSE_Ratio = combinedData.Close_SP500TT ./ combinedData.Close_FTSE100TT;
combinedData.SP500_DAX_Ratio = combinedData.Close_SP500TT ./ combinedData.Close_DAXTT;

% Plot S&P 500 / FTSE 100 Ratio vs USD/GBP Exchange Rate
figure;
yyaxis left;
plot(combinedData.Date, combinedData.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combinedData.Date, combinedData.Close_USD_GBPTT, '-r');
ylabel('USD/GBP Exchange Rate');
title('S&P 500 / FTSE 100 Ratio vs. USD/GBP Rate');
xlabel('Date');
grid on;

% Correlation
corr_SP500_FTSE_USD_GBP = corr(combinedData.SP500_FTSE_Ratio, combinedData.Close_USD_GBPTT, 'Rows', 'complete');
disp(['Correlation between S&P 500 / FTSE 100 Ratio and USD/GBP: ', num2str(corr_SP500_FTSE_USD_GBP)]);

% Plot S&P 500 / DAX Ratio vs USD/EUR Exchange Rate
figure;
yyaxis left;
plot(combinedData.Date, combinedData.SP500_DAX_Ratio, '-b');
ylabel('S&P 500 / DAX Ratio');
yyaxis right;
plot(combinedData.Date, combinedData.Close_USD_EURTT, '-r');
ylabel('USD/EUR Exchange Rate');
title('S&P 500 / DAX Ratio vs. USD/EUR Rate');
xlabel('Date');
grid on;

% Correlation
corr_SP500_DAX_USD_EUR = corr(combinedData.SP500_DAX_Ratio, combinedData.Close_USD_EURTT, 'Rows', 'complete');
disp(['Correlation between S&P 500 / DAX Ratio and USD/EUR: ', num2str(corr_SP500_DAX_USD_EUR)]);

%% Pre-crash Period Analysis
% Define the end date for the pre-crash period
preCrashEndDate = datetime('2007-12-31');

% Filter data for the pre-crash period
SP500_PreCrash = SP500TT(SP500TT.Date <= preCrashEndDate, :);
DAX_PreCrash = DAXTT(DAXTT.Date <= preCrashEndDate, :);
FTSE100_PreCrash = FTSE100TT(FTSE100TT.Date <= preCrashEndDate, :);
USD_GBP_PreCrash = USD_GBPTT(USD_GBPTT.Date <= preCrashEndDate, :);
USD_EUR_PreCrash = USD_EURTT(USD_EURTT.Date <= preCrashEndDate, :);

% Synchronize data for pre-crash period
combined_PreCrash = synchronize(SP500_PreCrash, DAX_PreCrash, FTSE100_PreCrash, USD_GBP_PreCrash, USD_EUR_PreCrash, 'union', 'linear');

% Calculate ratios
combined_PreCrash.SP500_FTSE_Ratio = combined_PreCrash.Close_SP500_PreCrash ./ combined_PreCrash.Close_FTSE100_PreCrash;
combined_PreCrash.SP500_DAX_Ratio = combined_PreCrash.Close_SP500_PreCrash ./ combined_PreCrash.Close_DAX_PreCrash;

% Descriptive Statistics
mean_SP500 = mean(combined_PreCrash.Close_SP500_PreCrash, 'omitnan');
mean_DAX = mean(combined_PreCrash.Close_DAX_PreCrash, 'omitnan');
mean_FTSE = mean(combined_PreCrash.Close_FTSE100_PreCrash, 'omitnan');
corr_SP500_FTSE = corr(combined_PreCrash.SP500_FTSE_Ratio, combined_PreCrash.Close_USD_GBP_PreCrash, 'Rows', 'complete');
corr_SP500_DAX = corr(combined_PreCrash.SP500_DAX_Ratio, combined_PreCrash.Close_USD_EUR_PreCrash, 'Rows', 'complete');

disp(['Mean S&P 500 (Pre-Crash): ', num2str(mean_SP500)]);
disp(['Mean DAX (Pre-Crash): ', num2str(mean_DAX)]);
disp(['Mean FTSE 100 (Pre-Crash): ', num2str(mean_FTSE)]);
disp(['Correlation (S&P 500 / FTSE 100 Ratio vs USD/GBP): ', num2str(corr_SP500_FTSE)]);
disp(['Correlation (S&P 500 / DAX Ratio vs USD/EUR): ', num2str(corr_SP500_DAX)]);

% Plot pre-crash ratios and exchange rates
figure;
subplot(2, 1, 1);
yyaxis left;
plot(combined_PreCrash.Date, combined_PreCrash.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combined_PreCrash.Date, combined_PreCrash.Close_USD_GBP_PreCrash, '-r');
ylabel('USD/GBP Exchange Rate');
title('Pre-Crash: S&P 500 / FTSE 100 Ratio vs USD/GBP Rate');
xlabel('Date');
grid on;

subplot(2, 1, 2);
yyaxis left;
plot(combined_PreCrash.Date, combined_PreCrash.SP500_DAX_Ratio, '-b');
ylabel('S&P 500 / DAX Ratio');
yyaxis right;
plot(combined_PreCrash.Date, combined_PreCrash.Close_USD_EUR_PreCrash, '-r');
ylabel('USD/EUR Exchange Rate');
title('Pre-Crash: S&P 500 / DAX Ratio vs USD/EUR Rate');
xlabel('Date');
grid on;

%% Crash Period Analysis
% Define the start and end dates for the crash period
crashStartDate = datetime('2008-01-01');
crashEndDate = datetime('2009-12-31');

% Filter data for the crash period
SP500_Crash = SP500TT((SP500TT.Date >= crashStartDate) & (SP500TT.Date <= crashEndDate), :);
DAX_Crash = DAXTT((DAXTT.Date >= crashStartDate) & (DAXTT.Date <= crashEndDate), :);
FTSE100_Crash = FTSE100TT((FTSE100TT.Date >= crashStartDate) & (FTSE100TT.Date <= crashEndDate), :);
USD_GBP_Crash = USD_GBPTT((USD_GBPTT.Date >= crashStartDate) & (USD_GBPTT.Date <= crashEndDate), :);
USD_EUR_Crash = USD_EURTT((USD_EURTT.Date >= crashStartDate) & (USD_EURTT.Date <= crashEndDate), :);

% Synchronize data for the crash period
combined_Crash = synchronize(SP500_Crash, DAX_Crash, FTSE100_Crash, USD_GBP_Crash, USD_EUR_Crash, 'union', 'linear');

% Calculate ratios
combined_Crash.SP500_FTSE_Ratio = combined_Crash.Close_SP500_Crash ./ combined_Crash.Close_FTSE100_Crash;
combined_Crash.SP500_DAX_Ratio = combined_Crash.Close_SP500_Crash ./ combined_Crash.Close_DAX_Crash;

% Descriptive Statistics
mean_SP500_Crash = mean(combined_Crash.Close_SP500_Crash, 'omitnan');
mean_DAX_Crash = mean(combined_Crash.Close_DAX_Crash, 'omitnan');
mean_FTSE_Crash = mean(combined_Crash.Close_FTSE100_Crash, 'omitnan');
corr_SP500_FTSE_Crash = corr(combined_Crash.SP500_FTSE_Ratio, combined_Crash.Close_USD_GBP_Crash, 'Rows', 'complete');
corr_SP500_DAX_Crash = corr(combined_Crash.SP500_DAX_Ratio, combined_Crash.Close_USD_EUR_Crash, 'Rows', 'complete');

disp(['Mean S&P 500 (Crash): ', num2str(mean_SP500_Crash)]);
disp(['Mean DAX (Crash): ', num2str(mean_DAX_Crash)]);
disp(['Mean FTSE 100 (Crash): ', num2str(mean_FTSE_Crash)]);
disp(['Correlation (S&P 500 / FTSE 100 Ratio vs USD/GBP): ', num2str(corr_SP500_FTSE_Crash)]);
disp(['Correlation (S&P 500 / DAX Ratio vs USD/EUR): ', num2str(corr_SP500_DAX_Crash)]);

% Plot crash ratios and exchange rates
figure;
subplot(2, 1, 1);
yyaxis left;
plot(combined_Crash.Date, combined_Crash.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combined_Crash.Date, combined_Crash.Close_USD_GBP_Crash, '-r');
ylabel('USD/GBP Exchange Rate');
title('Crash: S&P 500 / FTSE 100 Ratio vs USD/GBP Rate');
xlabel('Date');
grid on;

subplot(2, 1, 2);
yyaxis left;
plot(combined_Crash.Date, combined_Crash.SP500_DAX_Ratio, '-b');
ylabel('S&P 500 / DAX Ratio');
yyaxis right;
plot(combined_Crash.Date, combined_Crash.Close_USD_EUR_Crash, '-r');
ylabel('USD/EUR Exchange Rate');
title('Crash: S&P 500 / DAX Ratio vs USD/EUR Rate');
xlabel('Date');
grid on;

%% Recovery Period Analysis
% --- Define time periods ---
recoveryStartDate = datetime('2010-01-01');
recoveryEndDate = datetime('2019-12-31');


% Filter data for the recovery period
SP500_Recovery = SP500TT((SP500TT.Date >= recoveryStartDate) & (SP500TT.Date <= recoveryEndDate), :);
DAX_Recovery = DAXTT((DAXTT.Date >= recoveryStartDate) & (DAXTT.Date <= recoveryEndDate), :);
FTSE100_Recovery = FTSE100TT((FTSE100TT.Date >= recoveryStartDate) & (FTSE100TT.Date <= recoveryEndDate), :);
USD_GBP_Recovery = USD_GBPTT((USD_GBPTT.Date >= recoveryStartDate) & (USD_GBPTT.Date <= recoveryEndDate), :);
USD_EUR_Recovery = USD_EURTT((USD_EURTT.Date >= recoveryStartDate) & (USD_EURTT.Date <= recoveryEndDate), :);

% Synchronize data
combined_Recovery = synchronize(SP500_Recovery, DAX_Recovery, FTSE100_Recovery, USD_GBP_Recovery, USD_EUR_Recovery, 'union', 'linear');

% Calculate ratios
combined_Recovery.SP500_FTSE_Ratio = combined_Recovery.Close_SP500_Recovery ./ combined_Recovery.Close_FTSE100_Recovery;
combined_Recovery.SP500_DAX_Ratio = combined_Recovery.Close_SP500_Recovery ./ combined_Recovery.Close_DAX_Recovery;

% Descriptive statistics
mean_SP500_Recovery = mean(combined_Recovery.Close_SP500_Recovery, 'omitnan');
mean_DAX_Recovery = mean(combined_Recovery.Close_DAX_Recovery, 'omitnan');
mean_FTSE_Recovery = mean(combined_Recovery.Close_FTSE100_Recovery, 'omitnan');
corr_Recovery_FTSE = corr(combined_Recovery.SP500_FTSE_Ratio, combined_Recovery.Close_USD_GBP_Recovery, 'Rows', 'complete');

disp(['Mean S&P 500: ', num2str(mean_SP500_Recovery)]);
disp(['Mean DAX: ', num2str(mean_DAX_Recovery)]);
disp(['Mean FTSE 100: ', num2str(mean_FTSE_Recovery)]);
disp(['Correlation (S&P 500 / FTSE 100 Ratio vs USD/GBP): ', num2str(corr_Recovery_FTSE)]);

% Visualization
figure;
yyaxis left;
plot(combined_Recovery.Date, combined_Recovery.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combined_Recovery.Date, combined_Recovery.Close_USD_GBP_Recovery, '-r');
ylabel('USD/GBP Exchange Rate');
title('Recovery: S&P 500 / FTSE 100 Ratio vs USD/GBP');
xlabel('Date');
grid on;

%% COVID Period Analysis
% --- Define time periods ---
covidStartDate = datetime('2020-01-01');
covidEndDate = datetime('2021-12-31');

% Filter data for the COVID period
SP500_COVID = SP500TT((SP500TT.Date >= covidStartDate) & (SP500TT.Date <= covidEndDate), :);
DAX_COVID = DAXTT((DAXTT.Date >= covidStartDate) & (DAXTT.Date <= covidEndDate), :);
FTSE100_COVID = FTSE100TT((FTSE100TT.Date >= covidStartDate) & (FTSE100TT.Date <= covidEndDate), :);
USD_GBP_COVID = USD_GBPTT((USD_GBPTT.Date >= covidStartDate) & (USD_GBPTT.Date <= covidEndDate), :);
USD_EUR_COVID = USD_EURTT((USD_EURTT.Date >= covidStartDate) & (USD_EURTT.Date <= covidEndDate), :);

% Synchronize data
combined_COVID = synchronize(SP500_COVID, DAX_COVID, FTSE100_COVID, USD_GBP_COVID, USD_EUR_COVID, 'union', 'linear');

% Calculate ratios
combined_COVID.SP500_FTSE_Ratio = combined_COVID.Close_SP500_COVID ./ combined_COVID.Close_FTSE100_COVID;
combined_COVID.SP500_DAX_Ratio = combined_COVID.Close_SP500_COVID ./ combined_COVID.Close_DAX_COVID;

% Descriptive statistics
mean_SP500_COVID = mean(combined_COVID.Close_SP500_COVID, 'omitnan');
mean_DAX_COVID = mean(combined_COVID.Close_DAX_COVID, 'omitnan');
mean_FTSE_COVID = mean(combined_COVID.Close_FTSE100_COVID, 'omitnan');
corr_COVID_FTSE = corr(combined_COVID.SP500_FTSE_Ratio, combined_COVID.Close_USD_GBP_COVID, 'Rows', 'complete');

disp(['Mean S&P 500: ', num2str(mean_SP500_COVID)]);
disp(['Mean DAX: ', num2str(mean_DAX_COVID)]);
disp(['Mean FTSE 100: ', num2str(mean_FTSE_COVID)]);
disp(['Correlation (S&P 500 / FTSE 100 Ratio vs USD/GBP): ', num2str(corr_COVID_FTSE)]);

% Visualization
figure;
yyaxis left;
plot(combined_COVID.Date, combined_COVID.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combined_COVID.Date, combined_COVID.Close_USD_GBP_COVID, '-r');
ylabel('USD/GBP Exchange Rate');
title('COVID: S&P 500 / FTSE 100 Ratio vs USD/GBP');
xlabel('Date');
grid on;

%% Post-COVID Period Analysis
% --- Define time periods ---
postCovidStartDate = datetime('2022-01-01');

% Filter data for the post-COVID period
SP500_PostCOVID = SP500TT(SP500TT.Date >= postCovidStartDate, :);
DAX_PostCOVID = DAXTT(DAXTT.Date >= postCovidStartDate, :);
FTSE100_PostCOVID = FTSE100TT(FTSE100TT.Date >= postCovidStartDate, :);
USD_GBP_PostCOVID = USD_GBPTT(USD_GBPTT.Date >= postCovidStartDate, :);
USD_EUR_PostCOVID = USD_EURTT(USD_EURTT.Date >= postCovidStartDate, :);

% Synchronize data
combined_PostCOVID = synchronize(SP500_PostCOVID, DAX_PostCOVID, FTSE100_PostCOVID, USD_GBP_PostCOVID, USD_EUR_PostCOVID, 'union', 'linear');

% Calculate ratios
combined_PostCOVID.SP500_FTSE_Ratio = combined_PostCOVID.Close_SP500_PostCOVID ./ combined_PostCOVID.Close_FTSE100_PostCOVID;
combined_PostCOVID.SP500_DAX_Ratio = combined_PostCOVID.Close_SP500_PostCOVID ./ combined_PostCOVID.Close_DAX_PostCOVID;

% Descriptive statistics
mean_SP500_PostCOVID = mean(combined_PostCOVID.Close_SP500_PostCOVID, 'omitnan');
mean_DAX_PostCOVID = mean(combined_PostCOVID.Close_DAX_PostCOVID, 'omitnan');
mean_FTSE_PostCOVID = mean(combined_PostCOVID.Close_FTSE100_PostCOVID, 'omitnan');
corr_PostCOVID_FTSE = corr(combined_PostCOVID.SP500_FTSE_Ratio, combined_PostCOVID.Close_USD_GBP_PostCOVID, 'Rows', 'complete');

disp(['Mean S&P 500: ', num2str(mean_SP500_PostCOVID)]);
disp(['Mean DAX: ', num2str(mean_DAX_PostCOVID)]);
disp(['Mean FTSE 100: ', num2str(mean_FTSE_PostCOVID)]);
disp(['Correlation (S&P 500 / FTSE 100 Ratio vs USD/GBP): ', num2str(corr_PostCOVID_FTSE)]);

% Visualization
figure;
yyaxis left;
plot(combined_PostCOVID.Date, combined_PostCOVID.SP500_FTSE_Ratio, '-b');
ylabel('S&P 500 / FTSE 100 Ratio');
yyaxis right;
plot(combined_PostCOVID.Date, combined_PostCOVID.Close_USD_GBP_PostCOVID, '-r');
ylabel('USD/GBP Exchange Rate');
title('Post-COVID: S&P 500 / FTSE 100 Ratio vs USD/GBP');
xlabel('Date');
grid on;


% Helper function for candlestick plotting
function plotCandlestick(dataTT, titleStr)
    candle(dataTT);

    title(titleStr);
    xlabel('Time');
    ylabel('Price');
    grid on;
end

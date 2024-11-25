import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta

def get_stock_metrics(ticker_symbols, start_date=None, end_date=None, frequency='1d'):
    """
    Fetch historical stock prices and financial data for given stock tickers.
    
    Parameters:
    ticker_symbols (list): List of stock ticker symbols.
    start_date (str): Start date in 'YYYY-MM-DD' format (default: 1 year ago).
    end_date (str): End date in 'YYYY-MM-DD' format (default: today).
    frequency (str): Data frequency for historical prices ('1d', '1wk', '1mo', etc.).
    
    Returns:
    dict: Dictionary containing DataFrames with different data categories.
    """
    if not start_date:
        start_date = (datetime.now() - timedelta(days=365)).strftime('%Y-%m-%d')
    if not end_date:
        end_date = datetime.now().strftime('%Y-%m-%d')
    
    # Initialize results dictionary
    results = {
        'price_data': pd.DataFrame(),
        'financial_metrics': pd.DataFrame(),
        'income_statement': pd.DataFrame(),
        'balance_sheet': pd.DataFrame(),
        'cash_flow': pd.DataFrame()
    }
    
    for symbol in ticker_symbols:
        try:
            # Create Ticker object
            stock = yf.Ticker(symbol)
            
            # Fetch historical price data
            price_history = stock.history(start=start_date, end=end_date, interval=frequency)
            price_history = price_history.reset_index()  # Ensure the date is included as a column
            price_history['Date'] = price_history['Date'].dt.strftime('%Y-%m-%d')  # Format as 'YYYY-MM-DD'
            price_history['Symbol'] = symbol
            results['price_data'] = pd.concat([results['price_data'], price_history])
            
            # Fetch basic financial metrics
            info = stock.info
            financial_data = {
                'Symbol': symbol,
                'Date': datetime.now().strftime('%Y-%m-%d'),  # Add current date for metrics
                'Market Cap': info.get('marketCap'),
                'Enterprise Value': info.get('enterpriseValue'),
                'P/E Ratio': info.get('trailingPE'),
                'Forward P/E': info.get('forwardPE'),
                'EPS (TTM)': info.get('trailingEps'),
                'ROA': info.get('returnOnAssets'),
                'ROE': info.get('returnOnEquity'),
                'Revenue': info.get('totalRevenue'),
                'Profit Margin': info.get('profitMargins'),
                'Beta': info.get('beta'),
                'Dividend Yield': info.get('dividendYield')
            }
            results['financial_metrics'] = pd.concat([
                results['financial_metrics'], 
                pd.DataFrame([financial_data])
            ])
            
            # Fetch financial statements
            income_statement = stock.financials.T.reset_index()  # Reset index to get dates
            income_statement.rename(columns={'index': 'Date'}, inplace=True)
            income_statement['Symbol'] = symbol
            
            balance_sheet = stock.balance_sheet.T.reset_index()
            balance_sheet.rename(columns={'index': 'Date'}, inplace=True)
            balance_sheet['Symbol'] = symbol
            
            cash_flow = stock.cashflow.T.reset_index()
            cash_flow.rename(columns={'index': 'Date'}, inplace=True)
            cash_flow['Symbol'] = symbol
            
            # Add to results
            results['income_statement'] = pd.concat([results['income_statement'], income_statement])
            results['balance_sheet'] = pd.concat([results['balance_sheet'], balance_sheet])
            results['cash_flow'] = pd.concat([results['cash_flow'], cash_flow])
        
        except Exception as e:
            print(f"Error fetching data for {symbol}: {str(e)}")
    
    # Reset index for all DataFrames
    for key in results:
        results[key] = results[key].reset_index(drop=True)
    
    return results

def save_to_excel(results, filename='stock_analysis_with_dates.xlsx'):
    """
    Save all data to separate sheets in an Excel file.
    
    Parameters:
    results (dict): Dictionary of DataFrames containing different metrics.
    filename (str): Name of the output Excel file.
    """
    with pd.ExcelWriter(filename, engine='xlsxwriter') as writer:
        for sheet_name, df in results.items():
            # Create a copy to avoid modifying original data
            df_copy = df.copy()
            
            # Handle datetime columns - convert to naive UTC if timezone-aware
            for col in df_copy.columns:
                if pd.api.types.is_datetime64_any_dtype(df_copy[col]):
                    try:
                        if hasattr(df_copy[col].dt, 'tz'):
                            df_copy[col] = df_copy[col].dt.tz_convert('UTC').dt.tz_localize(None)
                    except Exception as e:
                        print(f"Warning: Could not process timezone for column {col}: {e}")
            
            # Write to Excel
            df_copy.to_excel(writer, sheet_name=sheet_name, index=False)

# Example usage
if __name__ == "__main__":
    # List of stock symbols to analyze
    symbols = ['HES','DVN','PBF','TOT.TO','OXY','PSX','COP','VLO','MPC','MUR','EOG','CPK','ED','EQT','MRO','VTLE','CVX','BP','SHEL','XOM']
    
    # Define date range and frequency
    start_date = '2000-01-01'
    end_date = '2023-12-31'
    frequency = '1d'  # Daily frequency
    
    # Fetch stock data and financial metrics
    results = get_stock_metrics(symbols, start_date=start_date, end_date=end_date, frequency=frequency)
    
    # Save to an Excel file
    save_to_excel(results, 'stock_analysis_with_dates.xlsx')

## needs pip install yfinance pandas xlsxwriter
import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta

def get_stock_metrics(ticker_symbols, start_date=None, end_date=None, frequency='1d'):
    """
    Fetch comprehensive financial metrics for given stock tickers with specified frequency.
    
    Parameters:
    ticker_symbols (list): List of stock ticker symbols
    start_date (str): Start date in 'YYYY-MM-DD' format (default: 1 year ago)
    end_date (str): End date in 'YYYY-MM-DD' format (default: today)
    frequency (str): Frequency of data collection (default: '1d')
    
    Returns:
    dict: Dictionary containing DataFrames with different metrics
    """
    if not start_date:
        start_date = (datetime.now() - timedelta(days=365)).strftime('%Y-%m-%d')
    if not end_date:
        end_date = datetime.now().strftime('%Y-%m-%d')
    
    results = {
        'price_data': pd.DataFrame(),
        'financial_metrics': pd.DataFrame(),
        'trading_info': pd.DataFrame()
    }
    
    for symbol in ticker_symbols:
        try:
            # Create Ticker object
            stock = yf.Ticker(symbol)
            
            # Get historical price data with specified frequency
            price_history = stock.history(start=start_date, end=end_date, interval=frequency)
            price_history['Symbol'] = symbol
            results['price_data'] = pd.concat([results['price_data'], price_history])
            
            # Get financial metrics
            info = stock.info
            financial_data = {
                'Symbol': symbol,
                'Market Cap': info.get('marketCap'),
                'Enterprise Value': info.get('enterpriseValue'),
                'P/E Ratio': info.get('trailingPE'),
                'Forward P/E': info.get('forwardPE'),
                'EPS (TTM)': info.get('trailingEps'),
                'ROA': info.get('returnOnAssets'),
                'ROE': info.get('returnOnEquity'),
                'Revenue': info.get('totalRevenue'),
                'Gross Profit': info.get('grossProfits'),
                'Profit Margin': info.get('profitMargins'),
                'Operating Margin': info.get('operatingMargins'),
                'Beta': info.get('beta'),
                'Dividend Yield': info.get('dividendYield')
            }
            results['financial_metrics'] = pd.concat([
                results['financial_metrics'], 
                pd.DataFrame([financial_data])
            ])
            
            # Get trading information
            trading_data = {
                'Symbol': symbol,
                'Volume': info.get('volume'),
                'Avg Volume': info.get('averageVolume'),
                'Avg Volume 10 days': info.get('averageVolume10days'),
                '52 Week High': info.get('fiftyTwoWeekHigh'),
                '52 Week Low': info.get('fiftyTwoWeekLow'),
                'Shares Outstanding': info.get('sharesOutstanding'),
                'Float Shares': info.get('floatShares')
            }
            results['trading_info'] = pd.concat([
                results['trading_info'], 
                pd.DataFrame([trading_data])
            ])
            
        except Exception as e:
            print(f"Error fetching data for {symbol}: {str(e)}")
    
    # Reset index for all DataFrames
    for key in results:
        results[key] = results[key].reset_index()
    
    return results

def save_to_excel(results, filename='stock_metrics.xlsx'):
    """
    Save all metrics to separate sheets in an Excel file
    
    Parameters:
    results (dict): Dictionary of DataFrames containing different metrics
    filename (str): Name of the output Excel file
    """
    with pd.ExcelWriter(filename, engine='xlsxwriter') as writer:
        for sheet_name, df in results.items():
            # Create a copy to avoid modifying original data
            df_copy = df.copy()
            
            # Handle datetime columns - check for both types of datetime columns
            for col in df_copy.columns:
                if pd.api.types.is_datetime64_any_dtype(df_copy[col]):
                    try:
                        # Convert timezone-aware to naive
                        if hasattr(df_copy[col].dt, 'tz'):
                            df_copy[col] = df_copy[col].dt.tz_convert('UTC').dt.tz_localize(None)
                    except (AttributeError, TypeError) as e:
                        print(f"Warning: Could not process timezone for column {col}: {e}")
                        continue
            
            # Write to Excel
            df_copy.to_excel(writer, sheet_name=sheet_name, index=False)
            dir
            
if __name__ == "__main__":
    # List of stock symbols to analyze
    symbols = ['AAPL', 'MSFT', 'GOOGL']
    
    # Define the start and end dates
    start_date = '2010-01-01'
    end_date = '2024-08-31'
    
    # Get the data with specified start and end dates
    results = get_stock_metrics(symbols, start_date=start_date, end_date=end_date, frequency='1d')
    
    # Save to Excel
    save_to_excel(results, 'stock_analysis_custom_dates.xlsx')

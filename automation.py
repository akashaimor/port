import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime

CITY = "Thiruvananthapuram"

# --- Put your actual keys directly inside the quotes ---
WEATHER_KEY = "7b2f5a369c03d9c23b48056ea922b561"
NEWS_KEY = "598d533ec1c947018559bed460a5eba5" 

EMAIL_SENDER = "akashgirasha@gmail.com"
EMAIL_PASSWORD = "kdhp lmjf fyne pygo"  # Replace this if you generate a new one!
EMAIL_RECEIVER = "akashgirasha@gmail.com"


def check_weather():
    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={WEATHER_KEY}&units=metric"
    response = requests.get(url)
    data = response.json()
    
    if response.status_code != 200:
        print("❌ OpenWeatherMap Error Response:", data)
        return ""
        
    temp = data['main']['temp']
    condition = data['weather'][0]['main'].lower()
    
    if temp > 35 or "rain" in condition:
        return f"⚠️ Weather Alert for {CITY}: {temp}°C with {condition}."
    return ""


def get_news_html():
    url = f"https://newsapi.org/v2/top-headlines?category=technology&language=en&apiKey={NEWS_KEY}"
    response = requests.get(url)
    data = response.json()
    
    if response.status_code != 200:
        print("❌ NewsAPI Error Response:", data)
        return "<h3>📰 Top Tech Headlines</h3><p>Could not fetch news.</p>"
        
    articles = data.get('articles', [])[:5] 
    
    html = "<h3>📰 Top Tech Headlines</h3><ul>"
    for art in articles:
        # Avoid crashes if publishedAt is missing
        published_at = art.get('publishedAt', '')
        time_str = published_at[11:16] if len(published_at) > 16 else "00:00"
        
        html += f"<li><a href='{art.get('url')}'>{art.get('title')}</a> [{time_str}]</li>"
    html += "</ul>"
    return html


def send_email():
    alert = check_weather()
    news_content = get_news_html()
    
    msg = MIMEMultipart('alternative')
    msg['Subject'] = f"Daily Briefing - {datetime.now().strftime('%d %b')}"
    msg['From'] = EMAIL_SENDER
    msg['To'] = EMAIL_RECEIVER
    
    alert_style = f"<p style='color:red; font-weight:bold;'>{alert}</p><hr>" if alert else ""
    body = f"<html><body>{alert_style}{news_content}</body></html>"
    msg.attach(MIMEText(body, 'html'))
    
    print("⏳ Connecting to Gmail server...")
    try:
        with smtplib.SMTP('smtp.gmail.com', 587) as server:
            server.starttls()
            server.login(EMAIL_SENDER, EMAIL_PASSWORD)
            print("🚀 Dispatching email payload...")
            server.sendmail(EMAIL_SENDER, EMAIL_RECEIVER, msg.as_string())
            print("✅ Success! Check your inbox.")
    except Exception as e:
        print(f"❌ Error occurred: {e}")

if __name__ == "__main__":
    send_email()
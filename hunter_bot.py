import requests
import time
from supabase import create_client

# 1. YOUR WAREHOUSE (SUPABASE) CREDENTIALS
# Use these exact keys from your project
SUPABASE_URL = "https://pkstzxkoyzcrlsybaums.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrc3R6eGtveXpjcmxzeWJhdW1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNjY2MTEsImV4cCI6MjA5MjY0MjYxMX0.-MZufmWstt8VkUW7hiplX1tTANVtLa99FjGECntg0ug" 
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def ghost_hunt():
    # These match your main.dart categories exactly
    categories = ["memes", "wholesomememes", "historymemes", "sciencememes"]
    
    # We pretend to be a real Windows Chrome browser to avoid Error 403
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Accept': 'application/json'
    }

    for cat in categories:
        print(f"--- Ghost Hunting in r/{cat} ---")
        
        # We add a 2-second sleep so Reddit doesn't think we are a fast bot
        time.sleep(2) 

        url = f"https://www.reddit.com/r/{cat}/hot.json?limit=10"
        try:
            response = requests.get(url, headers=headers)
            
            if response.status_code == 200:
                posts = response.json()['data']['children']
                for post in posts:
                    data = post['data']
                    img_url = data.get('url', '')
                    
                    # IMPORTANT: Only grab direct image files (.jpg, .png)
                    # This prevents the 'Meme is shy' error in Flutter!
                    if img_url.lower().endswith(('jpg', 'png', 'jpeg')):
                        
                        # Check if we already have this meme in the warehouse
                        check = supabase.table("memes").select("url").eq("url", img_url).execute()
                        
                        if not check.data:
                            meme_entry = {
                                "title": data['title'],
                                "url": img_url,
                                "ups": data['ups'],
                                "category": cat
                            }
                            supabase.table("memes").insert(meme_entry).execute()
                            print(f"✅ Stored: {data['title'][:30]}...")
                            break # Found the top image, move to next category
            else:
                print(f"❌ Error {response.status_code} reaching r/{cat}")
        except Exception as e:
            print(f"❌ Failed to connect: {e}")

if __name__ == "__main__":
    print("Starting the hunt...")
    ghost_hunt()
    print("Hunt complete! Warehouse is stocked.")

from datetime import datetime, timedelta, timezone

def clean_warehouse():
    print("--- Cleaning the Warehouse ---")
    # 1. Calculate the 'cutoff' time (e.g., memes older than 1 day)
    cutoff = datetime.now(timezone.utc) - timedelta(days=1)
    
    # 2. Tell Supabase to delete anything older than that
    try:
        response = supabase.table("memes").delete().lt("created_at", cutoff.isoformat()).execute()
        print(f"🧹 Janitor: Removed old memes.")
    except Exception as e:
        print(f"⚠️ Janitor was sleepy: {e}")

# Update your main block to include the cleanup
if __name__ == "__main__":
    clean_warehouse() # Clean first
    ghost_hunt()      # Then hunt
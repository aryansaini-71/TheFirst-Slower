import requests
import time
from supabase import create_client

# 1. YOUR WAREHOUSE (SUPABASE) CREDENTIALS
# Use these exact keys from your project
SUPABASE_URL = "https://pkstzxkoyzcrlsybaums.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrc3R6eGtveXpjcmxzeWJhdW1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNjY2MTEsImV4cCI6MjA5MjY0MjYxMX0.-MZufmWstt8VkUW7hiplX1tTANVtLa99FjGECntg0ug" 
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def ghost_hunt():
    categories = ["memes", "wholesomememes", "historymemes", "sciencememes"]
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Accept': 'application/json'
    }

    for cat in categories:
        print(f"--- Hunting in r/{cat} ---")
        # Increase limit to 25 to find more potential images
        url = f"https://www.reddit.com/r/{cat}/hot.json?limit=25"
        
        try:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                posts = response.json()['data']['children']
                count = 0
                for post in posts:
                    data = post['data']
                    img_url = data.get('url', '')

                    if img_url.lower().endswith(('jpg', 'png', 'jpeg')):
                        # Check for duplicates
                        check = supabase.table("memes").select("url").eq("url", img_url).execute()
                        
                        if not check.data:
                            supabase.table("memes").insert({
                                "title": data['title'],
                                "url": img_url,
                                "ups": data['ups'],
                                "category": cat
                            }).execute()
                            count += 1
                            print(f"✅ [{count}/10] Stored: {data['title'][:20]}...")
                    
                    # Stop after 10 memes per category
                    if count >= 10:
                        break
            time.sleep(2) # Be kind to Reddit's servers
        except Exception as e:
            print(f"❌ Error in r/{cat}: {e}")

if __name__ == "__main__":
    print("Starting the hunt...")
    ghost_hunt()
    print("Hunt complete! Warehouse is stocked.")

from datetime import datetime, timedelta, timezone

from datetime import datetime, timedelta, timezone

def clean_old_memes():
    print("--- 🧹 Cleaning the Warehouse ---")
    # Memes older than 24 hours are deleted
    time_threshold = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
    
    try:
        # Delete rows where created_at is less than 24 hours ago
        supabase.table("memes").delete().lt("created_at", time_threshold).execute()
        print("✅ Janitor: Old memes removed.")
    except Exception as e:
        print(f"⚠️ Janitor error: {e}")
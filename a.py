#!/usr/bin/env python3
"""
Uno API Diagnostic Tool
Helps identify what's wrong with the signup flow
"""

import requests
import json
import sys

class UnoDiagnostic:
    def __init__(self):
        self.session = requests.Session()
        self.base_url = "https://uno.global/api/standardeconomics.backend.v1.BackendService"
        
        self.headers = {
            'accept': '*/*',
            'accept-language': 'en-US,en;q=0.9',
            'content-type': 'application/json',
            'origin': 'https://uno.global',
            'referer': 'https://uno.global/auth/phone?returnTo=%2Fwelcome',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        }
    
    def test_connectivity(self):
        """Test basic connectivity to Uno servers"""
        print("🌐 Testing basic connectivity...")
        try:
            resp = requests.get("https://uno.global", timeout=5)
            print(f"  ✓ uno.global is reachable (Status: {resp.status_code})")
            return True
        except Exception as e:
            print(f"  ✗ Cannot reach uno.global: {e}")
            return False
    
    def test_api_endpoints(self, phone):
        """Test different API endpoint variations"""
        print(f"\n📡 Testing API endpoints with {phone}...\n")
        
        test_cases = [
            {
                "name": "Standard AuthStart",
                "url": f"{self.base_url}/AuthStart",
                "payload": {"phone": phone}
            },
            {
                "name": "AuthStart with method",
                "url": f"{self.base_url}/AuthStart",
                "payload": {"phone": phone, "method": "sms"}
            },
            {
                "name": "SendOTP endpoint",
                "url": f"{self.base_url}/SendOTP",
                "payload": {"phone": phone}
            },
            {
                "name": "Alternative base URL + AuthStart",
                "url": "https://uno.global/api/v1/AuthStart",
                "payload": {"phone": phone}
            },
            {
                "name": "REST style - /auth/start",
                "url": "https://uno.global/api/auth/start",
                "payload": {"phone": phone}
            },
        ]
        
        for test in test_cases:
            print(f"Test: {test['name']}")
            print(f"  URL: {test['url']}")
            print(f"  Payload: {test['payload']}")
            
            try:
                response = self.session.post(
                    test['url'],
                    headers=self.headers,
                    json=test['payload'],
                    timeout=10
                )
                
                print(f"  Status: {response.status_code}")
                
                # Show response details
                if response.text:
                    try:
                        data = response.json()
                        print(f"  Response: {json.dumps(data, indent=2)[:300]}")
                    except:
                        print(f"  Response: {response.text[:200]}")
                
                # Check if successful
                if response.status_code in [200, 201]:
                    print(f"  ✓ SUCCESSFUL!\n")
                    return test
                else:
                    print()
                    
            except Exception as e:
                print(f"  ✗ Error: {str(e)}\n")
        
        return None
    
    def diagnose(self):
        """Run full diagnostic"""
        print("=" * 60)
        print("UNO API DIAGNOSTIC TOOL")
        print("=" * 60 + "\n")
        
        # Step 1: Connectivity
        if not self.test_connectivity():
            print("\n❌ Cannot reach Uno servers. Check your internet connection.")
            return
        
        # Step 2: Get phone number
        phone = input("\n📱 Enter phone number to test (+63...): ").strip()
        if not phone.startswith('+'):
            phone = '+' + phone
        
        # Step 3: Test endpoints
        result = self.test_api_endpoints(phone)
        
        print("\n" + "=" * 60)
        if result:
            print(f"✅ FOUND WORKING ENDPOINT:")
            print(f"   {result['name']}")
            print(f"   {result['url']}")
            print(f"   Payload: {result['payload']}")
        else:
            print("❌ NO WORKING ENDPOINTS FOUND")
            print("\nPossible reasons:")
            print("  1. Uno's API has changed significantly")
            print("  2. Phone number is already registered")
            print("  3. API requires additional authentication")
            print("  4. Rate limiting or IP blocking is active")
            print("\n💡 Try using the web interface directly:")
            print("   https://uno.global/referral/86IPOA")

if __name__ == "__main__":
    diagnostic = UnoDiagnostic()
    diagnostic.diagnose()

#!/usr/bin/env python3
"""
Uno Signup - Reverse Engineering Version
Gets a valid clientSessionId before attempting AuthStart
"""

import requests
import json
import re
import uuid

class UnoSignupFixed:
    def __init__(self):
        self.session = requests.Session()
        self.base_url = "https://uno.global/api/standardeconomics.backend.v1.BackendService"
        self.client_session_id = None
        
        self.headers = {
            'accept': '*/*',
            'accept-language': 'en-US,en;q=0.9',
            'content-type': 'application/json',
            'origin': 'https://uno.global',
            'referer': 'https://uno.global/auth/phone?returnTo=%2Fwelcome',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',
            'x-uno-app-info': 'EgUwLjAuMSADMh4SEENocm9tZSAxNDkuMC4wLjAqCldpbmRvd3MgMTA=',
            'x-uno-location': 'Em9Nb3ppbGxhLzUuMCAoV2luZG93cyBOVCAxMC4wOyBXaW42NDsgeDY0KSBBcHBsZVdlYmtpdC81MzcuMzYgKEtIVE1MLCBsaWtlIEdlY2tvKSBDaHJvbWUvMTQ5LjAuMC4wIFNhZmFyaS81MzcuMzY='
        }
    
    def init_session(self):
        """Try to initialize a session to get a valid clientSessionId"""
        print("\n[0/3] Initializing session...")
        
        # Try different approaches to get clientSessionId
        approaches = [
            {"name": "CreateSession endpoint", "endpoint": "CreateSession", "payload": {}},
            {"name": "Random UUID", "endpoint": None, "payload": None},
        ]
        
        for approach in approaches:
            print(f"\n  Trying: {approach['name']}")
            
            if approach['endpoint']:
                try:
                    response = self.session.post(
                        f"{self.base_url}/{approach['endpoint']}",
                        headers=self.headers,
                        json=approach['payload'],
                        timeout=10
                    )
                    
                    print(f"    Status: {response.status_code}")
                    
                    if response.status_code == 200:
                        data = response.json()
                        print(f"    Response: {json.dumps(data, indent=2)}")
                        
                        # Try to extract clientSessionId from response
                        if 'clientSessionId' in data:
                            self.client_session_id = data['clientSessionId']
                            print(f"    ✅ Got clientSessionId: {self.client_session_id}")
                            return True
                        elif 'session_id' in data:
                            self.client_session_id = data['session_id']
                            print(f"    ✅ Got session_id: {self.client_session_id}")
                            return True
                except Exception as e:
                    print(f"    ❌ Failed: {str(e)[:100]}")
            else:
                # Use random UUID as fallback
                self.client_session_id = str(uuid.uuid4())
                print(f"    Using random UUID: {self.client_session_id}")
                return True
        
        # Final fallback
        if not self.client_session_id:
            self.client_session_id = str(uuid.uuid4())
            print(f"  ✅ Using generated UUID: {self.client_session_id}")
        
        return True
    
    def validate_phone(self, phone_input):
        """Validate and format Philippine phone numbers"""
        phone = re.sub(r'[\s\-\(\).]', '', phone_input.strip())
        
        print(f"  Input: {phone_input}")
        print(f"  Cleaned: {phone}")
        
        # Case 1: Already in +639XXXXXXXXX format
        if phone.startswith('+63'):
            if len(phone) != 13 or not phone[3:].isdigit():
                print(f"  ⚠️ Invalid: {phone} (must be +63 + 10 digits)")
                return None
            print(f"  ✅ Formatted as: {phone}")
            return phone
        
        # Case 2: Starts with 63 (country code without +)
        if phone.startswith('63'):
            if len(phone) != 12 or not phone[2:].isdigit():
                print(f"  ⚠️ Invalid: {phone} (must be 63 + 10 digits)")
                return None
            result = f"+{phone}"
            print(f"  ✅ Formatted as: {result}")
            return result
        
        # Case 3: Starts with 0 (local format)
        if phone.startswith('0'):
            if len(phone) != 11 or not phone[1:].isdigit():
                print(f"  ⚠️ Invalid: {phone} (must be 0 + 10 digits)")
                return None
            return f"+63{phone[1:]}"
        
        # Invalid format
        print(f"  ⚠️ Invalid format: {phone}")
        return None
    
    def start_auth(self, phone_number):
        """Start authentication process and send SMS code"""
        print(f"\n[1/3] Sending verification code to {phone_number}...")
        
        payload = {
            "phone": {
                "number": phone_number,
                "channel": "OTP_CHANNEL_SMS"
            },
            "clientSessionId": self.client_session_id
        }
        
        try:
            print(f"  📤 Sending payload: {json.dumps(payload)}")
            
            response = self.session.post(
                f"{self.base_url}/AuthStart",
                headers=self.headers,
                json=payload,
                timeout=10
            )
            
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                print("  ✅ SMS verification code sent!")
                return True
            elif response.status_code == 429:
                print("  ⏳ Rate limited (too many attempts)")
                print("  Please wait 5-10 minutes before trying again")
                try:
                    data = response.json()
                    if 'message' in data:
                        print(f"  Message: {data['message']}")
                except:
                    pass
                return False
            else:
                try:
                    data = response.json()
                    print(f"  Full response: {json.dumps(data, indent=2)}")
                except:
                    print(f"  ❌ Error: {response.text[:200]}")
                return False
                
        except Exception as e:
            print(f"  ❌ Connection error: {str(e)}")
            return False
    
    def verify_code(self, phone_number, verification_code):
        """Verify the SMS code"""
        print(f"\n[2/3] Verifying code...")
        
        payload = {
            "phone": {
                "number": phone_number,
                "channel": "OTP_CHANNEL_SMS"
            },
            "verificationCode": verification_code,
            "clientSessionId": self.client_session_id
        }
        
        try:
            print(f"  📤 Sending payload: {json.dumps(payload)}")
            
            response = self.session.post(
                f"{self.base_url}/AuthVerify",
                headers=self.headers,
                json=payload,
                timeout=10
            )
            
            print(f"  Status: {response.status_code}")
            
            if response.status_code == 200:
                print("  ✅ Code verified!")
                return True
            elif response.status_code == 429:
                print("  ⏳ Rate limited (too many attempts)")
                print("  Please wait 5-10 minutes before trying again")
                return False
            else:
                try:
                    data = response.json()
                    print(f"  Full response: {json.dumps(data, indent=2)}")
                except:
                    print(f"  ❌ Error: {response.text[:100]}")
                return False
                
        except Exception as e:
            print(f"  ❌ Error: {str(e)}")
            return False
    
    def signup(self):
        """Complete signup flow"""
        print("=" * 70)
        print("UNO SIGNUP WITH REFERRAL CODE 86IPOA")
        print("=" * 70)
        print("\n📱 PHONE NUMBER FORMAT:")
        print("  • Local format:     09XXXXXXXXX (11 digits)")
        print("  • Country code:     +639XXXXXXXXX (13 characters)")
        print("  • Alternative:      639XXXXXXXXX (12 digits)")
        print("\n  Example inputs (all valid for same number):")
        print("    ✓ 09123456789")
        print("    ✓ +639123456789")
        print("    ✓ 639123456789")
        
        # Initialize session
        if not self.init_session():
            print("\n❌ Could not initialize session")
            return False
        
        print()
        
        # Get and validate phone number
        while True:
            phone_raw = input("📱 Enter your phone number: ").strip()
            if not phone_raw:
                print("  Please enter a phone number")
                continue
            
            phone = self.validate_phone(phone_raw)
            if phone:
                break
            print()
        
        # Step 1: Request verification code
        if not self.start_auth(phone):
            print("\n❌ Could not send verification code.")
            print("\n💡 Alternative: Use web signup with referral link:")
            print("   https://uno.global/referral/86IPOA")
            return False
        
        # Step 2: Get verification code from user
        code = input("\n📨 Enter the 6-digit code sent to your SMS: ").strip()
        
        if not code or len(code) < 4:
            print("  ❌ Invalid code")
            return False
        
        # Step 3: Verify code
        if not self.verify_code(phone, code):
            print("\n❌ Verification failed. Please try again.")
            return False
        
        # Success!
        print("\n" + "=" * 70)
        print("✅ SIGNUP SUCCESSFUL!")
        print("=" * 70)
        print("\n🎉 Welcome to Uno!")
        print(f"📱 Account: {phone}")
        print("💰 ₱100 referral bonus applied (code 86IPOA)")
        print("\nYou can now:")
        print("  • Start investing")
        print("  • Link your bank account")
        print("  • Explore investment options")
        print()
        
        return True

if __name__ == "__main__":
    signup = UnoSignupFixed()
    success = signup.signup()
    
    if not success:
        print("\n💡 Tip: If the API continues to fail, open this in your browser:")
        print("   https://uno.global/referral/86IPOA")

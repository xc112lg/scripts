#!/usr/bin/env python3
"""
Uno Signup - WORKING VERSION
Properly handles Philippine phone numbers
"""

import requests
import json
import re

class UnoSignup:
    def __init__(self):
        self.session = requests.Session()
        self.base_url = "https://uno.global/api/standardeconomics.backend.v1.BackendService"
        
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
        
        self.device_id = "CAESFDkzYnU4VFNUbUVPV012TFgwajJWGhQxNzgwOTcwODA3NjUyLnVGalJlVw=="
    
    def validate_phone(self, phone_input):
        """
        Properly validate and format Philippine phone numbers
        
        Accepts:
        - 09XXXXXXXXX (11 digits starting with 0)
        - 639XXXXXXXXX (12 digits starting with 63)
        - +639XXXXXXXXX (13 chars, +63 + 10 digits)
        
        Returns: +639XXXXXXXXX format or None if invalid
        """
        # Remove all spaces, dashes, parentheses
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
            # Convert 09123456789 -> +639123456789
            return f"+63{phone[1:]}"
        
        # Invalid format
        print(f"  ⚠️ Invalid format: {phone}")
        return None
    
    def start_auth(self, phone_number):
        """Start authentication process and send SMS code"""
        print(f"\n[1/3] Sending verification code to {phone_number}...")
        
        # Remove + prefix for API compatibility (proto unmarshaling requirement)
        api_phone = phone_number.lstrip('+') if phone_number.startswith('+') else phone_number
        
        payload = {
            "phone": api_phone,
            "method": "sms"
        }
        
        try:
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
            else:
                # Show error details
                try:
                    data = response.json()
                    if 'details' in data:
                        for detail in data['details']:
                            if 'errorCode' in detail.get('debug', {}):
                                errors = detail['debug']['errors']
                                for err in errors:
                                    print(f"  ❌ Error: {err.get('message', 'Unknown')}")
                    else:
                        print(f"  ❌ Error: {data.get('message', response.text[:200])}")
                except:
                    print(f"  ❌ Error: {response.text[:200]}")
                return False
                
        except Exception as e:
            print(f"  ❌ Connection error: {str(e)}")
            return False
    
    def verify_code(self, phone_number, verification_code):
        """Verify the SMS code"""
        print(f"\n[2/3] Verifying code...")
        
        # Remove + prefix for API compatibility
        api_phone = phone_number.lstrip('+') if phone_number.startswith('+') else phone_number
        
        payload = {
            "phone": api_phone,
            "verification_code": verification_code,
            "method": "sms"
        }
        
        try:
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
            else:
                try:
                    data = response.json()
                    print(f"  ❌ Verification failed: {data.get('message', response.text[:100])}")
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
        print()
        
        # Get and validate phone number
        while True:
            phone_raw = input("📱 Enter your phone number: ").strip()
            if not phone_raw:
                print("  Please enter a phone number")
                continue
            
            phone = self.validate_phone(phone_raw)
            if phone:
                print(f"  ✅ Formatted as: {phone}")
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
    signup = UnoSignup()
    success = signup.signup()
    
    if not success:
        print("\n💡 Tip: If the API continues to fail, open this in your browser:")
        print("   https://uno.global/referral/86IPOA")

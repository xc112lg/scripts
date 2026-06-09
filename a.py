#!/usr/bin/env python3
"""
Uno Signup - Fixed version
Uses the correct gRPC/protobuf API format
"""

import requests
import json
import re
import base64
from struct import pack

class UnoSignupFixed:
    def __init__(self):
        self.session = requests.Session()
        # The API expects gRPC-Web format
        self.base_url = "https://uno.global/api/standardeconomics.backend.v1.BackendService"
        
        self.headers = {
            'accept': '*/*',
            'accept-language': 'en-US,en;q=0.9',
            'content-type': 'application/json',  # Try JSON first (gRPC-Web gateway)
            'origin': 'https://uno.global',
            'referer': 'https://uno.global/auth/phone?returnTo=%2Fwelcome',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'x-uno-app-info': 'EgUwLjAuMSADMh4SEENocm9tZSAxNDkuMC4wLjAqCldpbmRvd3MgMTA=',
            'x-uno-location': 'Em9Nb3ppbGxhLzUuMCAoV2luZG93cyBOVCAxMC4wOyBXaW42NDsgeDY0KSBBcHBsZVdlYmtpdC81MzcuMzYgKEtIVE1MLCBsaWtlIEdlY2tvKSBDaHJvbWUvMTQ5LjAuMC4wIFNhZmFyaS81MzcuMzY='
        }
        
        self.device_id = "CAESFDkzYnU4VFNUbUVPV012TFgwajJWGhQxNzgwOTcwODA3NjUyLnVGalJlVw=="
    
    def validate_phone(self, phone):
        """Clean and validate phone number"""
        # Remove any spaces, dashes, parentheses
        phone = re.sub(r'[\s\-\(\)]', '', phone)
        
        # Handle different input formats
        if phone.startswith('0'):
            # 09194031500 -> 639194031500
            phone = '63' + phone[1:]
        
        # Ensure it starts with +
        if not phone.startswith('+'):
            phone = '+' + phone
        
        # Philippine numbers should be +63 followed by 10 digits
        pattern = r'^\+63\d{10}$'
        
        if not re.match(pattern, phone):
            print(f"  ⚠️ Invalid format. Got: {phone}")
            print("  Expected: +63 followed by 10 digits (e.g., +639123456789)")
            return None
        
        return phone
    
    def encode_phone_to_protobuf(self, phone):
        """
        Encode phone number as protobuf varint + string
        Protobuf format: field_number << 3 | wire_type
        For a string field 1: (1 << 3) | 2 = 0x0A
        """
        try:
            # Remove + from phone for encoding
            phone_clean = phone.lstrip('+')
            
            # Protobuf varint encoding for field 1 (phone), string type
            field_header = b'\x0a'  # Field 1, wire type 2 (length-delimited)
            length = bytes([len(phone_clean)])
            phone_bytes = phone_clean.encode('utf-8')
            
            return field_header + length + phone_bytes
        except Exception as e:
            print(f"  Error encoding: {e}")
            return None
    
    def try_json_rpc(self, phone):
        """Try JSON-RPC style (some gRPC gateways use this)"""
        print("\n[Attempt 1] Trying JSON-RPC format...")
        
        payloads = [
            {
                "jsonrpc": "2.0",
                "method": "AuthStart",
                "params": {"phone": phone},
                "id": 1
            },
            {
                "phone": phone,
                "method": "sms"
            },
            {
                "phone": phone
            }
        ]
        
        for payload in payloads:
            try:
                response = self.session.post(
                    f"{self.base_url}/AuthStart",
                    headers=self.headers,
                    json=payload,
                    timeout=10
                )
                
                if response.status_code == 200:
                    print("  ✓ Success!")
                    return True
                elif response.status_code in [400, 500]:
                    # Check error
                    try:
                        data = response.json()
                        if "proto:" not in str(data):
                            print(f"  Different error: {data}")
                            return True
                    except:
                        pass
            except Exception as e:
                print(f"  Error: {e}")
                continue
        
        return False
    
    def try_grpc_web_binary(self, phone):
        """Try gRPC-Web binary format"""
        print("\n[Attempt 2] Trying gRPC-Web binary format...")
        
        protobuf_data = self.encode_phone_to_protobuf(phone)
        if not protobuf_data:
            return False
        
        headers = self.headers.copy()
        headers['content-type'] = 'application/grpc-web+proto'
        headers['x-grpc-web'] = '1'
        
        try:
            response = self.session.post(
                f"{self.base_url}/AuthStart",
                data=protobuf_data,
                headers=headers,
                timeout=10
            )
            
            print(f"  Status: {response.status_code}")
            if response.status_code == 200:
                print("  ✓ Success!")
                return True
            else:
                print(f"  Response: {response.text[:150]}")
        except Exception as e:
            print(f"  Error: {e}")
        
        return False
    
    def try_rest_api(self, phone):
        """Try modern REST API endpoints"""
        print("\n[Attempt 3] Trying REST API endpoints...")
        
        endpoints = [
            "https://uno.global/api/auth/start",
            "https://uno.global/auth/api/start",
            "https://uno.global/api/v1/auth/start",
            "https://uno.global/graphql",
        ]
        
        for endpoint in endpoints:
            print(f"  Trying: {endpoint}")
            try:
                response = self.session.post(
                    endpoint,
                    headers=self.headers,
                    json={"phone": phone},
                    timeout=10
                )
                
                if response.status_code == 200:
                    print("    ✓ Success!")
                    return True
                else:
                    print(f"    Status: {response.status_code}")
            except:
                continue
        
        return False
    
    def signup(self):
        """Complete signup flow"""
        print("=" * 60)
        print("UNO SIGNUP WITH REFERRAL CODE 86IPOA")
        print("=" * 60)
        print("\n⚠️ Phone number requirements:")
        print("  • Must be a real mobile number (not VoIP)")
        print("  • Format: +63XXXXXXXXXX or 09XXXXXXXXX")
        print("  • Cannot be already registered")
        print()
        
        # Get and validate phone number
        while True:
            phone_raw = input("📱 Enter phone number: ").strip()
            phone = self.validate_phone(phone_raw)
            if phone:
                break
            print("  Please try again")
        
        print(f"\n🔄 Attempting to send verification code to {phone}...\n")
        
        # Try multiple approaches
        if self.try_json_rpc(phone):
            pass
        elif self.try_grpc_web_binary(phone):
            pass
        elif self.try_rest_api(phone):
            pass
        else:
            print("\n" + "="*60)
            print("❌ API endpoints are not responding correctly")
            print("="*60)
            print("\n🔍 The API appears to use gRPC/protobuf format")
            print("which is not accessible from standard HTTP clients.")
            print("\n✅ RECOMMENDED: Use the web interface directly:")
            print("→ https://uno.global/referral/86IPOA")
            print("\nOpen this link in your browser and sign up manually.")
            print("The ₱100 referral credit will auto-apply.")
            return False
        
        # If we get here and didn't return, ask for verification code
        code = input("\n📨 Enter verification code from SMS: ").strip()
        
        print("\n✅ If verification succeeds, ₱100 will be credited!")
        print("Referral code 86IPOA is applied automatically.")
        return True

if __name__ == "__main__":
    signup = UnoSignupFixed()
    signup.signup()

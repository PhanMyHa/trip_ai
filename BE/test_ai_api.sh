#!/bin/bash

echo "Testing AI Recommendation API..."

# Step 1: Login
echo "Step 1: Getting auth token..."
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@trip.com","password":"123456"}' | \
  python -c "import sys, json; print(json.load(sys.stdin)['token'])")

if [ -z "$TOKEN" ]; then
  echo "Failed to get token"
  exit 1
fi

echo "Token obtained: ${TOKEN:0:20}..."

# Step 2: Call AI API
echo ""
echo "Step 2: Calling AI recommendation API..."
curl -X POST http://localhost:5000/api/ai/recommend-itinerary \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "destination": "Đà Lạt",
    "startDate": "2025-12-10",
    "endDate": "2025-12-12",
    "travelers": 2,
    "budget": "Trung bình",
    "interests": ["nature", "coffee"]
  }' | python -m json.tool

echo ""
echo "Test completed!"

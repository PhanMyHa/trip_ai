import sys
import json
import pickle
import pandas as pd
from pathlib import Path
import os

# Set UTF-8 encoding for stdout to handle emoji/unicode
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Suppress pandas warnings
import warnings
warnings.filterwarnings('ignore')

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.append(str(project_root))

from AI.train_model import TravelItineraryAI

def main():
    """Generate itinerary recommendation"""
    try:
        # Get arguments
        if len(sys.argv) < 4:
            raise ValueError("Missing required arguments: destination, days, user_profile")
        
        destination = sys.argv[1]
        days = int(sys.argv[2])
        user_profile = json.loads(sys.argv[3])
        
        # Redirect stderr to suppress emoji print statements
        original_stderr = sys.stderr
        sys.stderr = open(os.devnull, 'w', encoding='utf-8')
        
        # Load AI model
        ai = TravelItineraryAI()
        model_path = project_root / 'AI' / 'travel_ai_model.pkl'
        ai.load_model(str(model_path))
        
        # Generate recommendations
        itinerary = ai.recommend_services(
            destination=destination,
            user_profile=user_profile,
            num_days=days,
            services_per_day=4
        )
        
        # Restore stderr
        sys.stderr = original_stderr
        
        # Calculate total cost
        total_cost = sum(
            activity['price'] 
            for day in itinerary 
            for activity in day['activities']
        )
        
        # Output JSON
        result = {
            'itinerary': itinerary,
            'totalCost': int(total_cost)
        }
        
        print(json.dumps(result, ensure_ascii=False))
        
    except Exception as e:
        error_result = {
            'error': str(e),
            'itinerary': [],
            'totalCost': 0
        }
        print(json.dumps(error_result, ensure_ascii=False))
        sys.exit(1)

if __name__ == '__main__':
    main()

import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder
import json
import pickle
import re

class TravelItineraryAI:
    def __init__(self):
        self.services_df = None
        self.users_df = None
        self.bookings_df = None
        self.itineraries_df = None
        self.tfidf_vectorizer = TfidfVectorizer(max_features=100)
        self.label_encoders = {}
        self.service_features = None
        
    def load_data(self):
        """Load all CSV data"""
        print("📂 Loading data...")
        
        # Load services
        self.services_df = pd.read_csv('./BE/data/service.csv', sep=';', encoding='utf-8')
        print(f"✅ Loaded {len(self.services_df)} services")
        
        # Load users
        self.users_df = pd.read_csv('./BE/data/user.csv', sep=';', encoding='utf-8')
        print(f"✅ Loaded {len(self.users_df)} users")
        
        # Load bookings
        try:
            self.bookings_df = pd.read_csv('./BE/data/booking.csv', sep=';', encoding='utf-8')
            print(f"✅ Loaded {len(self.bookings_df)} bookings")
        except:
            self.bookings_df = pd.DataFrame()
            print("⚠️ No bookings data")
        
        # Load itineraries
        try:
            self.itineraries_df = pd.read_csv('./data/itinerary.csv', sep=';', encoding='utf-8')
            print(f"✅ Loaded {len(self.itineraries_df)} itineraries")
        except:
            self.itineraries_df = pd.DataFrame()
            print("⚠️ No itineraries data")
    
    def preprocess_services(self):
        """Preprocess service data for recommendation"""
        print("\n🔧 Preprocessing services...")
        
        # Extract location info
        def extract_city(location_str):
            try:
                if pd.notna(location_str) and location_str != 'undefined':
                    return json.loads(location_str).get('city', '')
            except:
                pass
            return ''
        
        self.services_df['city'] = self.services_df['location'].apply(extract_city)
        
        # Extract features
        def extract_features(features_str):
            try:
                if pd.notna(features_str) and features_str != 'undefined':
                    features_list = json.loads(features_str)
                    if isinstance(features_list, list):
                        return ' '.join(features_list)
            except:
                pass
            return ''
        
        self.services_df['features_text'] = self.services_df['features'].apply(extract_features)
        
        # Combine text features for TF-IDF
        self.services_df['combined_text'] = (
            self.services_df['title'].fillna('') + ' ' +
            self.services_df['description'].fillna('') + ' ' +
            self.services_df['features_text'].fillna('') + ' ' +
            self.services_df['category'].fillna('') + ' ' +
            self.services_df['city'].fillna('')
        )
        
        # Create TF-IDF features
        self.service_features = self.tfidf_vectorizer.fit_transform(
            self.services_df['combined_text']
        )
        
        print(f"✅ Created {self.service_features.shape[1]} TF-IDF features")
    
    def extract_user_preferences(self, user_profile):
        """Extract preferences from user profile"""
        preferences = {
            'budget': user_profile.get('budgetRange', 'Trung bình'),
            'interests': user_profile.get('interests', []),
            'people': user_profile.get('people', 2)
        }
        return preferences
    
    def calculate_service_score(self, service_idx, user_preferences, destination):
        """Calculate score for a service based on user preferences"""
        service = self.services_df.iloc[service_idx]
        score = 0.0
        
        # Location match (high priority)
        if destination.lower() in service['city'].lower():
            score += 10.0
        
        # Budget match
        budget_map = {'Thấp': 1, 'Trung bình': 2, 'Cao': 3}
        user_budget = budget_map.get(user_preferences['budget'], 2)
        
        if service['price'] < 1000000 and user_budget == 1:
            score += 5.0
        elif 1000000 <= service['price'] <= 5000000 and user_budget == 2:
            score += 5.0
        elif service['price'] > 5000000 and user_budget == 3:
            score += 5.0
        
        # Rating bonus
        score += service['rating'] * 2
        
        # Interest match
        features_text = service['features_text'].lower()
        for interest in user_preferences['interests']:
            if interest.lower() in features_text or interest.lower() in service['category'].lower():
                score += 3.0
        
        # Category diversity bonus (prioritize different categories)
        category_priority = {
            'Hotel': 1.5,
            'Restaurant': 1.3,
            'Tour': 1.4,
            'Activity': 1.2
        }
        score *= category_priority.get(service['category'], 1.0)
        
        return score
    
    def recommend_services(self, destination, user_profile, num_days=3, services_per_day=4):
        """Recommend services for itinerary"""
        print(f"\n🎯 Generating recommendations for {destination} ({num_days} days)...")
        
        user_preferences = self.extract_user_preferences(user_profile)
        
        # Filter services by destination
        city_services = self.services_df[
            self.services_df['city'].str.contains(destination, case=False, na=False)
        ].copy()
        
        if len(city_services) == 0:
            print(f"⚠️ No services found for {destination}, using all services")
            city_services = self.services_df.copy()
        
        print(f"📍 Found {len(city_services)} services in {destination}")
        
        # Calculate scores for each service
        city_services['score'] = city_services.index.map(
            lambda idx: self.calculate_service_score(idx, user_preferences, destination)
        )
        
        # Sort by score
        city_services = city_services.sort_values('score', ascending=False)
        
        # Generate itinerary
        itinerary = []
        total_services_needed = num_days * services_per_day
        
        # Ensure diversity in categories
        selected_services = []
        categories_used = []
        
        for _, service in city_services.iterrows():
            if len(selected_services) >= total_services_needed:
                break
            
            # Avoid too many of same category
            if categories_used.count(service['category']) < num_days:
                selected_services.append(service)
                categories_used.append(service['category'])
        
        # Organize by days
        services_per_day_list = [selected_services[i:i+services_per_day] 
                                 for i in range(0, len(selected_services), services_per_day)]
        
        for day_idx, day_services in enumerate(services_per_day_list[:num_days], 1):
            daily_schedule = {
                'day': day_idx,
                'date': f'Day {day_idx}',
                'theme': self._generate_theme(day_services),
                'weather_forecast': 'Sunny, 25-30°C',
                'ai_tip': self._generate_tip(day_services, user_preferences),
                'activities': []
            }
            
            # Generate activities with time slots
            time_slots = ['09:00', '12:00', '15:00', '18:00']
            for service, time in zip(day_services, time_slots):
                activity = {
                    'time': time,
                    'title': service['title'],
                    'place_id': service['serviceId'],
                    'notes': f"{service['category']} - {service.get('features_text', 'N/A')[:50]}...",
                    'price': int(service['price']),
                    'rating': float(service['rating'])
                }
                daily_schedule['activities'].append(activity)
            
            itinerary.append(daily_schedule)
        
        print(f"✅ Generated {len(itinerary)} days itinerary with {sum(len(d['activities']) for d in itinerary)} activities")
        return itinerary
    
    def _generate_theme(self, services):
        """Generate daily theme based on services"""
        categories = [s['category'] for s in services]
        if 'Hotel' in categories:
            return 'Relaxation & Comfort'
        elif 'Restaurant' in categories:
            return 'Culinary Experience'
        elif 'Tour' in categories:
            return 'Adventure & Exploration'
        else:
            return 'Mixed Activities'
    
    def _generate_tip(self, services, preferences):
        """Generate AI tip based on services and preferences"""
        tips = [
            f"Ngân sách {preferences['budget']} - hãy đặt trước để có giá tốt!",
            "Nhớ mang theo kem chống nắng và nước uống!",
            "Đặt xe di chuyển trước để tiết kiệm thời gian.",
            "Kiểm tra thời tiết trước khi đi để chuẩn bị tốt hơn."
        ]
        
        if any(s['category'] == 'Restaurant' for s in services):
            tips.append("Nên thử các món đặc sản địa phương!")
        
        return tips[len(services) % len(tips)]
    
    def save_model(self, filepath='./AI/travel_ai_model.pkl'):
        """Save trained model"""
        print(f"\n💾 Saving model to {filepath}...")
        model_data = {
            'tfidf_vectorizer': self.tfidf_vectorizer,
            'label_encoders': self.label_encoders,
            'services_df': self.services_df,
        }
        with open(filepath, 'wb') as f:
            pickle.dump(model_data, f)
        print("✅ Model saved successfully!")
    
    def load_model(self, filepath='./AI/travel_ai_model.pkl'):
        """Load trained model"""
        print(f"\n📥 Loading model from {filepath}...")
        with open(filepath, 'rb') as f:
            model_data = pickle.load(f)
        
        self.tfidf_vectorizer = model_data['tfidf_vectorizer']
        self.label_encoders = model_data['label_encoders']
        self.services_df = model_data['services_df']
        print("✅ Model loaded successfully!")


def main():
    """Main training and testing function"""
    print("🚀 Travel Itinerary AI - Training Started\n")
    
    # Initialize AI
    ai = TravelItineraryAI()
    
    # Load data
    ai.load_data()
    
    # Preprocess
    ai.preprocess_services()
    
    # Save model
    ai.save_model()
    
    # Test recommendation
    print("\n" + "="*60)
    print("🧪 Testing Recommendation System")
    print("="*60)
    
    test_user_profile = {
        'budgetRange': 'Trung bình',
        'interests': ['beach', 'food', 'relax'],
        'people': 2
    }
    
    itinerary = ai.recommend_services(
        destination='Đà Nẵng',
        user_profile=test_user_profile,
        num_days=3,
        services_per_day=4
    )
    
    # Print sample itinerary
    print("\n📋 Sample Itinerary:")
    for day in itinerary:
        print(f"\n  Day {day['day']}: {day['theme']}")
        print(f"  💡 Tip: {day['ai_tip']}")
        for activity in day['activities']:
            print(f"    {activity['time']} - {activity['title']} (${activity['price']:,})")
    
    print("\n✅ Training and testing completed!")


if __name__ == '__main__':
    main()

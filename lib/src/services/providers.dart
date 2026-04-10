import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/app_models.dart';

part 'providers.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

@riverpod
class UserController extends _$UserController {
  @override
  Future<UserModel?> build() async {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) return null;
    final doc = await ref.watch(firestoreProvider).collection('users').doc(user.uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await ref.read(firestoreProvider).collection('users').doc(user.uid).set(user.toMap());
    state = AsyncValue.data(user);
  }

  Future<void> markAsVisited(String placeName) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    
    final updatedList = List<String>.from(currentUser.visitedPlaces)..add(placeName);
    final updatedUser = currentUser.copyWith(visitedPlaces: updatedList);
    
    await ref.read(firestoreProvider).collection('users').doc(updatedUser.uid).update({
      'visitedPlaces': FieldValue.arrayUnion([placeName])
    });
    state = AsyncValue.data(updatedUser);
  }
}

@riverpod
class GeminiService extends _$GeminiService {
  late final GenerativeModel _model;

  @override
  void build() {
    _model = GenerativeModel(
      // Lightweight, fast 2.5 Flash Lite model
      model: 'gemini-2.5-flash-lite',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      // Forcing strict JSON output at the server level
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<List<PlaceRecommendationModel>> getRecommendations(UserModel user) async {
    final prompt = '''
      You are an elite, highly personalized travel AI. Suggest 5 unique travel destinations for a ${user.age}-year-old from ${user.state}, ${user.country}. 
      Their preferred environments are: ${user.preferredEnvironments.join(', ')}.
      
      CRITICAL INSTRUCTION 1: Do NOT recommend any of these places: ${user.visitedPlaces.join(', ')}.
      CRITICAL INSTRUCTION 2: Tailor these recommendations specifically for an adventure motorcycle rider operating a mid-weight (180kg) adventure bike with responsive torque (approx 26.5 nm). Focus on scenic routes, mountain passes, and rugged terrain that suit this riding style, blending it perfectly with their preferred environments.

      Return ONLY a valid JSON array of objects. Do not include markdown formatting. Each object MUST match this exact schema:
      [
        {
          "name": "Destination Name",
          "summary": "A vivid 2-sentence description highlighting why it's perfect for their travel and riding style.",
          "imageUrl": "https://source.unsplash.com/800x600/?motorcycle,scenic",
          "estimatedTravelCost": "\$1500",
          "estimatedTime": "10 Days",
          "tags": ["SCENIC ROUTES", "ADVENTURE RIDING"],
          "avgTemp": "22°C",
          "difficulty": "Moderate",
          "bestVisit": "May - Sep",
          "popularity": "High",
          "flightCost": "\$450 - \$820",
          "stayCost": "\$80 - \$150",
          "rentalCost": "\$45 / day",
          "activities": [
            {"tag": "ADVENTURE", "title": "High-altitude mountain pass riding"},
            {"tag": "SCENIC", "title": "Coastal highway exploration"}
          ]
        }
      ]
    '''; 
    
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    String cleanText = response.text ?? '[]';
    
    // Failsafe: Extract only the content between the first [ and the last ]
    final startIndex = cleanText.indexOf('[');
    final endIndex = cleanText.lastIndexOf(']');
    if (startIndex != -1 && endIndex != -1) {
      cleanText = cleanText.substring(startIndex, endIndex + 1);
    }
    
    final List<dynamic> data = jsonDecode(cleanText);
    return data.map((e) => PlaceRecommendationModel.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>> generateItinerary({
    required String start, 
    required String destination,
    required int days, 
    required double budget,
    required List<String> preferences,
  }) async {
    final prompt = '''
      Act as an elite travel architect. Construct a $days-day itinerary starting from $start to $destination. Total budget: ₹$budget INR.
      The traveler's preferences are: ${preferences.join(', ')}. Factor this into the transport, roads, and activities chosen.

      Return a JSON object with this EXACT schema. Do not use markdown (no ```json).
      {
        "tripTitle": "A catchy title for the trip",
        "itinerary": [
          {
            "day": 1,
            "dayTitle": "Arrival & Exploration",
            "daySummary": "A brief overview of the day.",
            "lodging": {
              "name": "Hotel Name",
              "description": "Brief description",
              "costPerNight": "₹4500",
              "imageUrl": "[https://source.unsplash.com/600x400/?hotel,boutique](https://source.unsplash.com/600x400/?hotel,boutique)"
            },
            "events": [
              {
                "type": "food", // Must be "food", "activity", or "transport"
                "title": "Dinner at Local Spot",
                "description": "Details about the food.",
                "cost": "₹1200",
                "bestTime": "8:00 PM",
                "entryTicket": "Not Applicable",
                "imageUrl": "" // Leave empty for food/transport, provide unsplash URL for activities
              },
              {
                "type": "activity",
                "title": "Museum Visit",
                "description": "Explore the history.",
                "cost": "₹500",
                "bestTime": "10:00 AM",
                "entryTicket": "Required - Book in advance",
                "imageUrl": "[https://source.unsplash.com/600x400/?museum](https://source.unsplash.com/600x400/?museum)"
              }
            ]
          }
        ]
      }
    ''';
    
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    String cleanText = response.text ?? '{}';
    
    // Failsafe: Extract only the content between the first { and the last }
    final startIndex = cleanText.indexOf('{');
    final endIndex = cleanText.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1) {
      cleanText = cleanText.substring(startIndex, endIndex + 1);
    }
    
    return jsonDecode(cleanText);
  }
}
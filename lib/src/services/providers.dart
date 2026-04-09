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
      // Updated to use the lightweight, fast 2.5 Flash Lite model
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
      You are an expert travel concierge. Suggest 5 travel destinations for a ${user.age} year old from ${user.state}, ${user.country}. 
      Their preferred environments are: ${user.preferredEnvironments.join(', ')}.
      CRITICAL INSTRUCTION: Do NOT recommend any of these places: ${user.visitedPlaces.join(', ')}.
      
      Return a JSON array of objects with these exact keys: "name", "summary", "estimatedTravelCost", "estimatedTime", "imageUrl" (provide a realistic unsplash placeholder URL for the image).
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
    required String start, required String destination,
    required int days, required double budget
  }) async {
    final prompt = '''
      Act as a budget-conscious travel agent. Construct a $days-day itinerary starting from $start to $destination. Total budget: \$$budget.
      Generate a logical day-by-day itinerary that fits within the budget constraint, suggesting specific transport types and lodging tiers.
      Return a JSON object with a key "itinerary" containing an array of objects. Each object should have:
      "day" (int), "title" (string), "lodging" (string), "activities" (list of strings), "estimatedDailyCost" (number).
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
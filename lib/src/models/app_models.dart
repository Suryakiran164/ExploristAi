import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final List<String> preferredEnvironments;
  final String country;
  final String state;
  final List<String> visitedPlaces;

  UserModel({
    required this.uid, required this.email, required this.name, required this.age,
    required this.preferredEnvironments, required this.country, required this.state,
    required this.visitedPlaces,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid, 'email': email, 'name': name, 'age': age,
      'preferredEnvironments': preferredEnvironments, 'country': country,
      'state': state, 'visitedPlaces': visitedPlaces,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '', email: map['email'] ?? '', name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      preferredEnvironments: List<String>.from(map['preferredEnvironments'] ?? []),
      country: map['country'] ?? '', state: map['state'] ?? '',
      visitedPlaces: List<String>.from(map['visitedPlaces'] ?? []),
    );
  }

  UserModel copyWith({List<String>? visitedPlaces}) {
    return UserModel(
      uid: uid, email: email, name: name, age: age,
      preferredEnvironments: preferredEnvironments, country: country,
      state: state, visitedPlaces: visitedPlaces ?? this.visitedPlaces,
    );
  }
}

class PlaceRecommendationModel {
  final String name;
  final String summary;
  final String estimatedTravelCost; 
  final String estimatedTime;       
  final String imageUrl;
  
  final List<String> tags; 
  final String avgTemp;    
  final String difficulty; 
  final String bestVisit;  
  final String popularity; 
  final String flightCost; 
  final String stayCost;   
  final String rentalCost; 
  final List<Map<String, String>> activities;

  PlaceRecommendationModel({
    required this.name, required this.summary, required this.estimatedTravelCost,
    required this.estimatedTime, required this.imageUrl,
    required this.tags, required this.avgTemp, required this.difficulty,
    required this.bestVisit, required this.popularity, required this.flightCost,
    required this.stayCost, required this.rentalCost, required this.activities,
  });

  factory PlaceRecommendationModel.fromMap(Map<String, dynamic> map) {
    return PlaceRecommendationModel(
      name: map['name'] ?? '', 
      summary: map['summary'] ?? '',
      estimatedTravelCost: map['estimatedTravelCost'] ?? '',
      estimatedTime: map['estimatedTime'] ?? '', 
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      avgTemp: map['avgTemp'] ?? 'N/A',
      difficulty: map['difficulty'] ?? 'N/A',
      bestVisit: map['bestVisit'] ?? 'N/A',
      popularity: map['popularity'] ?? 'N/A',
      flightCost: map['flightCost'] ?? 'N/A',
      stayCost: map['stayCost'] ?? 'N/A',
      rentalCost: map['rentalCost'] ?? 'N/A',
      activities: List<Map<String, String>>.from(
        (map['activities'] as List<dynamic>? ?? []).map(
          (x) => Map<String, String>.from(x as Map)
        )
      ),
    );
  }
}

class TripModel {
  final String tripId;
  final String userId;
  final String startingPoint;
  final String destination;
  final int durationDays;
  final double budget;
  final List<Map<String, dynamic>> itinerary;
  final DateTime createdAt;

  TripModel({
    required this.tripId, required this.userId, required this.startingPoint,
    required this.destination, required this.durationDays, required this.budget,
    required this.itinerary, required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId, 'userId': userId, 'startingPoint': startingPoint,
      'destination': destination, 'durationDays': durationDays,
      'budget': budget, 'itinerary': itinerary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // REQUIRED FOR THE SAVED SCREEN TO WORK
  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['tripId'] ?? '',
      userId: map['userId'] ?? '',
      startingPoint: map['startingPoint'] ?? '',
      destination: map['destination'] ?? '',
      durationDays: map['durationDays']?.toInt() ?? 0,
      budget: map['budget']?.toDouble() ?? 0.0,
      itinerary: List<Map<String, dynamic>>.from(
        (map['itinerary'] as List<dynamic>? ?? []).map((x) => Map<String, dynamic>.from(x as Map))
      ),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
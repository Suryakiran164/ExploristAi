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

  PlaceRecommendationModel({
    required this.name, required this.summary, required this.estimatedTravelCost,
    required this.estimatedTime, required this.imageUrl,
  });

  factory PlaceRecommendationModel.fromMap(Map<String, dynamic> map) {
    return PlaceRecommendationModel(
      name: map['name'] ?? '', summary: map['summary'] ?? '',
      estimatedTravelCost: map['estimatedTravelCost'] ?? '',
      estimatedTime: map['estimatedTime'] ?? '', imageUrl: map['imageUrl'] ?? '',
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
}
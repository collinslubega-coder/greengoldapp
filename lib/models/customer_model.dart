// lib/models/customer_model.dart
import 'package:uuid/uuid.dart'; // For generating UUIDs

class Customer {
  final String id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;

  Customer({
    String? id,
    required this.name,
    this.contactPerson,
    this.email,
    this.phoneNumber,
    this.address,
    DateTime? createdAt,
  }) :  id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contact_person'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper for updating immutable fields
  Customer copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
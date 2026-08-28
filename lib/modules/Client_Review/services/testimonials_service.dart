import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/testimonial_model.dart';

class TestimonialsService {
  static const String baseUrl = 'https://kdtdiamond.com';
  static const String endpoint = '/api/v1/testimonials/active';

  Future<List<Testimonial>> fetchTestimonials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final testimonials = Testimonial.fromJsonList(data);
        return testimonials;
      } else {
        throw Exception('Failed to load testimonials: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching testimonials: $e');
      rethrow;
    }
  }
}
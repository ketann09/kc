import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:kabadiwala_connect/core/network/api_client.dart';
import 'package:kabadiwala_connect/data/datasources/remote/lots_remote_data_source.dart';
import 'package:kabadiwala_connect/data/models/user_model.dart';
import 'package:kabadiwala_connect/domain/entities/lot_entity.dart';

class MockApiClientForLotLocation extends Fake implements ApiClient {
  Map<String, dynamic>? lastFormDataFields;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (data is FormData) {
      lastFormDataFields = {
        for (final entry in data.fields) entry.key: entry.value,
      };
    }
    return Response<T>(
      data: {
        'status': 'success',
        'data': {
          '_id': 'lot_test_loc_1',
          'id': 'lot_test_loc_1',
          'collectorId': 'col_123',
          'category': 'Plastic',
          'estimatedWeight': 5.0,
          'status': 'pending',
          'location': {
            'type': 'Point',
            'coordinates': [77.3910, 28.5355],
            'city': 'Noida',
            'state': 'Uttar Pradesh',
          },
        },
      } as T,
      statusCode: 201,
      requestOptions: RequestOptions(path: path),
    );
  }
}

void main() {
  group('Lot Location & Coordinates Tests', () {
    test('UserAddressModel parses coordinates correctly from num and string', () {
      final jsonNum = {
        'street': 'Sector 62',
        'city': 'Noida',
        'state': 'Uttar Pradesh',
        'pincode': '201301',
        'latitude': 28.5355,
        'longitude': 77.3910,
      };

      final addr1 = UserAddressModel.fromJson(jsonNum);
      expect(addr1.latitude, equals(28.5355));
      expect(addr1.longitude, equals(77.3910));

      final jsonStr = {
        'street': 'Sector 62',
        'city': 'Noida',
        'state': 'Uttar Pradesh',
        'pincode': '201301',
        'latitude': '28.5355',
        'longitude': '77.3910',
      };

      final addr2 = UserAddressModel.fromJson(jsonStr);
      expect(addr2.latitude, equals(28.5355));
      expect(addr2.longitude, equals(77.3910));
    });

    test('UserAddressModel handles null coordinates gracefully', () {
      final jsonNull = {
        'street': 'Sector 62',
        'city': 'Noida',
        'state': 'Uttar Pradesh',
      };

      final addr = UserAddressModel.fromJson(jsonNull);
      expect(addr.latitude, isNull);
      expect(addr.longitude, isNull);
    });

    test('LotsRemoteDataSourceImpl serializes non-zero coordinates in location payload', () async {
      final mockClient = MockApiClientForLotLocation();
      final dataSource = LotsRemoteDataSourceImpl(apiClient: mockClient);

      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test_photo.jpg')..writeAsStringSync('dummy content');

      try {
        await dataSource.createLot(
          CreateLotParams(
            imagePaths: [tempFile.path],
            estimatedWeight: 5.0,
            location: const LotLocationEntity(
              latitude: 28.5355,
              longitude: 77.3910,
              city: 'Noida',
              state: 'Uttar Pradesh',
              address: 'Sector 62, Noida',
            ),
            category: 'Plastic',
          ),
        );
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }

      expect(mockClient.lastFormDataFields, isNotNull);
      final locationJsonStr = mockClient.lastFormDataFields!['location'] as String;
      final parsedLocation = jsonDecode(locationJsonStr) as Map<String, dynamic>;

      expect(parsedLocation['type'], equals('Point'));
      final coords = parsedLocation['coordinates'] as List;
      expect(coords[0], equals(77.3910)); // Longitude first in GeoJSON
      expect(coords[1], equals(28.5355)); // Latitude second
      expect(parsedLocation['city'], equals('Noida'));
      expect(parsedLocation['state'], equals('Uttar Pradesh'));
    });
  });
}

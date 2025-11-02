import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rides = [
      {
        'date': '2024-01-15',
        'from': 'Paris',
        'to': 'Lyon',
        'price': 25.50,
        'status': 'completed',
        'driver': 'Jean Dupont',
        'rating': 5,
      },
      {
        'date': '2024-01-10',
        'from': 'Marseille',
        'to': 'Nice',
        'price': 18.00,
        'status': 'completed',
        'driver': 'Marie Martin',
        'rating': 4,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des trajets'),
      ),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.directions_car,
                color: ride['status'] == 'completed' ? Colors.green : Colors.orange,
              ),
              title: Text('${ride['from']} → ${ride['to']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ride['date']} - ${ride['driver']}'),
                  Text('${ride['price']}€'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ride['rating'] != null)
                    Icon(Icons.star, color: Colors.amber, size: 20),
                  Text(ride['rating']?.toString() ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

class NotificationTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    debugPrint('NotificationTab.build()');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black))
      ),
      body: const Text('Notification tab')
    );
  }
}
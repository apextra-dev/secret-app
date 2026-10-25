import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });
  final String partnerId;
  final String partnerName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Center(
            child: Column(
              children: [
                StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('users')
                      .child(partnerId)
                      .child('status')
                      .onValue,
                  builder: (context, snapshot) {
                    bool isOnline = false;

                    if (snapshot.hasData &&
                        snapshot.data?.snapshot.value != null) {
                      final data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map,
                      );
                      isOnline = data['state'] == 'online';
                    }
                    return Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          child: Text(
                            '${partnerName[0]}',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 10,
                            bottom: 5,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 4,
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                ),
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  partnerName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('users')
                      .child(partnerId)
                      .child('status')
                      .onValue,
                  builder: (context, snapshot) {
                    bool isOnline = false;

                    if (snapshot.hasData &&
                        snapshot.data?.snapshot.value != null) {
                      final data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map,
                      );
                      isOnline = data['state'] == 'online';
                    }
                    return Text(
                      isOnline ? 'online' : 'last seen recently',
                      style: TextStyle(color: isOnline ? Colors.blue : null),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 37,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              isDark
                                  ? 'assets/images/partner_profile/light_message.svg'
                                  : 'assets/images/partner_profile/dark_message.svg',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Message',
                              style: TextStyle(
                                fontWeight: .w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(child: Column(children: [Text('')])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

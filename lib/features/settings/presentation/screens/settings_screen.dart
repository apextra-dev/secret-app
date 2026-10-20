import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 50,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/settings/darkTheme.svg'),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:secret/bloc/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 50),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/settings/theme_img.svg'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, state) {
                        final currentBrightness = state.brightness;

                        return DropdownButton<Brightness>(
                          value: currentBrightness,
                          underline: const SizedBox(),
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(
                              currentBrightness == Brightness.dark
                                  ? Icons.nightlight_round
                                  : Icons.sunny,
                              color: currentBrightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                          onChanged: (Brightness? newBrightness) {
                            if (newBrightness != null) {
                              context.read<ThemeCubit>().setThemeBrightness(
                                newBrightness,
                              );
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Brightness.light,
                              child: Text(
                                'Light',
                                style: TextStyle(
                                  fontFamily: 'Rajdhani-Regular',
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Brightness.dark,
                              child: Text(
                                'Dark',
                                style: TextStyle(
                                  fontFamily: 'Rajdhani-Regular',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

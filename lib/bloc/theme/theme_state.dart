part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  ThemeState({required this.brightness});

  final Brightness brightness;

  @override
  List<Object?> get props => [brightness];

}
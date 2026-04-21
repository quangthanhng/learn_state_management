import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:gap/gap.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

typedef WeatherEmoji = String;

enum City { stockholm, paris, tokyo }

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {City.stockholm: '❄️', City.paris: '🌧️', City.tokyo: '🌥️'}[city] ??
        '?',
  );
}

// UI writes to and read from this
final currencityProvider = StateProvider<City?>((ref) => null);
//UI read this
const unknownWeatherEmoji = '🤷';

final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currencityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Title weather')),
      body: Column(
        children: [
          currentWeather.when(
            // Execute when with async value, with 3 parameters including 3 states
            data: (data) => Text(data, style: const TextStyle(fontSize: 40)),
            error: (error, stackTrace) => const Text('Error 😢'),
            loading: () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: const CircularProgressIndicator(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currencityProvider);
                return ListTile(
                  title: Text(city.toString()),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () =>
                      ref.read(currencityProvider.notifier).state = city,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

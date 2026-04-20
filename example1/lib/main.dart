import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

final currentDate = Provider((ref) => DateTime.now());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(currentDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Hooks Riverpod')),
      backgroundColor: Colors.blueGrey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              date.toIso8601String(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Gap(15),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentDate);
            },
            label: Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

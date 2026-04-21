import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:hooks_riverpod/misc.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.description,
    required this.title,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) {
    return Film(
      description: description,
      id: id,
      title: title,
      isFavorite: isFavorite,
    );
  }

  String toString() =>
      'Film(id: $id, '
      'title: $title,'
      'description: $description,'
      'isFavorite: $isFavorite )';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);
}

const allFilms = [
  Film(
    id: '1',
    description: 'Description for The ShawShank Redemption',
    title: 'The ShawShank Redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    description: 'Description for The Godfather',
    title: 'The Godfather',
    isFavorite: false,
  ),
  Film(
    id: '3',
    description: 'Description for The ShawShank Redemption',
    title: 'The Godfather: part II',
    isFavorite: false,
  ),
  Film(
    id: '4',
    description: 'Description for The Dark Knight',
    title: 'The Dark Kinght',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map(
          (thisFilm) => thisFilm.id == film.id
              ? thisFilm.copy(isFavorite: isFavorite)
              : thisFilm,
        )
        .toList();
  }
}

enum FavoriteStatus { all, favorite, notFavorite }

// favorite status
final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (ref) => FavoriteStatus.all,
);

// all films

final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (ref) => FilmsNotifier(),
);

// favorite films

final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite),
);

// not favorite films

final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite),
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Films')),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);
              switch (filter) {
                case FavoriteStatus.all:
                  return FilmsList(provider: allFilmsProvider);
                case FavoriteStatus.favorite:
                  return FilmsList(provider: favoriteFilmsProvider);
                case FavoriteStatus.notFavorite:
                  return FilmsList(provider: notFavoriteFilmsProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}

class FilmsList extends ConsumerWidget {
  final ProviderListenable<Iterable<Film>> provider;
  const FilmsList({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              onPressed: () {
                final isFavorite = !film.isFavorite;
                ref.read(allFilmsProvider.notifier).update(film, isFavorite);
              },
              icon: favoriteIcon,
            ),
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavoriteStatus.values
              .map((fs) => DropdownMenuItem(value: fs, child: Text(fs.name)))
              .toList(),
          onChanged: (fs) {
            ref.read(favoriteStatusProvider.notifier).state = fs!;
          },
        );
      },
    );
  }
}

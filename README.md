# Giphy Search

A small Flutter app that searches the [Giphy API](https://developers.giphy.com)
as you type. Results show up in a masonry grid, scroll to load more, tap one to
see it bigger.

Built and tested with **Flutter 3.38.6** (stable, Dart 3.10.x). The project's
Dart SDK constraint is `^3.7.2`, so any recent stable Flutter will do.

## Running

You'll need a Giphy API key — it's shared separately, or you can grab a free
one at [developers.giphy.com](https://developers.giphy.com/dashboard).

**Option A — paste once into source** (simplest):

Open `lib/core/config/app_config.dart` and put the key into `_fallbackApiKey`:

```dart
static const String _fallbackApiKey = 'your_key_here';
```

Then:

```sh
flutter pub get
flutter run
```

**Option B — keep it out of source** (recommended for anything beyond a quick
look):

```sh
cp env.example.json env.json   # then put the key inside
flutter pub get
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored.

If you forget to set the key, the app boots into a screen that tells you what
to do — it doesn't crash.

## Tests

```sh
flutter test
```

Covers JSON parsing, pagination math, the repository's connectivity gate and
error mapping, the BLoC (debounce, pagination, retries), and the `ErrorView`
widget.

## Notes on the code

- **State** — `flutter_bloc`. A single `GifSearchState` keeps everything the
  screen needs; old results stay on screen while the next page loads or while
  an error is shown.
- **Concurrency** — query events are debounced 400ms and `restartable`, so only
  the last query the user typed gets sent. Pagination uses `droppable` so we
  don't fire several "next page" requests in a row.
- **Errors** — the repository throws typed `Failure`s (`NetworkFailure`,
  `TimeoutFailure`, `ServerFailure`, `UnknownFailure`). The UI renders them as
  a full-screen view, a retry footer, or a snackbar depending on whether
  results are already visible.
- **Navigation** — routes are named, and a small `AppCoordinator` lets widgets
  push screens without touching `Navigator` directly.
- **Offline** — `connectivity_plus` drives the offline banner and triggers a
  retry when the connection comes back. The same caveat applies as always:
  connectivity reflects the interface, not real reachability, so failed
  requests still get caught and shown.

## Layout

```
lib/
├── app/                  composition root, DI, navigation
├── core/                 config, theming, failures, shared widgets
└── features/gif_search/
    ├── data/             dio data source + repository, JSON models
    ├── domain/entities/  Gif, GifPage
    └── presentation/     bloc, pages, widgets
```

## Trade-offs

- The grid uses animated previews (`fixed_width`). It's a GIF app, that's the
  point — but on very deep result lists you'd want still previews to ease
  memory pressure.
- Giphy's free tier caps deep pagination. If a deep page fails we keep what's
  already loaded and offer a retry.

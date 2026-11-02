import '../../../l10n/generated/app_localizations.dart';

/// Localized name for a catalog name key. A key this app does not know yet
/// shows a generic label instead of the raw key.
String activityName(AppLocalizations t, String nameKey) => switch (nameKey) {
  'activityCinema' => t.activityCinema,
  'activityTheatre' => t.activityTheatre,
  'activityConcerts' => t.activityConcerts,
  'activityMuseums' => t.activityMuseums,
  'activityRunning' => t.activityRunning,
  'activityTrekking' => t.activityTrekking,
  'activityCycling' => t.activityCycling,
  'activityBoardGames' => t.activityBoardGames,
  'activityKaraoke' => t.activityKaraoke,
  'activityLanguageExchange' => t.activityLanguageExchange,
  'activityStreetPhotography' => t.activityStreetPhotography,
  'activityRestaurants' => t.activityRestaurants,
  _ => t.activityUnknown,
};

String? activityDescription(AppLocalizations t, String nameKey) =>
    switch (nameKey) {
      'activityCinema' => t.activityCinemaDescription,
      'activityTheatre' => t.activityTheatreDescription,
      'activityConcerts' => t.activityConcertsDescription,
      'activityMuseums' => t.activityMuseumsDescription,
      'activityRunning' => t.activityRunningDescription,
      'activityTrekking' => t.activityTrekkingDescription,
      'activityCycling' => t.activityCyclingDescription,
      'activityBoardGames' => t.activityBoardGamesDescription,
      'activityKaraoke' => t.activityKaraokeDescription,
      'activityLanguageExchange' => t.activityLanguageExchangeDescription,
      'activityStreetPhotography' => t.activityStreetPhotographyDescription,
      'activityRestaurants' => t.activityRestaurantsDescription,
      _ => null,
    };

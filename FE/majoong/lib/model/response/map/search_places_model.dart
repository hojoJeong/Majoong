class SearchPlacesModel {
  final String image;
  final String locationName;
  final String address;
  final bool isFavorite;
  final double lat;
  final double lng;

  SearchPlacesModel(
      {required this.image,
      required this.locationName,
      required this.address,
      required this.isFavorite,
      required this.lat,
      required this.lng});
}

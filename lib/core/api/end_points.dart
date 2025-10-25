class EndPoints {
  static const String baseUrl = 'https://waslny.octopusteam.net/api/v1/';
  static const String loginUrl = '${baseUrl}login';
  static const String validateDataUrl = '${baseUrl}validate-data';
  static const String registerUrl = '${baseUrl}register';
  static const String homeUrl = '${baseUrl}get-home?filter_by=';
  static const String changeFavUrl = '${baseUrl}tripFav/';
  static const String getLastAddressesUrl =
      '${baseUrl}get-last-addresses?is_service=';
  static const String getFavTripsAndServicesUrl =
      '${baseUrl}get-fav?filter_by=';
  static const String cloneTripUrl = '${baseUrl}clone-trip';

  //!

  static const String shipmentDetailsUrl = '${baseUrl}get-shipment-detail/';
  static const String userCompleteShipmentUrl =
      '${baseUrl}mark-shipment-complete/';
  static const String getNotificationsUrl = '${baseUrl}get-notifications';

  static const String assignDriverUrl = '${baseUrl}assign-driver';
  static const String updateShipmentStatusUrl =
      '${baseUrl}update-shipment-status';
  static const String deleteShipmentUrl = '${baseUrl}delete-shipment/';
  static const String updateIsNotifyUrl = '${baseUrl}is_notify';
  static const String driverRequestShipmentUrl =
      '${baseUrl}driver/request-shipment/';
  static const String driverCancelRequestShipmentUrl =
      '${baseUrl}driver/cancel-request-shipment/';

  static const String driverHomeUrl = '${baseUrl}driver/get-home';
  static const String driverShipmnetDetailsUrl =
      '${baseUrl}driver/get-shipment/';
  static const String driverScheduleTripsUrl =
      '${baseUrl}driver/get-my-schedule-trips';
  static const String driverCompleteShipmentUrl =
      '${baseUrl}driver/mark-shipment-complete/';
  static const String driverCancelTripUrl = '${baseUrl}cancel-trip';
  static const String addShipmentLocationUrl =
      '${baseUrl}add-shipment-location';
  static const String addRateUrl = '${baseUrl}add-rate';

  static const String forgetPasswordUrl = '${baseUrl}forget-password';
  static const String resetPasswordUrl = '${baseUrl}reset-password';
  static const String mainGetDataUrl = '${baseUrl}get-data';
  static const String addNewTripUrl = '${baseUrl}add-trip';
  static const String updateTrip = '${baseUrl}update-trip/';
  static const String contactUsUrl = '${baseUrl}contact-us';
  static const String deleteAccountUrl = '${baseUrl}delete-account';
  static const String logoutUrl = '${baseUrl}logout';
  static const String authDatatUrl = '${baseUrl}auth-data';
  static const String changeLanguageUrl = '${baseUrl}change-language';
  static const String updateUserProfiletUrl = '${baseUrl}update-profile';
  static const String updateDeliveryprofiletUrl =
      '${baseUrl}driver/update-driver-data';
  static const String updateDriverDataUrl = '${baseUrl}driver/upload-documents';
  static const String toggleStatusUrl = '${baseUrl}driver/toggle-status';
  static const String getSettingsUrl = '${baseUrl}get-settings';
  static const String getChatRoomsUrl = '${baseUrl}get-all-chat-rooms';
  // static const String sendMessageUrl = '${baseUrl}v1/chat/sendMessage';
  static const String createChatRoomUrl = '${baseUrl}get-room-token';
  static const String getVideosUrl = '${baseUrl}get-videos';
  static const String getAddressMapUrl =
      'https://nominatim.openstreetmap.org/reverse';
  static const String searchOnMapUrl =
      'https://nominatim.openstreetmap.org/search';
  static const String getDriverDetailsUrl = '${baseUrl}get-driver-details/';
  static const String sendMessageNotificationUrl =
      '${baseUrl}send-message-notification';
  static const String updatePassword = '${baseUrl}update-password';
  static const String getMyTrips = '${baseUrl}get-my-trips?filter_by=';
  static const String cancelTrip = '${baseUrl}cancel-trip';
}


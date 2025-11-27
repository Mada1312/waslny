abstract class DriverTripsState {}

class DriverTripsInitial extends DriverTripsState {}


class GetTripsLoadingState extends DriverTripsState {}

class GetTripsErrorState extends DriverTripsState {}

class GetTripsSuccessState extends DriverTripsState {}

class UpdateTripStatusSuccessState extends DriverTripsState {}

class UpdateTripStatusLoadingState extends DriverTripsState {}

class UpdateTripStatusErrorState extends DriverTripsState {}

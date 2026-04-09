// lib/core/features/booking/data/cubit/booking_state.dart

part of 'booking_cubit.dart';

sealed class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  final BookingDetail? selectedBooking;
  final CreateBookingResponse? createResponse;
  final CancelBookingResponse? cancelResponse;

  const BookingLoaded({
    this.bookings = const [],
    this.selectedBooking,
    this.createResponse,
    this.cancelResponse,
  });

  BookingLoaded copyWith({
    List<Booking>? bookings,
    BookingDetail? selectedBooking,
    CreateBookingResponse? createResponse,
    CancelBookingResponse? cancelResponse,
  }) {
    return BookingLoaded(
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      createResponse: createResponse ?? this.createResponse,
      cancelResponse: cancelResponse ?? this.cancelResponse,
    );
  }
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}
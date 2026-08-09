import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod { creditCard, paypal }

final checkoutProvider =
    NotifierProvider.autoDispose<CheckoutController, CheckoutState>(
      CheckoutController.new,
    );

class CheckoutState {
  const CheckoutState({
    this.contact = '',
    this.country = 'United Kingdom',
    this.firstName = '',
    this.lastName = '',
    this.address = '',
    this.apartment = '',
    this.city = '',
    this.postcode = '',
    this.acceptsMarketing = false,
    this.selectedPaymentMethod = PaymentMethod.creditCard,
  });

  final String contact;
  final String country;
  final String firstName;
  final String lastName;
  final String address;
  final String apartment;
  final String city;
  final String postcode;
  final bool acceptsMarketing;
  final PaymentMethod selectedPaymentMethod;

  CheckoutState copyWith({
    String? contact,
    String? country,
    String? firstName,
    String? lastName,
    String? address,
    String? apartment,
    String? city,
    String? postcode,
    bool? acceptsMarketing,
    PaymentMethod? selectedPaymentMethod,
  }) {
    return CheckoutState(
      contact: contact ?? this.contact,
      country: country ?? this.country,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      acceptsMarketing: acceptsMarketing ?? this.acceptsMarketing,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setContact(String value) => state = state.copyWith(contact: value);
  void setCountry(String value) => state = state.copyWith(country: value);
  void setFirstName(String value) => state = state.copyWith(firstName: value);
  void setLastName(String value) => state = state.copyWith(lastName: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setApartment(String value) => state = state.copyWith(apartment: value);
  void setCity(String value) => state = state.copyWith(city: value);
  void setPostcode(String value) => state = state.copyWith(postcode: value);
  void setAcceptsMarketing(bool value) {
    state = state.copyWith(acceptsMarketing: value);
  }

  void setPaymentMethod(PaymentMethod value) {
    state = state.copyWith(selectedPaymentMethod: value);
  }
}

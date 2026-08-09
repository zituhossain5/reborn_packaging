abstract final class PricingConfig {
  static const vatRate = 0.20;

  static double priceForVatState({
    required double exVatPrice,
    required bool includeVat,
  }) {
    return includeVat ? exVatPrice * (1 + vatRate) : exVatPrice;
  }
}

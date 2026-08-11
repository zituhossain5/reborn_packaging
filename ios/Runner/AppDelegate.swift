import Flutter
import ShopifyCheckoutSheetKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
  ShopifyCheckoutSheetKitDelegate
{
  private static let checkoutChannelName =
    "com.rebornpackaging.reborn_packaging/shopify_checkout"
  private var checkoutChannel: FlutterMethodChannel?
  private var pendingCheckoutResult: FlutterResult?
  private weak var checkoutPresenter: UIViewController?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "RebornShopifyCheckoutBridge")
    let channel = FlutterMethodChannel(
      name: Self.checkoutChannelName,
      binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleCheckoutMethod(call, result: result)
    }
    checkoutChannel = channel
    configureCheckoutKit()
  }

  private func configureCheckoutKit() {
    let brandGreen = UIColor(
      red: 18.0 / 255.0,
      green: 75.0 / 255.0,
      blue: 61.0 / 255.0,
      alpha: 1.0)
    ShopifyCheckoutSheetKit.configuration.colorScheme = .light
    ShopifyCheckoutSheetKit.configuration.tintColor = brandGreen
    ShopifyCheckoutSheetKit.configuration.backgroundColor = .white
    ShopifyCheckoutSheetKit.configuration.title = "Reborn Packaging"
    ShopifyCheckoutSheetKit.configuration.closeButtonTintColor = brandGreen
  }

  private func handleCheckoutMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "presentCheckout" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard pendingCheckoutResult == nil else {
      result(
        FlutterError(
          code: "checkout_already_presented",
          message: "Checkout is already open.",
          details: nil))
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let rawCheckoutURL = arguments["checkoutUrl"] as? String,
      let checkoutURL = URL(string: rawCheckoutURL),
      checkoutURL.scheme?.lowercased() == "https",
      checkoutURL.host != nil
    else {
      result(
        FlutterError(
          code: "invalid_checkout_url",
          message: "Checkout is unavailable.",
          details: nil))
      return
    }
    guard let presenter = topViewController(from: window?.rootViewController) else {
      result(
        FlutterError(
          code: "presentation_failed",
          message: "Checkout could not be opened.",
          details: nil))
      return
    }

    pendingCheckoutResult = result
    checkoutPresenter = presenter
    ShopifyCheckoutSheetKit.present(
      checkout: checkoutURL,
      from: presenter,
      delegate: self)
  }

  private func topViewController(from root: UIViewController?) -> UIViewController? {
    if let navigation = root as? UINavigationController {
      return topViewController(from: navigation.visibleViewController)
    }
    if let tabs = root as? UITabBarController {
      return topViewController(from: tabs.selectedViewController)
    }
    if let presented = root?.presentedViewController {
      return topViewController(from: presented)
    }
    return root
  }

  func checkoutDidComplete(event: CheckoutCompletedEvent) {
    var details: [String: Any] = [:]
    if !event.orderDetails.id.isEmpty {
      details["orderId"] = event.orderDetails.id
    }
    finishCheckout(event: "checkoutCompleted", details: details)
  }

  func checkoutDidCancel() {
    finishCheckout(event: "checkoutCanceled")
  }

  func checkoutDidFail(error: CheckoutError) {
    finishCheckout(event: "checkoutFailed", errorCode: safeErrorCode(for: error))
  }

  private func safeErrorCode(for error: CheckoutError) -> String {
    switch error {
    case .sdkError:
      return "sdk_error"
    case .configurationError:
      return "configuration_error"
    case .checkoutUnavailable:
      return "checkout_unavailable"
    case .checkoutExpired:
      return "cart_expired"
    @unknown default:
      return "unknown"
    }
  }

  private func finishCheckout(
    event: String,
    errorCode: String? = nil,
    details: [String: Any] = [:]
  ) {
    guard let result = pendingCheckoutResult else { return }
    pendingCheckoutResult = nil

    var payload = details
    payload["event"] = event
    if let errorCode {
      payload["errorCode"] = errorCode
    }

    let presenter = checkoutPresenter
    checkoutPresenter = nil
    presenter?.dismiss(animated: true) {
      result(payload)
    }
  }
}

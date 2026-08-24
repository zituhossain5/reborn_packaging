package com.rebornpackaging.reborn_packaging

import com.shopify.checkoutsheetkit.DefaultCheckoutEventProcessor
import com.shopify.checkoutsheetkit.CheckoutException
import com.shopify.checkoutsheetkit.CheckoutSheetKitDialog
import com.shopify.checkoutsheetkit.Color
import com.shopify.checkoutsheetkit.ColorScheme
import com.shopify.checkoutsheetkit.ShopifyCheckoutSheetKit
import com.shopify.checkoutsheetkit.lifecycleevents.CheckoutCompletedEvent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var pendingCheckoutResult: MethodChannel.Result? = null
    private var checkoutDialog: CheckoutSheetKitDialog? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ShopifyCheckoutSheetKit.configure {
            it.colorScheme = ColorScheme.Light().customize {
                headerBackground = Color.ResourceId(R.color.checkout_header_background)
                headerFont = Color.ResourceId(R.color.checkout_header_foreground)
                closeIconTint = Color.ResourceId(R.color.checkout_header_foreground)
                progressIndicator = Color.ResourceId(R.color.checkout_progress)
                webViewBackground = Color.ResourceId(R.color.checkout_background)
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHECKOUT_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    PRESENT_CHECKOUT -> presentCheckout(call.argument<String>("checkoutUrl"), result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun presentCheckout(checkoutUrl: String?, result: MethodChannel.Result) {
        if (pendingCheckoutResult != null) {
            result.error("checkout_already_presented", "Checkout is already open.", null)
            return
        }
        if (checkoutUrl.isNullOrBlank()) {
            result.error("invalid_checkout_url", "Checkout is unavailable.", null)
            return
        }

        pendingCheckoutResult = result
        val eventProcessor = object : DefaultCheckoutEventProcessor(this@MainActivity) {
            override fun onCheckoutCompleted(checkoutCompletedEvent: CheckoutCompletedEvent) {
                val order = checkoutCompletedEvent.orderDetails
                val total = order.cart.price.total
                finishCheckout(
                    "checkoutCompleted",
                    dismissDialog = true,
                    details = mapOf(
                        "orderId" to order.id,
                        "itemCount" to order.cart.lines.sumOf { it.quantity },
                        "totalAmount" to total?.amount,
                        "currencyCode" to total?.currencyCode,
                    ),
                )
            }

            override fun onCheckoutCanceled() {
                finishCheckout("checkoutCanceled")
            }

            override fun onCheckoutFailed(error: CheckoutException) {
                finishCheckout("checkoutFailed", error.errorCode)
            }
        }

        try {
            checkoutDialog = ShopifyCheckoutSheetKit.present(checkoutUrl, this, eventProcessor)
        } catch (_: Exception) {
            finishCheckout("checkoutFailed", "presentation_failed")
        }
    }

    private fun finishCheckout(
        event: String,
        errorCode: String? = null,
        dismissDialog: Boolean = false,
        details: Map<String, Any?> = emptyMap(),
    ) {
        val result = pendingCheckoutResult ?: return
        pendingCheckoutResult = null
        val dialog = checkoutDialog
        checkoutDialog = null
        if (dismissDialog) dialog?.dismiss()
        result.success(
            buildMap<String, Any?> {
                put("event", event)
                errorCode?.takeIf { it.isNotBlank() }?.let { put("errorCode", it) }
                putAll(details.filterValues { it != null })
            },
        )
    }

    companion object {
        private const val CHECKOUT_CHANNEL =
            "com.rebornpackaging.reborn_packaging/shopify_checkout"
        private const val PRESENT_CHECKOUT = "presentCheckout"
    }
}

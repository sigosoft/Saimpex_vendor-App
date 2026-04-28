import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/OrderDetailsModel.dart';
import 'package:saimpex_vendor/utils/printing/bluetooth_escpos_printer.dart';
import 'package:saimpex_vendor/utils/printing/esc_pos_receipt_builder.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class OrderPrintService {
  final EscPosReceiptBuilder _receiptBuilder;
  final BluetoothEscPosPrinter _printer;

  OrderPrintService({
    EscPosReceiptBuilder? receiptBuilder,
    BluetoothEscPosPrinter? printer,
  }) : _receiptBuilder = receiptBuilder ?? EscPosReceiptBuilder(),
       _printer = printer ?? BluetoothEscPosPrinter();

  Future<EscPosReceiptBuildResult> generateOrderPrintPayload({
    required String orderId,
    String? orderType,
  }) async {
    final data = await _fetchOrderDetails(orderId: orderId, orderType: orderType);

    // Resolve vendor/store name from saved preferences
    final vendorName =
        (await getSavedObject('storeName'))?.toString().trim() ??
        (await getSavedObject('vendorName'))?.toString().trim() ??
        (await getSavedObject('restaurantName'))?.toString().trim() ??
        '';

    return _receiptBuilder.buildReceipt(
      data,
      vendorName: vendorName.isNotEmpty ? vendorName : null,
      feedLines: 6, // ensures full feed before cutter
      withCut: true, // explicit cut command
    );
  }

  Future<EscPosReceiptBuildResult> printOrder({
    required String orderId,
    String? orderType,
    String? printerAddress,
  }) async {
    final payload = await generateOrderPrintPayload(
      orderId: orderId,
      orderType: orderType,
    );

    await _printer.printBytes(
      printerAddress: printerAddress ?? await _resolvePrinterAddressOrNull(),
      bytes80mm: payload.bytes80mm,
      bytes58mm: payload.bytes58mm,
    );
    return payload;
  }

  Future<Data> _fetchOrderDetails({
    required String orderId,
    String? orderType,
  }) async {
    final token = await getSavedObject('token');
    DioClient().updateToken(token);

    final vendorType = (await getSavedObject('vendorType'))?.toString() ?? '1';
    final isRestaurant =
        orderType?.toLowerCase().contains('restaurant') == true ||
        (orderType?.toLowerCase().contains('grocery') != true && vendorType == '1');

    final endpoint = isRestaurant
        ? ApiEndPoints.restaurantOrderDetails
        : ApiEndPoints.groceryOrderDetails;

    final response = await DioClient().get(
      endpoint,
      query: {'order_id': orderId},
    );
    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw Exception('Invalid order details response');
    }

    final model = OrderDetailsModel.fromJson(raw);
    if (model.status?.toString() != 'true' || model.data == null) {
      throw Exception('Unable to load order details for printing');
    }

    return model.data!;
  }

  Future<String?> _resolvePrinterAddressOrNull() async {
    final candidates = <String?>[
      (await getSavedObject('printerAddress'))?.toString(),
      (await getSavedObject('printerMacAddress'))?.toString(),
      (await getSavedObject('bluetoothPrinterAddress'))?.toString(),
    ];
    final picked = candidates
        .map((e) => e?.trim())
        .firstWhere(
          (e) => e != null && e.isNotEmpty && e.toLowerCase() != 'null',
          orElse: () => null,
        );
    return picked;
  }
}

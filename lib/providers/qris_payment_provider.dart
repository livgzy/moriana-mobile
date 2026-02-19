import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrisPaymentProvider extends ChangeNotifier {
  final String orderId;
  final OrderProvider orderProvider;

  QrisPaymentProvider( this.orderId, this.orderProvider,) {
    _listenOrder();
  }

  final _supabase = Supabase.instance.client;

  static const String qrisStaticPath = 'qris.jpg';

  Duration _remaining = Duration.zero;
  Duration get remaining => _remaining;

  bool _expired = false;
  bool get expired => _expired;

  String _orderStatus = 'Pending';
  String get orderStatus => _orderStatus;

  bool get isProcessing => _orderStatus == 'Process';
  bool get isPending => _orderStatus == 'Pending';
  bool get canCancel {
    return isPending && !_expired && remaining.inSeconds > 0;
  }

  bool isLoading = true;

  String? _qrisUrl;
  String? get qrisUrl => _qrisUrl;

  StreamSubscription<DocumentSnapshot>? _orderSub;
  Timer? _ticker;

void _listenOrder() {
  isLoading = true;

  _orderSub = FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .listen((doc) async {
    if (!doc.exists) return;

    final data = doc.data()!;
    _orderStatus = data['status'] ?? "Pending";

    if (_orderStatus == "Process") {
      _expired = false;
      _qrisUrl = null;
      isLoading = false;
      _disposeInternal();
      notifyListeners();
      return;
    }

    final Timestamp? expiredTs = data['expiredTime'];
    if (expiredTs == null) {
      isLoading = false;
      notifyListeners();
      return;
    };


    final expiredAt = expiredTs.toDate();
    _startCountdown(expiredAt);

    if (_qrisUrl == null && !_expired) {
      await _generateSignedQrisUrl(expiredAt);
    }
    
    isLoading = false;
    notifyListeners();
  });
}


Future<void> _generateSignedQrisUrl(DateTime expiredAt) async {
  try {
    final seconds = expiredAt
        .difference(DateTime.now())
        .inSeconds
        .clamp(1, 3600);

    debugPrint("Generate QRIS signed URL...");
    debugPrint("Bucket: qris");
    debugPrint("Path  : $qrisStaticPath");

    final url = await _supabase.storage
        .from('payment')
        .createSignedUrl("qris.jpg", seconds);

    _qrisUrl = url;
    debugPrint("QRIS URL SUCCESS: $url");
    notifyListeners();
  } catch (e) {
    debugPrint("FAILED generate QRIS URL: $e");
    _qrisUrl = null;
    notifyListeners();
  }
}

  void _startCountdown(DateTime expiredAt) {
  _ticker?.cancel();

  _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
    final diff = expiredAt.difference(DateTime.now());

    if (diff.isNegative || diff.inSeconds <= 0) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
            'status': 'Expired',
          });
    
      await orderProvider.fetchOrdersForUser();

      _expired = true;
      _remaining = Duration.zero;

      notifyListeners();
      _disposeInternal();
    } else {
      _remaining = diff;
      notifyListeners();
    }
  });
}


  String get formattedTime {
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _disposeInternal() {
    _ticker?.cancel();
    _orderSub?.cancel();
  }

  @override
  void dispose() {
    _disposeInternal();
    super.dispose();
  }
}



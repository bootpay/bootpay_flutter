import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/bootpay_helper.dart';

/// 본인인증 화면 (Android AuthenticationActivity / iOS AuthenticationController)
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String _selectedPg = '다날';
  final List<String> _pgList = ['다날', 'KCP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('본인인증'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 60, color: Colors.indigo[300]),
                        const SizedBox(height: 8),
                        Text('본인인증', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[700])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('휴대폰 본인인증', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '휴대폰 번호를 통해 본인임을 확인합니다.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.indigo[700]),
                            const SizedBox(width: 8),
                            Text('본인인증 안내', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo[700])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• 이름, 생년월일, 성별, 휴대폰 번호를 통해 본인 확인\n• SMS 인증번호를 통한 본인인증\n• 회원가입, 성인인증 등에 활용 가능',
                          style: TextStyle(fontSize: 13, color: Colors.indigo[900], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // 인증 업체 선택
                  const Text('인증 업체 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...List.generate(_pgList.length, (index) {
                    final pg = _pgList[index];
                    return _buildRadioTile(pg, _selectedPg == pg, () => setState(() => _selectedPg = pg));
                  }),
                ],
              ),
            ),
          ),
          _buildAuthButton(),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.indigo : Colors.grey[300]!, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Colors.indigo : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _requestAuthentication,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              '본인인증 시작',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _requestAuthentication() {
    Payload payload = Payload();
    payload.webApplicationId = BootpayHelper.webApplicationId;
    payload.androidApplicationId = BootpayHelper.androidApplicationId;
    payload.iosApplicationId = BootpayHelper.iosApplicationId;

    payload.pg = _selectedPg;
    payload.method = '본인인증';
    payload.orderName = '본인인증';
    payload.authenticationId = DateTime.now().millisecondsSinceEpoch.toString();
    payload.items = null;

    User user = User();
    user.id = 'user_1234';
    user.username = '홍길동';
    user.phone = '01012345678';
    payload.user = user;

    Extra extra = Extra();
    extra.openType = 'iframe';
    payload.extra = extra;

    Bootpay().requestAuthentication(
      context: context,
      payload: payload,
      showCloseButton: false,
      onCancel: (String data) => debugPrint('------- onCancel: $data'),
      onError: (String data) => debugPrint('------- onError: $data'),
      onClose: () {
        debugPrint('------- onClose');
        if (!kIsWeb) Bootpay().dismiss(context);
      },
      onIssued: (String data) => debugPrint('------- onIssued: $data'),
      onConfirm: (String data) => true,
      onDone: (String data) {
        debugPrint('------- onDone: $data');
        _showAuthenticationResult(data);
      },
    );
  }

  void _showAuthenticationResult(String data) {
    debugPrint('[Authentication] _showAuthenticationResult called');
    debugPrint('[Authentication] data: $data');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _AuthenticationResultPage(data: data)),
    );
    debugPrint('[Authentication] Navigator.pushReplacement called');
  }
}

class _AuthenticationResultPage extends StatelessWidget {
  final String data;
  const _AuthenticationResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? parsedData;
    try { parsedData = json.decode(data); } catch (e) { parsedData = null; }

    final eventData = parsedData?['data'] as Map<String, dynamic>?;
    final receiptId = eventData?['receipt_id'] ?? '';
    final pg = eventData?['pg'] ?? '';
    final authenticateAt = eventData?['authenticate_at'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('인증 완료'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: Colors.green, size: 80),
                    const SizedBox(height: 24),
                    const Text('본인인증 완료', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('본인인증이 성공적으로 완료되었습니다', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    _buildInfoRow('인증업체', pg),
                    _buildInfoRow('영수증ID', receiptId),
                    _buildInfoRow('인증일시', authenticateAt),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

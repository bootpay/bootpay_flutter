import 'package:bootpay/bootpay.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:flutter/material.dart';

/// 팝업(window.open / target="_blank") 닫기 버튼 동작 수동 검증 화면.
///
/// SDK 가 실제로 쓰는 fork WebView(`bootpay_webview_flutter`) 로 테스트 페이지를
/// 띄우고, 거기서 팝업을 직접 열어 네이티브 팝업 경로
/// (Android `WebChromeClient.onCreateWindow`, iOS `WKUIDelegate.createWebViewWith`)
/// 를 그대로 태운다.
///
/// 호스트 WebView 를 일부러 **화면 일부(테두리 박스)**에만 둔다. 팝업이 그 박스를
/// 벗어나 화면 전체를 덮는지로 "전체화면 부착"을 눈으로 검증하기 위함이다.
/// - Android 팝업은 Activity decorView 에 full-screen 으로 붙고,
/// - iOS 팝업도 opener 의 **window**(전체화면)에 붙으므로 opener 가 화면 일부만
///   차지해도 팝업은 항상 full-screen 이 된다.
///
/// 닫기 UI 는 팝업 위에 겹쳐 뜨는 **반투명 플로팅 ✕ 버튼 하나**다(상단 바 없음).
/// 노출 여부는 상단 토글로 `Bootpay.setPopupCloseButtonMode(...)` 를 호출해 제어한다.
///
/// 검증 포인트:
/// 1. `auto`(기본): 광고 도메인(doubleclick.net 등) 팝업 → 전체화면 + 우상단 ✕.
///    광고가 아닌 일반/결제성 팝업 → ✕ 없이 전체화면, JS `window.close()` 로 닫힘.
/// 2. `always`: 모든 팝업에 ✕ 노출.
/// 3. `never`: 어떤 팝업에도 ✕ 미노출.
/// 4. `Bootpay.addPopupAdHosts([...])` 로 런타임에 광고 도메인을 추가하면(auto 모드)
///    그 도메인 팝업에도 ✕ 가 뜬다.
/// 5. `Bootpay.closePopupWebView()` 로 현재 떠 있는 팝업을 코드로 즉시 닫는다
///    (개발자가 광고 종료 이벤트를 받았을 때 호출하는 시나리오).
///
/// ✕ 버튼은 팝업/광고를 차단하지 않는다 — 광고는 항상 인앱에 그대로 표시되고,
/// 버튼은 "스스로 닫지 않는 광고 페이지"에서 빠져나올 escape hatch 일 뿐이다.
class PopupAdTestScreen extends StatefulWidget {
  const PopupAdTestScreen({Key? key}) : super(key: key);

  @override
  State<PopupAdTestScreen> createState() => _PopupAdTestScreenState();
}

class _PopupAdTestScreenState extends State<PopupAdTestScreen> {
  late final WebViewController _controller;

  /// 현재 적용된 닫기 버튼 노출 모드. 기본값은 SDK 기본과 동일한 auto.
  BootpayPopupCloseButtonMode _mode = BootpayPopupCloseButtonMode.auto;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      // HTML 안의 "주입" 버튼이 이 채널로 호출 → Dart 가 광고 호스트를 런타임 추가.
      ..addJavaScriptChannel(
        'InjectAdHost',
        onMessageReceived: (JavaScriptMessage message) => _injectExampleHost(),
      )
      ..loadHtmlString(_hostHtml);
  }

  /// example.com 을 광고 호스트로 런타임 주입하고, 숨겨둔 확장 테스트 버튼을 노출.
  Future<void> _injectExampleHost() async {
    await Bootpay.addPopupAdHosts(['example.com']);
    await _controller.runJavaScript(
      "document.getElementById('ext-btn').style.display='block';"
      "var ib=document.getElementById('inject-btn'); if(ib){ ib.disabled=true; }"
      "log('addPopupAdHosts([example.com]) 주입 완료 → 아래 ④ 버튼으로 확인');",
    );
  }

  /// 닫기 버튼 노출 모드를 변경한다.
  Future<void> _setMode(BootpayPopupCloseButtonMode mode) async {
    await Bootpay.setPopupCloseButtonMode(mode);
    setState(() => _mode = mode);
  }

  /// 현재 떠 있는 팝업을 코드로 닫는다.
  Future<void> _closePopup() async {
    await Bootpay.closePopupWebView();
  }

  @override
  Widget build(BuildContext context) {
    // host WebView 를 일부러 화면 일부(테두리 박스)에만 둔다. 팝업이 이 박스를
    // 벗어나 화면 전체를 덮으면 iOS "전체화면 부착" 수정이 정상 동작하는 것.
    // (production 의 Bootpay WebView 는 전체화면이라 팝업도 자연히 전체화면이 된다.)
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECEF),
      appBar: AppBar(
        title: const Text('팝업 닫기 ✕ 버튼 테스트'),
        backgroundColor: const Color(0xFF3182F6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '아래 회색 테두리 박스가 host WebView(화면 일부)입니다.\n'
              '팝업 버튼을 누르면 이 박스를 벗어나 화면 전체로 떠야 정상이고,\n'
              '닫기 UI 는 우상단에 겹쳐 뜨는 반투명 ✕ 버튼 하나입니다.',
              style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFADB5BD), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '✕ 버튼 노출 모드 (setPopupCloseButtonMode)',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF343A40)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _modeButton(BootpayPopupCloseButtonMode.auto, 'auto\n(광고만)'),
                      const SizedBox(width: 8),
                      _modeButton(BootpayPopupCloseButtonMode.always, 'always\n(전부)'),
                      const SizedBox(width: 8),
                      _modeButton(BootpayPopupCloseButtonMode.never, 'never\n(없음)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _closePopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE03131),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      '현재 팝업 닫기 (closePopupWebView)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '광고 종료 이벤트를 받았다고 가정하고 코드로 팝업을 닫는 경로입니다.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF868E96), height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(BootpayPopupCloseButtonMode mode, String label) {
    final bool selected = _mode == mode;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _setMode(mode),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF3182F6) : Colors.white,
          foregroundColor: selected ? Colors.white : const Color(0xFF495057),
          side: BorderSide(
            color: selected ? const Color(0xFF3182F6) : const Color(0xFFCED4DA),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
        ),
      ),
    );
  }

  /// WebView 에 로드되는 호스트 페이지. 버튼들이 팝업을 띄운다.
  /// - ② 일반 팝업은 `window.open('')` + `document.write` 로 만든다. 최신 WebKit/
  ///   Chromium 은 top-level `data:` 내비게이션을 차단하므로 about:blank 에 직접
  ///   write 하는 방식을 쓴다. host 가 없어 광고로 분류되지 않으니 auto 모드에서는
  ///   ✕ 가 없어야 하고, 페이지 안의 `window.close()` 버튼으로 결제창처럼 닫힌다.
  static const String _hostHtml = r'''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <style>
    body { font-family: -apple-system, sans-serif; margin: 0; padding: 20px; background:#fff; color:#191f28; }
    h1 { font-size: 18px; }
    p { font-size: 13px; color:#4e5968; line-height:1.5; }
    button, .btn {
      display:block; width:100%; box-sizing:border-box; margin:10px 0;
      padding:16px; font-size:15px; font-weight:600; border:0; border-radius:10px;
      color:#fff; text-align:center; text-decoration:none;
    }
    .ad { background:#e8590c; }
    .normal { background:#3182f6; }
    .inject { background:#0ca678; }
    .ext { background:#7048e8; }
    button:disabled { opacity:0.5; }
    .tag { font-size:11px; font-weight:400; opacity:0.9; }
    #log { margin-top:14px; padding:12px; background:#f2f4f6; border-radius:8px;
           font-size:12px; color:#3182f6; min-height:18px; }
  </style>
</head>
<body>
  <h1>팝업 닫기 ✕ 버튼 테스트</h1>
  <p>auto 모드 기준:<br>
     ① · ③ · ④ = 광고 도메인 → <b>전체화면 + 우상단 ✕</b><br>
     ② = 일반/결제성 팝업 → <b>전체화면, ✕ 없음</b>, 안의 버튼으로 닫힘<br>
     (always 모드면 ② 에도 ✕, never 모드면 어디에도 ✕ 없음)</p>

  <button class="ad" onclick="openAd()">
    ① 광고 팝업 (doubleclick.net)<br><span class="tag">window.open → ✕ 떠야 함</span>
  </button>

  <button class="normal" onclick="openNormal()">
    ② 일반/결제성 팝업<br><span class="tag">auto 면 ✕ 없이 전체화면 · 팝업 안 버튼으로 닫기</span>
  </button>

  <a class="btn ad" href="https://googlesyndication.com" target="_blank" rel="noopener">
    ③ 광고 링크 target="_blank" (googlesyndication)<br><span class="tag">앵커 경로 → ✕ 떠야 함</span>
  </a>

  <button id="inject-btn" class="inject" onclick="inject()">
    ↳ 광고 호스트 주입: addPopupAdHosts(['example.com'])<br><span class="tag">주입 후 ④ 버튼 노출</span>
  </button>

  <button id="ext-btn" class="ext" style="display:none" onclick="openExample()">
    ④ 확장 테스트: example.com 팝업<br><span class="tag">주입 후 → ✕ 떠야 함</span>
  </button>

  <div id="log">버튼을 눌러 팝업을 띄워보세요.</div>

  <script>
    function log(m){ document.getElementById('log').textContent = m; }

    function openAd(){
      var w = window.open('https://www.doubleclick.net/', '_blank');
      log(w ? '① 광고 팝업 열림 → 우상단 ✕ 확인' : '① 팝업이 차단되었습니다');
    }

    function openNormal(){
      var w = window.open('', '_blank');
      if(!w){ log('② 팝업이 차단되었습니다'); return; }
      w.document.write(`<!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <style>body{font-family:-apple-system,sans-serif;padding:24px;color:#191f28}
        h2{font-size:18px}p{font-size:14px;color:#4e5968;line-height:1.6}
        button{margin-top:16px;font-size:16px;padding:14px 24px;border:0;border-radius:8px;background:#3182f6;color:#fff}</style>
        </head><body><h2>일반 / 결제성 팝업</h2>
        <p>광고 도메인이 아니므로 auto 모드에서는 <b>✕ 없이 전체화면</b>으로 떠야 정상입니다.</p>
        <p>결제창과 동일하게 JS 로 스스로 닫힙니다 ↓</p>
        <button onclick="window.close()">window.close() 로 닫기</button>
        </body></html>`);
      w.document.close();
      log('② 일반 팝업 열림 → auto 면 ✕ 없이 전체화면, 안의 버튼으로 닫기');
    }

    function inject(){
      if(window.InjectAdHost && window.InjectAdHost.postMessage){
        window.InjectAdHost.postMessage('example.com');
      } else {
        log('InjectAdHost 채널을 찾을 수 없습니다');
      }
    }

    function openExample(){
      var w = window.open('https://example.com/', '_blank');
      log(w ? '④ example.com 팝업 열림 → 주입했으면 ✕ 확인' : '④ 팝업이 차단되었습니다');
    }
  </script>
</body>
</html>
''';
}

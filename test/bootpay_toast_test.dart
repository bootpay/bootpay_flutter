import 'package:bootpay/widget/bootpay_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const msg = "'뒤로' 버튼을 한번 더 눌러주세요.";

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })),
    ));
    return ctx;
  }

  testWidgets('메시지를 표시하고 duration 뒤에 사라진다', (tester) async {
    final ctx = await pumpHost(tester);

    BootpayToast.show(ctx, msg);
    await tester.pump();
    expect(find.text(msg), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('연속 호출하면 하나만 남는다', (tester) async {
    final ctx = await pumpHost(tester);

    BootpayToast.show(ctx, msg);
    await tester.pump(const Duration(milliseconds: 500));
    BootpayToast.show(ctx, msg);
    await tester.pump();
    expect(find.text(msg), findsOneWidget);

    // 두 번째 호출 기준으로 2초가 다시 흐른다
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text(msg), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text(msg), findsNothing);
  });

  testWidgets('터치를 가로채지 않는다', (tester) async {
    var tapped = 0;
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return SizedBox.expand(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tapped++,
          ),
        );
      })),
    ));

    BootpayToast.show(ctx, msg);
    await tester.pump();
    await tester.tap(find.text(msg), warnIfMissed: false);
    expect(tapped, 1);

    await tester.pump(const Duration(seconds: 2));
  });
}

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('testing testing one two testing', (tester) async {
    await tester.pumpWidget(
      MyApp(items: List<String>.generate(10_000, (i) => 'Item $i')),
    );

    final listFinder = find.byType(Scrollable);
    final itemFinder = find.byKey(const ValueKey('item_500_text'));

    Timer.periodic(
      Duration(milliseconds: 600),
      (timer) {
        final performance = web.window.performance;
        final memory = performance.getProperty("memory".toJS) as JSObject;
        final jsHeapSizeLimit = memory.getProperty("jsHeapSizeLimit".toJS);
        final totalJSHeapSize = memory.getProperty("totalJSHeapSize".toJS);
        final usedJSHeapSize = memory.getProperty("usedJSHeapSize".toJS);

        print("jsHeapSizeLimit: $jsHeapSizeLimit");
        print("totalJSHeapSize: $totalJSHeapSize");
        print("usedJSHeapSize: $usedJSHeapSize");
      },
    );

    await tester.scrollUntilVisible(
      itemFinder,
      500,
      scrollable: listFinder,
    );
  });
}

class MyApp extends StatelessWidget {
  final List<String> items;
  const MyApp({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const title = 'Long List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(title: const Text(title)),
        body: ListView.builder(
          key: const Key('long_list'),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                key: Key('item_${index}_text'),
                items[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

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

    await tester.scrollUntilVisible(
      itemFinder,
      500,
      scrollable: listFinder,
    );
    final result = await measureMemoryUsageInBytes();
    print("memory usage: $result bytes");
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

/// Estimates the memory usage of the DevTools web aplication, including all
/// iFrames and workers.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/Performance/measureUserAgentSpecificMemory.
Future<int?> measureMemoryUsageInBytes() async {
  // Use of this API requires a secure context and cross origin isolation.
  print(
    'isSecureContext: ${web.window.isSecureContext}, '
    'crossOriginIsolated: ${web.window.crossOriginIsolated}',
  );
  if (web.window.isSecureContext && web.window.crossOriginIsolated) {
    final memory = await web.window.performance
        .measureUserAgentSpecificMemory();
    return memory?.bytes;
  }
  return null;
}

extension on web.Performance {
  @JS('measureUserAgentSpecificMemory')
  external JSPromise<_UserAgentSpecificMemory>
  _measureUserAgentSpecificMemory();

  Future<_UserAgentSpecificMemory>? measureUserAgentSpecificMemory() =>
      has('measureUserAgentSpecificMemory')
      ? _measureUserAgentSpecificMemory().toDart
      : null;
}

@JS()
extension type _UserAgentSpecificMemory._(JSObject _) implements JSObject {
  external int get bytes;

  external JSArray<_UserAgentSpecificMemoryBreakdownElement> get breakdown;
}

@JS()
extension type _UserAgentSpecificMemoryBreakdownElement._(JSObject _)
    implements JSObject {
  external JSArray<_UserAgentSpecificMemoryBreakdownAttributionElement>
  get attribution;

  external int get bytes;

  external JSArray<JSString> get types;
}

@JS()
extension type _UserAgentSpecificMemoryBreakdownAttributionElement._(JSObject _)
    implements JSObject {
  external _UserAgentSpecificMemoryBreakdownAttributionContainerElement?
  get container;

  external String get scope;

  external String get url;
}

@JS()
extension type _UserAgentSpecificMemoryBreakdownAttributionContainerElement._(
  JSObject _
)
    implements JSObject {
  external String get id;

  external String get url;
}

# flutter_oauth_wasm

To run the flutter driver test, paste this on your terminal:
```sh
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/my_test.dart \
  -d chrome \
  --web-header=cross-origin-opener-policy=same-origin \
  --web-header=cross-origin-embedder-policy=credentialless
```

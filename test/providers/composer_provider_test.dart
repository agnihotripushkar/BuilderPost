import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/providers/composer_provider.dart';
import 'package:my_app/providers/service_providers.dart';
import 'package:my_app/services/gemini_service.dart';

/// Fake that streams canned cumulative chunks instead of hitting the network.
class FakeGeminiService extends GeminiService {
  FakeGeminiService() : super('fake-key');

  int callCount = 0;

  @override
  Stream<String> generatePostStream({
    required String description,
    required String platform,
    required String tone,
    List<String> imagePaths = const [],
    String? readmeContent,
    String? projectUrl,
  }) async* {
    callCount++;
    yield 'Hello';
    yield 'Hello world';
  }
}

ProviderContainer _container({String? apiKey, FakeGeminiService? fake}) {
  final fakeService = fake ?? FakeGeminiService();
  return ProviderContainer(
    overrides: [
      apiKeyProvider.overrideWith((ref) async => apiKey),
      geminiServiceFactoryProvider.overrideWithValue((_) => fakeService),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('generate() produces 3 variations and finishes done', () async {
    final fake = FakeGeminiService();
    final c = _container(apiKey: 'k', fake: fake);
    addTearDown(c.dispose);

    final notifier = c.read(composerProvider.notifier);
    notifier.updateDescription('A cool project');
    await notifier.generate();

    final state = c.read(composerProvider);
    expect(state.status, ComposerStatus.done);
    expect(state.generatedPosts, hasLength(3));
    expect(state.generatedPosts!.every((p) => p.content == 'Hello world'), isTrue);
    expect(state.streamingText, isEmpty); // cleared when done
    expect(fake.callCount, 3); // one stream per variation
  });

  test('streamingText updates live during generation', () async {
    final c = _container(apiKey: 'k');
    addTearDown(c.dispose);

    final seen = <String>[];
    c.listen(composerProvider, (_, next) {
      if (next.streamingText.isNotEmpty) seen.add(next.streamingText);
    });

    await c.read(composerProvider.notifier).generate();

    // First variation drove the live preview through both cumulative chunks.
    expect(seen, containsAllInOrder(['Hello', 'Hello world']));
  });

  test('generate() with no API key sets an error', () async {
    final c = _container(apiKey: null);
    addTearDown(c.dispose);

    await c.read(composerProvider.notifier).generate();

    final state = c.read(composerProvider);
    expect(state.status, ComposerStatus.error);
    expect(state.errorMessage, contains('API key'));
  });
}

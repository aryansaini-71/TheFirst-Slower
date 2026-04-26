//Creator - Aryan saini
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. THIS IS THE ONLY MAIN FUNCTION - It initializes the connection to your warehouse
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pkstzxkoyzcrlsybaums.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrc3R6eGtveXpjcmxzeWJhdW1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNjY2MTEsImV4cCI6MjA5MjY0MjYxMX0.-MZufmWstt8VkUW7hiplX1tTANVtLa99FjGECntg0ug',
  );

  runApp(const SlowerApp());
}

class SlowerApp extends StatelessWidget {
  const SlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SlowerHome(),
    );
  }
}

class SlowerHome extends StatefulWidget {
  const SlowerHome({super.key});

  @override
  State<SlowerHome> createState() => _SlowerHomeState();
}

class _SlowerHomeState extends State<SlowerHome> {
  String memeUrl = "";
  String memeTitle = "TAKE A DEEP BREATH...";
  String? nextMemeUrl;
  String? nextMemeTitle;
  String timeRemaining = "00:00";
  Timer? _timer;
  int categoryIndex = 0;
  List<String> categories = [
    "memes",
    "wholesomememes",
    "historymemes",
    "sciencememes",
  ];
  int skipsRemaining = 3;

  @override
  void initState() {
    super.initState();
    initialLoad();
    _startTimer();
  }

  Future<void> initialLoad() async {
    await fetchMeme();
    prefetchNextMeme();
  }

  // --- FETCHING WITH ROTATING PROXY ---
  Future<void> fetchMeme() async {
    setState(() {
      memeUrl = "";
      memeTitle = "OPENING THE WAREHOUSE...";
    });

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('memes')
          .select()
          .eq('category', categories[categoryIndex])
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        String originalUrl = data['url'];
        setState(() {
          // We switch to 'wsrv.nl' - it's a high-speed image proxy that is GREAT for Flutter
          memeUrl = "https://wsrv.nl/?url=${Uri.encodeComponent(originalUrl)}";
          memeTitle = "${data['title'].toUpperCase()} (${data['ups']} 👍)";
        });
      } else {
        setState(() => memeTitle = "CATEGORY EMPTY! RUN THE BOT.");
      }
    } catch (e) {
      setState(() => memeTitle = "WAREHOUSE ERROR: CHECK CONNECTION");
    }
  }

  Future<void> prefetchNextMeme() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('memes')
          .select()
          .eq('category', categories[categoryIndex])
          .limit(1)
          .maybeSingle();

      if (data != null && mounted) {
        // Use the same wsrv.nl proxy here
        nextMemeUrl =
            "https://wsrv.nl/?url=${Uri.encodeComponent(data['url'])}";
        nextMemeTitle = "${data['title'].toUpperCase()} (${data['ups']} 👍)";
        precacheImage(NetworkImage(nextMemeUrl!), context);
      }
    } catch (e) {
      debugPrint("Prefetch status: Waiting for drop");
    }
  }

  void handleSkip() {
    _vibrate();
    if (nextMemeUrl != null && nextMemeUrl!.isNotEmpty) {
      setState(() {
        memeUrl = nextMemeUrl!;
        memeTitle = nextMemeTitle!;
        skipsRemaining--;
      });
      prefetchNextMeme();
    } else {
      setState(() => skipsRemaining--);
      fetchMeme();
      prefetchNextMeme();
    }
  }

  void _vibrate() => HapticFeedback.lightImpact();

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.minute % 10 == 0 && now.second == 0) handleSkip();

      setState(() {
        int mUntil = 9 - (now.minute % 10);
        int sUntil = 59 - now.second;
        timeRemaining =
            "${mUntil.toString().padLeft(2, '0')}:${sUntil.toString().padLeft(2, '0')}";
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "S  L  O  W  E  R",
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 8,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                _vibrate();
                setState(() {
                  categoryIndex = (categoryIndex + 1) % categories.length;
                  fetchMeme();
                  prefetchNextMeme();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "CATEGORY: ${categories[categoryIndex].toUpperCase()}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                memeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black26,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5D9C9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: memeUrl.isEmpty
                      ? const Center(
                          child: Text(
                            "Loading from warehouse...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.brown,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Image.network(
                            memeUrl,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Text(
                                    "Meme is shy... check proxy!",
                                    style: TextStyle(
                                      color: Colors.brown,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8DA082),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      "NEXT DROP IN",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      timeRemaining,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => debugPrint("Sharing..."),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "SHARE THIS MEME",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1A799),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: skipsRemaining > 0 ? handleSkip : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    backgroundColor: skipsRemaining > 0
                        ? const Color(0xFFFAFAFA)
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    skipsRemaining > 0
                        ? "SKIP THIS ($skipsRemaining LEFT TODAY)"
                        : "NO SKIPS LEFT. BE PATIENT.",
                    style: TextStyle(
                      color: skipsRemaining > 0
                          ? Colors.black26
                          : Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

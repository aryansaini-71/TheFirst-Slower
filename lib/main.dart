//Creator - Aryan saini
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
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

  Future<void> fetchMeme() async {
    setState(() {
      memeUrl = "";
      memeTitle = "FINDING A BANGER...";
    });

    try {
      final category = categories[categoryIndex];
      final response = await http.get(
        Uri.parse('https://meme-api.com/gimme/$category/10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List allMemes = data['memes'];

        allMemes.sort((a, b) => b['ups'].compareTo(a['ups']));
        var selectedMeme = allMemes.firstWhere(
          (m) => m['ups'] >= 4000,
          orElse: () => allMemes[0],
        );

        setState(() {
          // FIXED: Using string interpolation ${} instead of +
          // Use the 'cors-proxy.htmldriven.com' bridge - it is very friendly to Flutter
          memeUrl =
              "https://cors-proxy.htmldriven.com/?url=${Uri.encodeComponent(selectedMeme['url'])}";
          memeTitle =
              "${selectedMeme['title'].toUpperCase()} (${selectedMeme['ups']} 👍)";
        });
      }
    } catch (e) {
      setState(() => memeTitle = "OFFLINE... ENJOY THE SILENCE");
    }
  }

  Future<void> prefetchNextMeme() async {
    try {
      final category = categories[categoryIndex];
      final response = await http.get(
        Uri.parse('https://meme-api.com/gimme/$category/10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List allMemes = data['memes'];
        allMemes.sort((a, b) => b['ups'].compareTo(a['ups']));
        var selectedMeme = allMemes.firstWhere(
          (m) => m['ups'] >= 4000,
          orElse: () => allMemes[0],
        );

        // FIXED: Using string interpolation ${} and correct variable name
        nextMemeUrl =
            "https://api.allorigins.win/raw?url=${Uri.encodeComponent(selectedMeme['url'])}";
        nextMemeTitle =
            "${selectedMeme['title'].toUpperCase()} (${selectedMeme['ups']} 👍)";

        if (mounted) {
          precacheImage(NetworkImage(nextMemeUrl!), context);
        }
      }
    } catch (e) {
      debugPrint("Prefetch status: Waiting for next drop");
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

  void _vibrate() {
    HapticFeedback.lightImpact();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.minute % 10 == 0 && now.second == 0) {
        handleSkip();
      }

      setState(() {
        int minutesUntilNextDrop = 9 - (now.minute % 10);
        int secondsUntilNextDrop = 59 - now.second;
        String m = minutesUntilNextDrop.toString().padLeft(2, '0');
        String s = secondsUntilNextDrop.toString().padLeft(2, '0');
        timeRemaining = "$m:$s";
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
                            "Loading high-quality meme...",
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
                            // THE BACKUP PLAN: This helps the browser trust the image source
                            headers: const {"Access-Control-Allow-Origin": "*"},
                            // This keeps the previous image visible while the new one loads
                            gaplessPlayback: true,
                            frameBuilder: (context, child, frame, wasLoaded) {
                              if (wasLoaded) return child;
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 500),
                                child: child,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text(
                                  "Meme is shy... try changing category!",
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
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
                  onPressed: () {
                    _vibrate();
                    debugPrint("Sharing...");
                  },
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

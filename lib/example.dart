import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:hive/hive.dart';
import 'package:hive_d/user_model.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';


class Example extends StatefulWidget {
  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  Box? notepad;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _updateController = TextEditingController();

  //********Here Coding for Mobile Add

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;

  // Rewarded Ad
  RewardedAd? _rewardedAd;

  // Counter to switch ads
  int _adCounter = 0;

  /// ✅ Load Banner Ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/9214589741", // Here Replace real Ad Unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load Banner Ad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }
  /// ✅ Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712", // Replace with your real Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load Interstitial Ad: ${err.message}');
        },
      ),
    );
  }

  /// ✅ Show Interstitial Ad
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd(); // Load next one
    }
  }

  /// ✅ Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917", // Replace with your real Ad Unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load Rewarded Ad: ${err.message}');
        },
      ),
    );
  }

  /// ✅ Show Rewarded Ad
  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd = null;
      _loadRewardedAd(); // Load next one
    }
  }

  //When Add New Not button first save data then show add alternately
  void _showAd() {
    _adCounter++;

    if (_adCounter % 2 == 1) {
      // Odd = Interstitial
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadInterstitialAd(); // load next
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _loadInterstitialAd();
          },
        );
        _interstitialAd!.show();
        _interstitialAd = null;
      }
    } else {
      // Even = Rewarded
      if (_rewardedAd != null) {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _loadRewardedAd(); // load next
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _loadRewardedAd();
          },
        );
        _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            debugPrint("User earned: ${reward.amount} ${reward.type}");
          },
        );
        _rewardedAd = null;
      }
    }
  }

  //Here coding for Drawer
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Notepad++",
      applicationVersion: "1.0.0",
      applicationIcon: Icon(Icons.note, color: Colors.green),
      children: [
        Text("This is a simple Notepad app built with Flutter."),
      ],
    );
  }

  void _exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit App?"),
        content: Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => exit(0), // Force exit app
            child: Text("Exit", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  //Here Add Dispose
  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
    notepad = Hive.box('notepad');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notepad++', style: TextStyle(color: Colors.white)),
       // automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              accountName: Text(
                Hive.box<UserModel>('userBox').get('currentUser')?.name ?? "Guest",
              ),
              accountEmail: Text(
                Hive.box<UserModel>('userBox').get('currentUser')?.email ?? "",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: Hive.box<UserModel>('userBox')
                    .get('currentUser')
                    ?.imagePath !=
                    null
                    ? FileImage(File(
                    Hive.box<UserModel>('userBox').get('currentUser')!.imagePath))
                    : null,
                child: Hive.box<UserModel>('userBox').get('currentUser')?.imagePath ==
                    null
                    ? Icon(Icons.person, size: 40, color: Colors.green)
                    : null,
              ),
            ),

            // --- Drawer Menu Items ---
            ListTile(
              leading: Icon(Icons.home, color: Colors.green),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.pink),
              title: Text("Favorites"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm, color: Colors.orange),
              title: Text("Reminders"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.label, color: Colors.blue),
              title: Text("Tags"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Trash"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Colors.green),
              title: Text("About"),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text("Exit"),
              onTap: () {
                Navigator.pop(context);
                _exitApp(context);
              },
            ),

            Spacer(), // pushes footer to bottom

            // --- Footer Logout Button ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  onPressed: () async {
                    final userBox = Hive.box<UserModel>('userBox');
                    await userBox.delete('currentUser'); // clear login
                    Navigator.pop(context);

                    // Navigate back to login page
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Write something...'),
            ),

            // Add button
            Container(
              width: 400,
              margin: EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final userInput = _controller.text.trim();
                    if (userInput.isEmpty) return;

                    final now = DateTime.now();

                    await notepad!.add({
                      'text': userInput,
                      'timestamp': now.toIso8601String(),
                    });

                    _controller.clear();
                    Fluttertoast.showToast(msg: 'Added successfully');
                   // _showInterstitialAd();
                    _showAd();
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Add new note"),
              ),
              // ElevatedButton(
              //   onPressed: _showInterstitialAd,
              //   child: const Text("Show Interstitial Ad"),
              // ),
              // const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: _showRewardedAd,
              //   child: const Text("Show Rewarded Ad"),
              // ),
            ),

            // Notes list
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('notepad').listenable(),
                builder: (context, box, widget) {
                  final keys = box.keys.toList();

                  if (keys.isEmpty) {
                    return Center(
                      child: Text(
                        "No notes yet!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (_, index) {
                      final key = keys[index];
                      final item = box.get(key);

                      // Handle old String data
                      if (item is String) {
                        return _buildOldNoteCard(item);
                      }

                      // Handle new Map data
                      else if (item is Map) {
                        return _buildNewNoteCard(item, key, box);
                      }

                      // Unknown data type
                      else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      )
          : null,
    );
  }

  /// Card for old notes (String only, no timestamp)
  Widget _buildOldNoteCard(String text) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(text),
        subtitle: Text("Old data (no timestamp)"),
      ),
    );
  }

  /// Card for new notes (Map with text + timestamp)
  Widget _buildNewNoteCard(Map item, dynamic key, Box box) {
    final text = item['text'] ?? '';
    final timestamp = item['timestamp'];

    String formattedDate = '';
    if (timestamp != null) {
      formattedDate =
          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(timestamp));
    }

    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await box.delete(key);
        Fluttertoast.showToast(msg: 'Deleted successfully');
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(text),
          subtitle: Text(formattedDate),
          onLongPress: () {
            _updateController.text = text;
            showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _updateController,
                          decoration: InputDecoration(hintText: 'Update data'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final updatedData = _updateController.text.trim();
                            if (updatedData.isEmpty) return;

                            await box.put(key, {
                              'text': updatedData,
                              'timestamp': DateTime.now().toIso8601String(),
                            });
                            _updateController.clear();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Update'),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


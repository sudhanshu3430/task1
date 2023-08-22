import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Carousel',
      home: OnboardingCarousel(),
    );
  }
}

class OnboardingCarousel extends StatefulWidget {
  @override
  _OnboardingCarouselState createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  late PageController _pageController;
  List<String> _videoAssets = [
    'assets/videos/bg_video1.mp4',
    'assets/videos/bg_video4.mp4',
    'assets/videos/bg_video3.mp4',
  ];
  double _currentPage = 0;

  String? _accessToken;
  String? _newCardId;

  void updateAccessToken(String token) {
    setState(() {
      _accessToken = token;
    });
  }

  void updateNewCardId(String id) {
    setState(() {
      _newCardId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showAuthDialog(
      BuildContext context, String title, bool isLogin) async {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (isLogin) {
                  final success = await _login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (success) {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            accessToken: _accessToken!, newCardId: _newCardId!),
                      ),
                    );
                  }
                } else {
                  final success = await _register(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (success) {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            accessToken: _accessToken!, newCardId: _newCardId!),
                      ),
                    );
                  }
                }
              },
              child: Text(title),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _login(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://interview-api.onrender.com/v1/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String accessToken = responseBody['tokens']['access']['token'];
      String newCardId = responseBody['user']['id'];
      updateAccessToken(accessToken);
      updateNewCardId(newCardId);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _register(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://interview-api.onrender.com/v1/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String accessToken = responseBody['tokens']['access']['token'];
      String newCardId = responseBody['newCardId'];
      updateAccessToken(accessToken);
      updateNewCardId(newCardId);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _videoAssets.length,
            itemBuilder: (context, index) {
              return OnboardingScreen(videoAsset: _videoAssets[index]);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showAuthDialog(context, 'Sign In', true);
                        },
                        child: Text('Sign In'),
                      ),
                      SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          _showAuthDialog(context, 'Create Account', false);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DotsIndicator(
                    dotsCount: _videoAssets.length,
                    position: _currentPage,
                    decorator: DotsDecorator(
                      color: Colors.grey,
                      activeColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final String videoAsset;

  const OnboardingScreen({required this.videoAsset});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(_controller);
  }
}

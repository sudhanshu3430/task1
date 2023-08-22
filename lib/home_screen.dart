import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './new_screen.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  final String newCardId; // Include newCardId here

  HomeScreen({required this.accessToken, required this.newCardId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CreditCardData> creditCards = [];

  @override
  void initState() {
    super.initState();
    _fetchCreditCards();
  }

  Future<void> _fetchCreditCards() async {
    final apiUrl = 'https://interview-api.onrender.com/v1/cards';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${widget.accessToken}',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> results = responseData['results'];
      final List<CreditCardData> fetchedCards =
          results.map((cardData) => CreditCardData.fromJson(cardData)).toList();

      setState(() {
        creditCards = fetchedCards;
      });
    } else {
      print('Failed to fetch credit cards: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var card in creditCards)
                _buildCreditCard(
                  color: card.cardColor,
                  cardNumber: card.cardNumber,
                  cardHolder: card.cardHolder,
                  cardExpiration: card.cardExpiration,
                ),
              _buildAddCardButton(
                icon: Icon(Icons.add),
                color: Color(0xFF081603),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card _buildCreditCard(
      {required Color color,
      required String cardNumber,
      required String cardHolder,
      required String cardExpiration}) {
    return Card(
      elevation: 4.0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLogosBlock(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '$cardNumber',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontFamily: 'CourrierPrime'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDetailsBlock(
                  label: 'CARDHOLDER',
                  value: cardHolder,
                ),
                _buildDetailsBlock(label: 'VALID THRU', value: cardExpiration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset(
          "assets/images/contact_less.png",
          height: 20,
          width: 18,
        ),
        Image.asset(
          "assets/images/mastercard.png",
          height: 50,
          width: 50,
        ),
      ],
    );
  }

  Column _buildDetailsBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label',
          style: TextStyle(
              color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        Text(
          '$value',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Container _buildAddCardButton({
    required Icon icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 24.0),
      alignment: Alignment.center,
      child: FloatingActionButton(
        elevation: 2.0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewScreen(accessToken: widget.accessToken),
            ),
          );
        },
        backgroundColor: color,
        mini: false,
        child: icon,
      ),
    );
  }
}

class CreditCardData {
  final Color cardColor;
  final String cardNumber;
  final String cardHolder;
  final String cardExpiration;

  CreditCardData({
    required this.cardColor,
    required this.cardNumber,
    required this.cardHolder,
    required this.cardExpiration,
  });

  factory CreditCardData.fromJson(Map<String, dynamic> json) {
    final String cardCategory = json['category'];
    Color cardColor;

    if (cardCategory == 'VISA') {
      cardColor = Color(0xFF4285F4); // Blue color for VISA
    } else if (cardCategory == 'MC') {
      cardColor = Color(0xFFFF3B3A); // Red color for MasterCard
    } else {
      cardColor = Colors.grey; // Default color for other categories
    }

    return CreditCardData(
      cardColor: cardColor,
      cardNumber: json['cardNumber'],
      cardHolder: json['cardHolder'],
      cardExpiration: json['cardExpiration'],
    );
  }
}

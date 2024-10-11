import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'lunchtoken.dart';

class DisplayTokens extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userName;
  final VoidCallback onLogout;
  final String cafeteria;
  final String? date;
  final String meal;
  final String? tokens;

  const DisplayTokens({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
    required this.userName,
    required this.cafeteria,
    required this.date,
    required this.meal,
    required this.tokens,
  });

  @override
  State<DisplayTokens> createState() => _DisplayTokensState();
}

class _DisplayTokensState extends State<DisplayTokens> {
  late int tokenCount;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    tokenCount = int.tryParse(widget.tokens ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.25;

    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Tokens',
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: cardWidth / cardHeight,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        padding: EdgeInsets.all(screenWidth * 0.02),
        itemCount: tokenCount,
        itemBuilder: (context, index) {
          String meal = widget.meal;
          String date = widget.date ?? 'N/A';
          String tokenId = uuid.v4();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LunchToken(
                    userId: widget.userId,
                    userDept: widget.userDept,
                    onLogout: widget.onLogout,
                    userName: widget.userName,
                    cafeteria: widget.cafeteria,
                    date: date,
                    meal: meal,
                    tokenId: tokenId,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.secondaryHeaderColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.toUpperCase(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      tokenId.substring(0, 8),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

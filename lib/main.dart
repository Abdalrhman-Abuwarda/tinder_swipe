import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinder_swipe/provider/card_provider.dart';
import 'package:tinder_swipe/widget/tinder_card.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Tinder Clone';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => CardProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: const MainPage(),
      theme: ThemeData(
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 32),
            elevation: 8,
            primary: Colors.white,
            shape: const CircleBorder(),
            minimumSize: const Size.square(80),
          ),
        ),
      ),
    ),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.shade200,
          Colors.black,
        ],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Tinder',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: buildCards()),
              const SizedBox(height: 16),
              buildButtons(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget buildCards() {
    final provider = Provider.of<CardProvider>(context);
    final users = provider.users;

    return users.isEmpty
        ? const Center(
      child: Text(
        '💔  The End.',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    )
        : Stack(
      children: users.map((user) => TinderCard(
        user: user,
        isFront: users.last == user,
      ))
          .toList(),
    );
  }

  Widget buildButtons() {
    final provider = Provider.of<CardProvider>(context);
    final users = provider.users;
    final status = provider.getStatus();
    final isLike = status == CardStatus.like;
    final isDislike = status == CardStatus.dislike;
    final isSuperLike = status == CardStatus.superLike;

    return users.isEmpty
        ? ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        'Restart',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        final provider =
        Provider.of<CardProvider>(context, listen: false);

        provider.resetUsers();
      },
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor:
            getColor(Colors.red, Colors.white, isDislike),
            backgroundColor:
            getColor(Colors.white, Colors.red, isDislike),
            side: getBorder(Colors.red, Colors.white, isDislike),
          ),
          child: const Icon(Icons.clear, size: 46),
          onPressed: () {
            final provider =
            Provider.of<CardProvider>(context, listen: false);

            provider.dislike();
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor:
            getColor(Colors.blue, Colors.white, isSuperLike),
            backgroundColor:
            getColor(Colors.white, Colors.blue, isSuperLike),
            side: getBorder(Colors.blue, Colors.white, isSuperLike),
          ),
          child: const Icon(Icons.star, size: 40),
          onPressed: () {
            final provider =
            Provider.of<CardProvider>(context, listen: false);

            provider.superLike();
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            foregroundColor: getColor(Colors.teal, Colors.white, isLike),
            backgroundColor: getColor(Colors.white, Colors.teal, isLike),
            side: getBorder(Colors.teal, Colors.white, isLike),
          ),
          child: const Icon(Icons.favorite, size: 40),
          onPressed: () {
            final provider =
            Provider.of<CardProvider>(context, listen: false);

            provider.like();
          },
        ),
      ],
    );
  }

  MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed, bool force) {
    getColor(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }

  MaterialStateProperty<BorderSide> getBorder(
      Color color, Color colorPressed, bool force) {
    getBorder(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return const BorderSide(color: Colors.transparent);
      } else {
        return BorderSide(color: color, width: 2);
      }
    }

    return MaterialStateProperty.resolveWith(getBorder);
  }
}

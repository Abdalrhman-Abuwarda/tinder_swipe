import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../provider/card_provider.dart';
class TinderCard extends StatefulWidget {
  final User user;
  final bool isFront;

  const TinderCard({
    Key? key,
    required this.user,
    required this.isFront,
  }) : super(key: key);

  @override
  State<TinderCard> createState() => _TinderCardState();
}

class _TinderCardState extends State<TinderCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: widget.isFront ? buildFrontCard() : buildCard(),
      );

  Widget buildFrontCard() => GestureDetector(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = Provider.of<CardProvider>(context);
            final position = provider.position;
            final milliseconds = provider.isDragging ? 0 : 400;

            final center = constraints.smallest.center(Offset.zero);
            final angle = provider.angle * pi / 180;
            final rotatedMatrix = Matrix4.identity()
              ..translate(center.dx, center.dy)
              ..rotateZ(angle)
              ..translate(-center.dx, -center.dy);

            return AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: milliseconds),
              transform: rotatedMatrix..translate(position.dx, position.dy),
              child: Stack(
                children: [
                  buildCard(),
                  buildStamps(),
                ],
              ),
            );
          },
        ),
        onPanStart: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);

          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);

          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);

          provider.endPosition();
        },
      );

  Widget buildCard() => buildCardShadow(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.user.urlImage),
                fit: BoxFit.cover,
                alignment: Alignment(-0.3, 0),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  stops: [0.2, 1],
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Spacer(),
                  buildName(),
                  const SizedBox(height: 8),
                  buildActive(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildCardShadow({required Widget child}) => ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.white12,
              ),
            ],
          ),
          child: child,
        ),
      );

  Widget buildStamps() {
    final provider = Provider.of<CardProvider>(context);
    final status = provider.getStatus();
    final opacity = provider.getStatusOpacity();

    switch (status) {
      case CardStatus.like:
        final child = buildStamp(
          angle: -0.5,
          color: Colors.green,
          text: 'LIKE',
          opacity: opacity,
        );

        return Positioned(top: 64, left: 50, child: child);
      case CardStatus.dislike:
        final child = buildStamp(
          angle: 0.5,
          color: Colors.red,
          text: 'NOPE',
          opacity: opacity,
        );

        return Positioned(top: 64, right: 50, child: child);
      case CardStatus.superLike:
        final child = Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 8)
              ],
            ),
            child: buildStamp(
              color: Colors.blue,
              text: 'SUPER\nLIKE',
              opacity: opacity,
            ),
          ),
        );

        return Positioned(bottom: 128, right: 0, left: 0, child: child);
      default:
        return Container();
    }
  }

  Widget buildStamp({
    double angle = 0,
    required Color color,
    required String text,
    required double opacity,
  }) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActive() => Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            width: 12,
            height: 12,
          ),
          const SizedBox(width: 8),
          Text(
            'Recently Active',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      );

  Widget buildName() => Row(
        children: [
          Text(
            widget.user.name,
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${widget.user.age}',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ],
      );
}

import 'package:flutter/material.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';

class SwipeToBookButton extends StatefulWidget {
  final String title;
  final Function onDragEnd;
  const SwipeToBookButton(
      {super.key, required this.title, required this.onDragEnd});

  @override
  _SwipeToBookButtonState createState() => _SwipeToBookButtonState();
}

class _SwipeToBookButtonState extends State<SwipeToBookButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  double _dragPosition = 0.0;
  bool _isBookingConfirmed = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Control wave speed here
    )..repeat(reverse: true); // Repeat the animation in reverse

    // Define a sine wave-like animation
    _waveAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/buttton_bg.png"),
            fit: BoxFit.cover,
          ),
          color: ThemeClass.facebookBlue,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            // Swipe to Book Text (centered)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _isBookingConfirmed ? 'Booking Confirmed!' : widget.title,
                  style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                ),
              ),
            ),
            // Draggable Button
            Positioned(
              left: _dragPosition, // Position based on drag
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragPosition += details.delta.dx;
                    // Limit drag position within container bounds
                    if (_dragPosition < 0) _dragPosition = 0;
                    if (_dragPosition >
                        MediaQuery.of(context).size.width - 100) {
                      _dragPosition = MediaQuery.of(context).size.width - 100;
                      _isBookingConfirmed = true; // If dragged to the end
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (!_isBookingConfirmed) {
                    // Reset position if not fully swiped
                    setState(() {
                      _dragPosition = 0;
                    });
                  } else {
                    // Navigate or show booking confirmation
                    // Navigator.pushNamed(context, '/bookingConfirmation');
                    widget.onDragEnd();
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: ThemeClass.facebookBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The main [MaterialApp] widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: MacBookDockBar(),
        ),
      ),
    );
  }
}

class MacBookDockBar extends StatefulWidget {
  const MacBookDockBar({super.key});

  @override
  State<MacBookDockBar> createState() => _MacBookDockBarState();
}

class _MacBookDockBarState extends State<MacBookDockBar>
    with TickerProviderStateMixin {
  /// List of icons in the dock.
  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.settings,
    Icons.camera,
    Icons.notifications,
    Icons.email,
    Icons.music_note,
    Icons.shopping_cart,
    Icons.cloud,
  ];

  /// Index of the icon currently hovered over.
  int _hoveredIndex = -1;

  /// Proximity factor for spacing animation.
  double _proximity = 0.0;

  /// Hover Both side icon
  final double _hoversideICON = -8.0;

  /// Hover Main icon
  final double _hoverOnIcon = -15.0;

  late final List<double> _heights = List.generate(_icons.length, (_) => 0.0);

  // List to hold animation controllers for each icon
  late List<AnimationController> _controllers;
  late List<Animation<double>> _waveAnimations;

  // Boolean to track if the user is holding an icon
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _icons.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _waveAnimations = List.generate(
      _icons.length,
      (index) => Tween<double>(begin: 0.0, end: 10.0).animate(CurvedAnimation(
          parent: _controllers[index], curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Center widget to show the name of the hovered icon
        Container(
          alignment: Alignment.center,
          height: double.maxFinite,
          width: double.maxFinite,
          color: Colors.white,
          child: const Text(
            "Home Screen",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
        ),
        // Dock Bar at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: _icons.asMap().entries.map((entry) {
                final index = entry.key;
                final icon = entry.value;

                return _buildDockIcon(icon, index);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds each dock icon with dynamic spacing and animation.
  Widget _buildDockIcon(IconData icon, int index) {
    return Draggable<IconData>(
      data: icon,
      feedback: Material(
        color: Colors.transparent,
        child: Icon(
          icon,
          size: 50,
          color: Colors.black,
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        setState(() {
          _isHolding = true;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _isHolding = false;
        });
      },
      child: GestureDetector(
        onDoubleTap: () {
          // Reset the state after the user releases the click
          setState(() {
            _isHolding = true;
          });
        },
        onTapDown: (_) {
          // Prevent hover effects during the hold
          setState(() {
            _isHolding = true;
          });
        },
        onTapUp: (_) {
          // Reset the state after the user releases the click
          setState(() {
            _isHolding = false;
          });
        },
        child: MouseRegion(
          onEnter: (_) {
            if (!_isHolding) {
              setState(() {
                _heights[index] = _hoverOnIcon; // Move the hovered icon up
                // Adjust neighboring icons (if they exist)
                if (index > 0) {
                  _heights[index - 1] =
                      _hoversideICON; // Move the left icon up slightly
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] =
                      _hoversideICON; // Move the right icon up slightly
                }
              });
            } else {
              setState(() {
                _heights[index] = _hoverOnIcon; // Move the hovered icon up
                // Adjust neighboring icons (if they exist)
                if (index > 0) {
                  _heights[index - 1] =
                      _hoversideICON; // Move the left icon up slightly
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] =
                      _hoversideICON; // Move the right icon up slightly
                }
              });
            }
          },
          onExit: (_) {
            if (!_isHolding) {
              setState(() {
                _heights[index] = 0.0; // Reset the hovered icon position
                // Reset neighboring icons (if they exist)
                if (index > 0) {
                  _heights[index - 1] = 0.0; // Reset the left icon
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] = 0.0; // Reset the right icon
                }
                _controllers[index].reverse(); // Reverse the wave animation
              });
            } else {
              setState(() {
                _heights[index] = 0.0; // Reset the hovered icon position
                // Reset neighboring icons (if they exist)
                if (index > 0) {
                  _heights[index - 1] = 0.0; // Reset the left icon
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] = 0.0; // Reset the right icon
                }
                _controllers[index].reverse(); // Reverse the wave animation
              });
            }
          },
          child: DragTarget<IconData>(
            // ignore: deprecated_member_use
            onWillAccept: (data) {
              setState(() {
                _hoveredIndex = index;
                _proximity = 1.0; // Full spacing when hovered.
                // Adjust the heights of the hovered icon and its neighbors
                _heights[index] = _hoverOnIcon; // Move the hovered icon up
                if (index > 0) {
                  _heights[index - 1] = -7.0; // Move the left icon up slightly
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] =
                      _hoversideICON; // Move the right icon up slightly
                }
              });
              return true;
            },
            onLeave: (_) {
              setState(() {
                _hoveredIndex = -1;
                _proximity = 0.0; // Reset spacing when leaving.
                // Reset heights of the hovered icon and its neighbors
                _heights[index] = 0.0; // Reset the hovered icon
                if (index > 0) {
                  _heights[index - 1] = 0.0; // Reset the left icon
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] = 0.0; // Reset the right icon
                }
              });
            },
            onAccept: (data) {
              setState(() {
                final oldIndex = _icons.indexOf(data);
                _icons.removeAt(oldIndex);
                _icons.insert(index, data);
                _hoveredIndex = -1;
                _proximity = 0.0;

                // Reset heights after the icon is moved
                _heights[index] = 0.0;
                if (index > 0) {
                  _heights[index - 1] = 0.0;
                }
                if (index < _icons.length - 1) {
                  _heights[index + 1] = 0.0;
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = _hoveredIndex == index;

              // Calculate extra spacing based on proximity factor.
              final extraSpace = isHovered
                  ? Tween<double>(begin: 0.0, end: 100.0).transform(_proximity)
                  : 0.0;

              // Here, we add the spacing symmetrically on both sides
              final symSpacing = extraSpace / 2;

              return AnimatedBuilder(
                animation: _waveAnimations[index],
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(right: symSpacing),
                    width: 48,
                    transform:
                        Matrix4.translationValues(0.10, _heights[index], 20.0)
                          ..rotateZ(_waveAnimations[index].value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 40,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

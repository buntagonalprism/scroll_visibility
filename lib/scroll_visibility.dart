library visibility_widget;

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that allows programmatic scrolling into view
///
/// Scrolling logic from by Collin Jackson
/// https://gist.github.com/collinjackson/50172e3547e959cba77e2938f2fe5ff5
class ScrollVisibility extends StatefulWidget {

  ScrollVisibility({
    Key key,
    @required this.child,
    @required this.visibilityNode,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);


  /// Child to display inside the visibility widget which will be scrolled into view when
  /// [node.makeVisible()] is called
  final Widget child;

  /// The node identifying this visibility widget. Create nodes and then call [makeVisible] on them
  /// to request a widget be scrolled into view
  final ScrollVisibilityNode visibilityNode;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  @override
  _ScrollVisibilityState createState() => _ScrollVisibilityState();
}

class _ScrollVisibilityState extends State<ScrollVisibility> {

  @override
  void initState() {
    super.initState();
    widget.visibilityNode._makeVisible = makeVisible;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void makeVisible() {
    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    ScrollPosition position = scrollableState.position;
    double alignment;
    if (position.pixels > viewport.getOffsetToReveal(object, 0.0).offset) {
      // Move down to the top of the viewport
      alignment = 0.0;
    } else if (position.pixels < viewport.getOffsetToReveal(object, 1.0).offset) {
      // Move up to the bottom of the viewport
      alignment = 1.0;
    } else {
      // No scrolling is necessary to reveal the child
      return;
    }
    position.ensureVisible(
      object,
      alignment: alignment,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

}

class ScrollVisibilityNode {
  VoidCallback _makeVisible;
  void makeVisible() {
    if (_makeVisible != null) {
      _makeVisible();
    }
  }

  /// Helper function to scroll nodes with errors displayed into view
  ///
  /// [errorNodes] input is a map between visibility nodes and an error message contained within the
  /// corresponding visibility widget - typically the errorText value of a TextField
  ///
  /// Intended for when form input validation has occurred and we want to reveal the first field
  /// with an error. The first node with a non-null error will be scrolled into view.
  ///
  /// The [delayMs] parameter defaults to about 4 frames worth to allow error text to be drawn.
  /// Otherwise, if the error was not present at the time the visibility widget started to scroll,
  /// error text may not be scrolled into view since the scroll calculations were performed before
  /// the error existed.
  static void scrollNonNullErrorIntoView(Map<ScrollVisibilityNode, String> errorNodes, {int delayMs = 64}) async {
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    for (var node in errorNodes.keys) {
      String error = errorNodes[node];
      if (error != null) {
        node.makeVisible();
        return;
      }
    }
  }
}

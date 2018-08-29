library visibility_widget;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

///
/// Inspired by Colin Jackson https://gist.github.com/collinjackson/50172e3547e959cba77e2938f2fe5ff5


class VisibilityWidget extends StatefulWidget {

  VisibilityWidget({
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
  final VisibilityNode visibilityNode;

  /// The curve we will use to scroll ourselves into view.
  ///
  /// Defaults to Curves.ease.
  final Curve curve;

  /// The duration we will use to scroll ourselves into view
  ///
  /// Defaults to 100 milliseconds.
  final Duration duration;

  @override
  _VisibilityWidgetState createState() => _VisibilityWidgetState();
}

class _VisibilityWidgetState extends State<VisibilityWidget> {

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

class VisibilityNode {
  VoidCallback _makeVisible;
  void makeVisible() {
    if (_makeVisible != null) {
      _makeVisible();
    }
  }
}
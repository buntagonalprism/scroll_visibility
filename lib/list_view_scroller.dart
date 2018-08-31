import 'dart:async';

import 'package:flutter/widgets.dart';

class ListViewScroller {

  /// Scrolls a scroll controller to the end of its scrollable region, using a double-scroll action
  ///
  /// Helpful when items in a ListView do not have a fixed vertical extent and therefore the total
  /// height of the list cannot be calculated in advance.
  ///
  /// [durationMs] is the time taken to perform the scroll
  ///
  /// [delayBeforeStart] is how long to wait before starting to scroll. This defaults to 32
  /// milliseconds ~= 2 frames at 60fps, to allow any state transitions / rebuilds to complete,
  /// like adding a new item to the end of a list, before beginning the scroll.
  ///
  /// Operates by performing an initial scroll for [durationMs] towards the anticipated bottom of
  /// the list. Then 50ms before the end of the initial scroll, initiates a new scroll.
  /// By this point we should have scrolled very close to the end of the list (except for very long
  /// lists), and the current max scroll extent is then used to reach the true bottom.
  void scrollToEnd(ScrollController controller, {int durationMs = 600, int delayBeforeStart = 32}) {
    new Timer(Duration(milliseconds: delayBeforeStart), () async {
      if (controller.hasClients) {
        ScrollPosition current = controller.position;
        current.animateTo(current.maxScrollExtent, duration: Duration(milliseconds: durationMs),
            curve: Curves.easeIn);
        new Timer(Duration(milliseconds: durationMs - 50), () async {
          current = controller.position;
          await current.animateTo(
              current.maxScrollExtent, duration: Duration(milliseconds: 50), curve: Curves.easeIn);
        });
      }
    });
  }

}
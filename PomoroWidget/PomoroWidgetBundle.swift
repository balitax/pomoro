import WidgetKit
import SwiftUI

@main
struct PomoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomoroTimerWidget()
        PomoroLockScreenWidget()
    }
}

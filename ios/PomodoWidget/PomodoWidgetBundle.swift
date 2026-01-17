//
//  PomodoWidgetBundle.swift
//  PomodoWidget
//
//  Widget bundle for Live Activities and potential home screen widgets
//

import SwiftUI
import WidgetKit

@main
struct PomodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Live Activity for Dynamic Island and Lock Screen
        PomodoLiveActivity()

        // Future: Home screen widget
        // PomodoHomeWidget()
    }
}

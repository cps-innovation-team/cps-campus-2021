//
//  CampusWidgets.swift
//  CPS Campus (Shared)
//
//  7/22/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI
import WidgetKit

@main
struct CampusWidgets: WidgetBundle {
    var body: some Widget {
#if os(iOS)
        ScheduleWidgetiOS()
#elseif os(macOS)
        ScheduleWidgetmacOS()
#endif
    }
}

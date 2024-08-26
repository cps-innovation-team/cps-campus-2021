//
//  ViewHelpers.swift
//  CPS Campus (Shared)
//
//  6/19/2021
//  Designed by Rahim Malik in California.
//

import Foundation
import SwiftUI

struct SectionHeader: View {
    let name: String
    var body: some View {
#if os(iOS)
        HStack {
            Text(name)
                .fontWeight(.bold)
                .font(.system(size: 24))
                .foregroundStyle(Color("SystemContrast"))
            Spacer()
        }.padding(.leading, 10)
#elseif os(macOS)
        HStack {
            Text(name)
                .fontWeight(.bold)
                .font(.system(size: 20))
                .foregroundStyle(Color("SystemContrast"))
            Spacer()
        }.padding(.leading, 10)
#endif
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

extension View {
    func borderedCellStyle() -> some View {
        return self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                    .foregroundStyle(Color("SystemCell").opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                    .stroke(Color("SystemGray3"), lineWidth: 1)
            )
            .padding(1)
    }
    
    func tintedCellStyle(color: Color) -> some View {
        return self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                    .foregroundStyle(color.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12.5, style: .continuous)
                    .stroke(color, lineWidth: 1)
            )
            .padding(1)
    }
}

#if canImport(UIKit)
import QuickLook

struct NavigationBarColor: ViewModifier {
    
    init(backgroundColor: UIColor, tintColor: UIColor) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: tintColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor, tintColor: UIColor) -> some View {
        self.modifier(NavigationBarColor(backgroundColor: backgroundColor, tintColor: tintColor))
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PreviewController: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let url: URL
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator,
            action: #selector(context.coordinator.dismiss)
        )
        
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return parent.url as NSURL
        }
        
        @objc func dismiss() {
            parent.dismiss()
        }
    }
}
#endif

#if os(macOS)
func toggleSidebar() { NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

class FocusNSView: NSView {
    override var acceptsFirstResponder: Bool {
        return true
    }
}
#endif

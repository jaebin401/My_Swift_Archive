//
//  VisualEffectView.swift
//  FloatingPanelStudy
//
//  Created by Jaebin Ahn on 7/20/26.
//

import SwiftUI

/// Bridges `NSVisualEffectView` so floating panel content can use native macOS blur materials.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active
    var emphasized: Bool = false

    func makeNSView(context: Context) -> NSVisualEffectView {
        context.coordinator.visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        context.coordinator.update(
            material: material,
            blendingMode: blendingMode,
            state: state,
            emphasized: emphasized
        )
    }

    func makeCoordinator() -> VisualEffectViewCoordinator {
        VisualEffectViewCoordinator()
    }
}

final class VisualEffectViewCoordinator {
    let visualEffectView = NSVisualEffectView()

    func update(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        state: NSVisualEffectView.State,
        emphasized: Bool
    ) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = state
        visualEffectView.isEmphasized = emphasized
    }
}

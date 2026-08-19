//
//  VisualEffectView.swift
//  macOS_SideBar_study
//
//  Created by Jaebin Ahn on 7/21/26.
//

import SwiftUI

/// AppKit의 NSVisualEffectView를 SwiftUI에서 사용할 수 있게 감싼 view입니다.
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

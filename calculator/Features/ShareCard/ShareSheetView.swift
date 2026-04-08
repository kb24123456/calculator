//
//  ShareSheetView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

/// UIKit wrapper for UIActivityViewController to share an image.
struct ShareSheetView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

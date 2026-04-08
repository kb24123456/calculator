//
//  NumoLiveActivity.swift
//  Numo
//
//  Created by 廖云丰 on 2026/4/9.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NumoAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NumoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NumoAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NumoAttributes {
    fileprivate static var preview: NumoAttributes {
        NumoAttributes(name: "World")
    }
}

extension NumoAttributes.ContentState {
    fileprivate static var smiley: NumoAttributes.ContentState {
        NumoAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NumoAttributes.ContentState {
         NumoAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NumoAttributes.preview) {
   NumoLiveActivity()
} contentStates: {
    NumoAttributes.ContentState.smiley
    NumoAttributes.ContentState.starEyes
}

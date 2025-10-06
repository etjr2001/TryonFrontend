//
//  InfoButton.swift
//  Tryon
//
//  Created by Eric Tan Jun Ren on 29/9/25.
//

import SwiftUI

struct InfoButton: View {
    let infoTitle: String
    let infoText: String
    
    @State var showPopover = false
    
    var body: some View {
        Button(action: { showPopover = true }) {
            Image(systemName: "info.circle")
        }
        .popover(isPresented: $showPopover) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button("Close") {
                        showPopover = false
                    }
                }
                .padding()
                Text(infoTitle)
                    .font(.headline)
                Text(infoText)
                    .font(.body)
                Spacer()
            }
            .padding()
        }
    }
}

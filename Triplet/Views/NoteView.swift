//
//  NoteView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI

struct NoteView: View {
    var note: Note
    
    @State var title: String = ""
    @State var content: String = ""
    
    var body: some View {
        VStack {
            TextField("Note Title", text: $title)
                .padding([.leading, .trailing], 40)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.indigo)
            Spacer()
                .frame(maxHeight: 20)
            TextEditor(text: $content)
                .padding([.leading, .trailing, .bottom], 40)
        }
        .onAppear {
            title = note.title
            content = note.content
        }
        .toolbar {
            ToolbarItem {
                Button {
                    
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

#Preview {
    NoteView(note: Note())
}

//
//  NoteView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    var note: Note
    
    @State var title: String = ""
    @State var content: String = ""
    
    var body: some View {
        VStack {
            TextField("Note Title", text: $title)
                .padding([.leading, .trailing], 40)
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(Color("Dark Teal"))
            Spacer()
                .frame(maxHeight: 20)
            TextEditor(text: $content)
                .padding([.leading, .trailing, .bottom], 40)
                .font(.custom("Poppins-Regular", size: 16))
        }
        .onAppear {
            title = note.title
            content = note.content
        }
        .toolbar {
            ToolbarItem {
                Button {
                    if let noteId = note.id {
                        overviewViewModel.updateNote(noteId: noteId, content: content)
                    }
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

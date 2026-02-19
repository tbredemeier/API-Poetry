//
//  PoemsView.swift
//  API Poetry
//
//  Created by Tom Bredemeier on 2/19/26.
//

import SwiftUI

struct PoemsView: View {
    @State private var poems = [Poem]()
    @State private var showingAlert = false
    let author: String
    var body: some View {
        List(poems) { poem in
            NavigationLink {
                ScrollView{
                    VStack {
                        Text(poem.title)
                            .font(.headline)
                        Text("by \(author)").padding(.bottom)
                        ForEach(poem.lines, id: \.self) { line in
                            Text(line)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            } label: {
                Text(poem.title)
            }
        }
        .navigationTitle("Poems by " + author)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await(getPoems())
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading the poems."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func getPoems() async {
        let query = "https://poetrydb.org/author/" + author + "/title,lines"
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode([Poem].self, from: data) {
                    poems = decodedResponse
                    return
                }
            }
        }
        showingAlert = true
    }
}

#Preview {
    PoemsView(author: "Walt Whitman")
}

struct Poem: Identifiable, Codable {
    let id = UUID()
    let title: String
    let lines: [String]
    
    enum CodingKeys: String, CodingKey {
        case title, lines
    }
}

//
//  SearchView.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 20/10/24.
//


import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults = [String]()
    
    // Example data
    let allItems = ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape", "Honeydew"]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search something...", text: $searchText, onEditingChanged: { isEditing in
                    self.search() // Search when user types
                }, onCommit: {
                    self.search() // Search when user presses 'Search' on the keyboard
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                List {
                    ForEach(searchResults, id: \.self) { item in
                        Text(item)
                    }
                }
            }
        }
    }
    
    func search() {
        if searchText.isEmpty {
            searchResults = allItems
        } else {
            searchResults = allItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

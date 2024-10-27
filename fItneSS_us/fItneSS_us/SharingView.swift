//
//  Post.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 9/10/24.
//


import SwiftUI


struct SharingView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0 // For top tab navigation

    //private let tabTitles = ["Follow", "Explore", "➕", "Event", "🔎"]
    //private let tabTitles = ["Event", "Explore", "Post",  "🔎"]
    private let tabTitles = ["Explore", "Post",  "Search"]
    private let tabIcons: [Image] = [
        Image(systemName: "magnifyingglass"),
        Image(systemName: "square.and.arrow.up"),
        Image(systemName: "magnifyingglass"),
    ]
    //private let navigationBarTitle = ["Explore Popular Events", "Explore Workout Posts", "Sharing your workout", "Search"]
    private let navigationBarTitle = ["Explore Workout Posts", "Sharing your workout", "Search"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Tab Bar
                Picker("Select", selection: $selectedTab) {
                    ForEach(0..<tabTitles.count, id: \.self) { index in
                        Text(self.tabTitles[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Content based on selected top tab
                Group {
                    switch selectedTab {
                    //case 0:
                    //    EventView()
                    case 0:
                        ExploreView()
                    case 1:
                        PostView()
                    case 2:
                        SearchView()
                    default:
                        Text("Selection does not exist.")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.slide)
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.slide)
            
        }.navigationBarTitle(navigationBarTitle[selectedTab], displayMode: .inline)
    }
}

#Preview {
    SharingView()
}

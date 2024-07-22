//
//  SearchableExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/f2nxenwKCVM?si=xxYqeWhvbjJDw-cY - min 14, search logic
//  Created by Uri on 22/7/24.
//

import SwiftUI

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese, worldwide
}

final class RestaurantManager {
    
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", name: "Umami Burger", cuisine: .american),
            Restaurant(id: "2", name: "Santa Lucia", cuisine: .italian),
            Restaurant(id: "3", name: "Kurama", cuisine: .japanese),
            Restaurant(id: "4", name: "Carrot Cafe", cuisine: .worldwide),
        ]
    }
}

@MainActor
final class SearchableExampleViewModel: ObservableObject {
    
    let manager = RestaurantManager()
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    
    @Published var searchText: String = ""
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
        } catch {
            debugPrint(error)
        }
    }
}

struct SearchableExample: View {
    
    @StateObject private var viewModel = SearchableExampleViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.allRestaurants) { restaurant in
                    restaurantRow(restaurant: restaurant)
                }
            }
            .padding()
        }
        .searchable(text: $viewModel.searchText, prompt: "Search restaurant")
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
    }
}

#Preview {
    NavigationStack {
        SearchableExample()
    }
}

extension SearchableExample {
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.name)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
    }
}

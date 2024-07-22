//
//  SearchableExample.swift
//  ConcurrencyBootcamp
//
//  Created by Uri on 22/7/24.
//

import SwiftUI

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: CuisineOption
}

enum CuisineOption {
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
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    let manager = RestaurantManager()
    
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
                ForEach(viewModel.allRestaurants, id: \.self) { restaurant in
                    Text(restaurant.name)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }
}

#Preview {
    SearchableExample()
}

//
//  SearchableExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/f2nxenwKCVM?si=xxYqeWhvbjJDw-cY
//  Created by Uri on 22/7/24.
//

import SwiftUI
import Combine

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
            Restaurant(id: "5", name: "Shake Shack", cuisine: .american),
            Restaurant(id: "6", name: "Totoro", cuisine: .japanese)
        ]
    }
}

@MainActor
final class SearchableExampleViewModel: ObservableObject {
    
    let manager = RestaurantManager()
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                guard let self = self else { return }
                self.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // Filter on search scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        // Filter on search text
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.name.lowercased().contains(search)
            let cuisineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainsSearch
        })
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            // Convert the array to a Set so we have a collection of unique values in our search scope
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            
            // Show only those cuisines that will return results
            allSearchScopes = [.all] + allCuisines.map({ SearchScopeOption.cuisine(option: $0) })
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
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                    restaurantRow(restaurant: restaurant)
                }
            }
            .padding()
            
            // Uncomment to check isSearching
            //Text("ViewModel is searching: \(viewModel.isSearching.description)")
            //SearchChildView()
        }
        .searchable(text: $viewModel.searchText, prompt: "Search restaurant")
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
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

// MARK: - Read searchable from environment instead of using a computed property in VM
struct SearchChildView: View {
    @Environment(\.isSearching) private var isSearching
    
    
    var body: some View {
        Text("Child view is searching: \(isSearching.description)")
    }
}

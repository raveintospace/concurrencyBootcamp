//
//  RefreshableExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/UiU0y2wQTLw?si=qhYb1dhl9y0szMnF
//  Created by Uri on 22/7/24.
//

import SwiftUI

actor RefreshableExampleDataService {
    
    func getData() async throws -> [String] {
        // sleep for demo purposes only
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return ["Apple", "Banana", "Kiwi", "Orange", "Peach", "Strawberry"].shuffled()
    }
}

@MainActor
final class RefreshableExampleViewModel: ObservableObject {
    
    @Published private(set) var fruits: [String] = []
    let manager = RefreshableExampleDataService()
    
    func loadData() async {
        do {
            fruits = try await manager.getData()
        } catch {
            debugPrint(error)
        }
    }
}

struct RefreshableExample: View {
    
    @StateObject private var viewModel = RefreshableExampleViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.fruits, id: \.self) { fruit in
                        Text(fruit)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Refreshable example")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    RefreshableExample()
}

//
//  ObservableMA.swift
//  ConcurrencyBootcamp
//  https://youtu.be/4dQOnNYjO58?si=L6chvoK7eAnGOgvj
//  Created by Uri on 26/7/24.
//

import SwiftUI
import Observation

// MARK: - Data Manager
actor TitleDataManager {
    
    func getNewTitle() -> String {
        "Title from actor"
    }
}

// MARK: - ViewModels
@MainActor
final class ObservableMAViewModelClassic: ObservableObject {
    
    @Published var title: String = "Starting title observable object"
    let manager = TitleDataManager()
    
    func updateTitle() async {
        await title = manager.getNewTitle()
    }
}

@Observable
@MainActor
final class ObservableMAViewModel {
    
    // does not observe our manager because it does not update to the view
    // If manager changed, it does not have anything that updates our view
    @ObservationIgnored let manager = TitleDataManager()
    
    var title: String = "Starting title observable"
    
    func updateTitle() async {
        await title = manager.getNewTitle()
    }
    
    // option 2
    func updateTitleWithTask() {
        Task {
            title = await manager.getNewTitle()
            debugPrint("title updated with task")
        }
    }
}

// MARK: View
struct ObservableMA: View {
    
    @StateObject private var viewModel2 = ObservableMAViewModelClassic()
    @State private var viewModel = ObservableMAViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
//            .onAppear {
//                viewModel.updateTitleWithTask()
//            }
    }
}

#Preview {
    ObservableMA()
}

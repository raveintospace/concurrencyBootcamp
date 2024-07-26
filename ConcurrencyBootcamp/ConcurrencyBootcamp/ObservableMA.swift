//
//  ObservableMA.swift
//  ConcurrencyBootcamp
//  https://youtu.be/4dQOnNYjO58?si=L6chvoK7eAnGOgvj
//  Created by Uri on 26/7/24.
//

import SwiftUI
import Observation

// MARK: - Data Manager
@MainActor
final class ObservableMAViewModelClassic: ObservableObject {
    
    @Published var title: String = "Starting title observable object"
    let manager = TitleDataManager()
    
    func updateTitle() async {
        await title = manager.getNewTitle()
    }
}

// MARK: - ViewModels
@Observable
final class ObservableMAViewModel {
    
    // does not observe manager because it does not publish to the view
    @ObservationIgnored let manager = TitleDataManager()
    
    // update title on main thread
    @MainActor var title: String = "Starting title observable"
    
    // func needs to be on main actor to update title
    @MainActor
    func updateTitle() async {
        await title = manager.getNewTitle()
    }
    
    // option 2
    func updateTitleWithTask() {
        Task { @MainActor in
            title = await manager.getNewTitle()
            debugPrint("title updated with task")
        }
    }
}

actor TitleDataManager {
    
    func getNewTitle() -> String {
        "Title from actor"
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

//
//  ObservableMA.swift
//  ConcurrencyBootcamp
//  https://youtu.be/4dQOnNYjO58?si=L6chvoK7eAnGOgvj
//  Created by Uri on 26/7/24.
//

import SwiftUI
import Observation

@Observable
final class ObservableMAViewModel {
    
}

actor TitleDataManager {
    
    func getNewTitle() -> String {
        "Title from actor"
    }
}

final class ObservableMAViewModelClassic: ObservableObject {
    
    @Published var title: String = "Starting title"
    let manager = TitleDataManager()
    
    func updateTitle() async {
        await title = manager.getNewTitle()
    }
}

struct ObservableMA: View {
    
    @StateObject private var viewModel2 = ObservableMAViewModelClassic()
    
    var body: some View {
        Text(viewModel2.title)
            .task {
                await viewModel2.updateTitle()
            }
    }
}

#Preview {
    ObservableMA()
}

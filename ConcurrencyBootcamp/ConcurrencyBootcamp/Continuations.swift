//
//  Continuations.swift
//  ConcurrencyBootcamp
//  https://youtu.be/Tw_WLMIfEPQ?si=Lsf-moS8eHqNnrte
//  Created by Uri on 13/7/24.
//

import SwiftUI

final class ContinuationsNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
}

final class ContinuationsViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = ContinuationsNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await networkManager.getData(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            debugPrint(error)
        }
    }
}

struct Continuations: View {
    
    @StateObject private var viewModel = ContinuationsViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getImage()
        }
    }
}

#Preview {
    Continuations()
}

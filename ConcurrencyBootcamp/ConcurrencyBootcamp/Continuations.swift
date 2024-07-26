//
//  Continuations.swift
//  ConcurrencyBootcamp
//  https://youtu.be/Tw_WLMIfEPQ?si=Lsf-moS8eHqNnrte
//  Created by Uri on 13/7/24.
//  For completion handlers that execute only one time / Multiple times -> Async stream

import SwiftUI

final class ContinuationsNetworkManager {
    
    // returns Data, previous network managers code returns UIImage
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    // completion handler (escaping closure) in URLSession, code that does not take async is converted to take it
    // we always have to resume, only once
    // Continuations return one value one time
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageWithCompletionHandler(completionHandler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImageWithCompletionHandler { image in
                continuation.resume(returning: image)
            }
        }
    }
}

final class ContinuationsViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = ContinuationsNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            //let data = try await networkManager.getData2(url: url)
            
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
    
    // using getHeartImageWithCompletionHandler
    func getHeartImage() {
        networkManager.getHeartImageWithCompletionHandler { [weak self] image in
            guard let self = self else { return }
            self.image = image
        }
    }
    
    // using getHeartImageFromDatabase()
    func getHeartImage2() async {
        self.image = await networkManager.getHeartImageFromDatabase()
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
            // await viewModel.getImage()
            // viewModel.getHeartImage()
            
            await viewModel.getHeartImage2()
        }
    }
}

#Preview {
    Continuations()
}

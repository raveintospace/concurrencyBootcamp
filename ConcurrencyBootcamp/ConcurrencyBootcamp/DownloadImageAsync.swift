//
//  DownloadImageAsync.swift
//  ConcurrencyBootcamp
//  L2
//  Created by Uri on 7/7/24.
//

import SwiftUI
import Combine

final class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void ) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            let image = self.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })   // maps the URLError from handleResponse to Error
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

final class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var expectedImage: UIImage? = nil
    
    let loader = DownloadImageAsyncImageLoader()
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchImageCompletionHandler() {
        loader.downloadWithEscaping { [weak self] returnedImage, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.expectedImage = returnedImage
            }
        }
    }
    
    func fetchImageCombine() {
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedImage in
                guard let self = self else { return }
                expectedImage = returnedImage
            }
            .store(in: &cancellables)
    }
    
    func fetchWithAsync() async {
        let returnedImage = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.expectedImage = returnedImage
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.expectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            // viewModel.fetchImageCompletionHandler()
            // viewModel.fetchImageCombine()
            Task {
                await viewModel.fetchWithAsync()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}

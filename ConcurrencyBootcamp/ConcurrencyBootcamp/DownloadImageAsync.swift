//
//  DownloadImageAsync.swift
//  ConcurrencyBootcamp
//  L2
//  Created by Uri on 7/7/24.
//

import SwiftUI

class DownloadImageAsyncImageLoader {
    
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
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    
    func fetchImage() {
        loader.downloadWithEscaping { [weak self] returnedImage, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.image = returnedImage
            }
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            viewModel.fetchImage()
        }
    }
}

#Preview {
    DownloadImageAsync()
}

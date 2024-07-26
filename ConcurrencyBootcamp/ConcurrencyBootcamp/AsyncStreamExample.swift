//
//  AsyncStreamExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/gi38bouUI2Q?si=xEBYlnAXrGOi5oNY
//  Created by Uri on 26/7/24.

//  Convert escaping closures to async streams, can return multiple times (stream of data)
//  Continuations only return one value one time

import SwiftUI

final class AsyncStreamDataManager {
    
    // Simulates a stream of data coming to our app, using a completion handler
    func getFakeData(completion: @escaping (_ value: Int) -> Void) {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]

        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                    completion(item)
            })
        }
    }
    
    // Simulates a stream of data coming to our app and notifying when the stream finishes
    // The stream can optionally throw errors on its onFinish
    func getFakeDataWithOnFinish(
        newValue: @escaping (_ value: Int) -> Void,
        onFinish: @escaping (_ error: Error?) -> Void
    ) {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]

        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                    newValue(item)
                
                if item == items.last {
                    onFinish(nil)   // no errors
                }
            })
        }
    }
    
    // Simulates a stream of data coming to our app, using async code
    // We have to specify what type of data our asyncstream returns
    func getAsyncStream() -> AsyncStream<Int> {
        AsyncStream { [weak self] continuation in
            guard let self = self else { return }
            self.getFakeData { value in
                continuation.yield(value)
            }
        }
    }
    
    // AsyncStream that throws errors
    func getAsyncStreamWithOnFinish() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeDataWithOnFinish(newValue: { value in
                continuation.yield(value)
            }, onFinish: { error in
                if let error {
                    continuation.finish(throwing: error)
                } else {
                    continuation.finish()
                }
            })
        }
    }
}

@MainActor
final class AsyncStreamExampleViewModel: ObservableObject {
    
    let manager = AsyncStreamDataManager()
    @Published private(set) var currentNumber: Int = 0
    
    func onViewAppear() {
        manager.getFakeData { [weak self] value in
            guard let self = self else { return }
            self.currentNumber = value
        }
    }
    
    // async in viewModel
    func onViewAppearAsyncStream() {
        let task = Task {
            do {
                for try await value in manager.getAsyncStreamWithOnFinish() {
                    currentNumber = value
                }
            } catch {
                debugPrint(error)
            }
        }
        
        // cancels the task of viewModel, but not the task of the manager (getFakeData)
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            task.cancel()
        })
        */
    }
    
    // async in View (Task)
    func onViewAppearAsyncStream2() async {
        for await value in manager.getAsyncStream() {
            currentNumber = value
        }
    }
}

struct AsyncStreamExample: View {
    
    @StateObject private var viewModel = AsyncStreamExampleViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppearAsyncStream()
            }
        // onAppear asyncStream2
        /*
         .onAppear {
             Task {
                 await viewModel.onViewAppearAsyncStream2()
             }
         }
         */
    }
}

#Preview {
    AsyncStreamExample()
}

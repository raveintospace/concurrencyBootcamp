//
//  ActorExample.swift
//  ConcurrencyBootcamp
//  https://youtu.be/UUdi137FySk?si=HcTLRcqWF0UNGfqu
//  Created by Uri on 16/7/24.
//

/*
 1. What is the problem that actors solve? When multiple threads try to access the same piece of memory in the heap at the same time
 
 2. How to fix the problem before Actors? Make classes thread safe with "private let queue"
 
 3. Actors make classes thread safe by themselves
 */

import SwiftUI

// MARK: - Safely multithreading with class
final class MyDataManager {
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    
    // makes the class thread safe
    private let queue = DispatchQueue(label: "com.MyAppName.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        queue.async {
            self.data.append(UUID().uuidString)
            debugPrint(Thread())
            completionHandler(self.data.randomElement())
        }
    }
}

struct HomeView: View {
    
    let manager = MyDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            text = data
                        }
                    }
                }
            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .default).async {
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            text = data
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Multithreading with Actor

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        debugPrint(Thread())
        return data.randomElement()
    }
    
    nonisolated func getSavedDataWithoutWaiting() -> String {
        return "New Data"
    }
    
    nonisolated let myRandomText: String = "fasfsadfas"
}

struct ActorHomeView: View {
    
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        text = data
                    }
                }
            }
        }
    }
}

struct ActorBrowseView: View {
    
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            // non-isolated func & property
            let newString = manager.getSavedDataWithoutWaiting()
            let newRandomText = manager.myRandomText
            
            // actor-isolated property
            Task {
                await manager.data
            }
        }
        .onReceive(timer) { _ in
            Task {
                // await to get into the actor
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        text = data
                    }
                }
            }
        }
    }
}

struct ActorExample: View {
    var body: some View {
        TabView {
            Text("Fato")
            //ActorHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            Text("Fati")
            //ActorBrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorExample()
}

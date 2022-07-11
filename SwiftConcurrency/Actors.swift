//
//  Actors.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 11.07.2022.
//

import SwiftUI

// 1. What is the problem that actor are solving?  - data race
// 2. How was this problem solved prior to actors?
// 3. Actors can solve the problem

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let queue = DispatchQueue(label: "Myapp.MyDataManager")
    
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {  //make class thread-safe before actors
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
    nonisolated let myRandomText = "fddsfdsfgsd"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    func getSavedData() -> String {
        return "New Data"
    }
    
    nonisolated func getSavedData2() -> String {
        return "New Data"
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let newString = manager.getSavedData2() // noisolated no need for Task and awaits(async enviroment)
            let newString2 = manager.myRandomText  // noisolated
            Task {
                let newString = await manager.getSavedData() // isolated, task and await are needed
            }
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
   //         DispatchQueue.global(qos: .background).async {
   //             manager.getRandomData { title in
   //                 if let data = title {
   //                     DispatchQueue.main.async {
   //                         self.text = data
   //                     }
   //                 }
   //             }
   //         }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
    //        DispatchQueue.global(qos: .default).async {
    //            manager.getRandomData { title in
    //                if let data = title {
    //                    DispatchQueue.main.async {
    //                        self.text = data
    //                    }
    //                }
    //            }
    //        }
        }
    }
}

struct Actors: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct Actors_Previews: PreviewProvider {
    static var previews: some View {
        Actors()
    }
}

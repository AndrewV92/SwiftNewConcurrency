//
//  AsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 12.07.2022.
//

import SwiftUI
import Combine

///dig into AsyncSequence, AsyncStream
///Async Algorithms(zip, merge, chain, buffer, debounce, throttle, CombineLatest)
///github: apple/swigt-async-algorithms

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Melon")
    }
}

class AsyncPublisherViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    
    let manager = AsyncPublisherDataManager()
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        Task {
        for await value in manager.$myData.values { //convert anything that @Published into async
            await MainActor.run(body: {
                self.dataArray = value
            })
        }
        
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
        }
    }
    
    func start() async {
       await manager.addData()
    }
}


struct AsyncPublisher: View {
    
    @StateObject private var viewModel = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisher_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisher()
    }
}

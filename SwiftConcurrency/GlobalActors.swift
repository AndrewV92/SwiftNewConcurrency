//
//  GlobalActors.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 12.07.2022.
//

import SwiftUI

//basically we put any function in actor, opposite of nonisolated

@globalActor struct MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDataBase() -> [String] {
        return ["one", "two", "three", "four", "five"]
    }
}
//@MainActor - isolate all class content in MainActor
class GlobalActorsViewModel: ObservableObject {
    
    let manager = MyFirstGlobalActor.shared
    
    @MainActor @Published var dataArray: [String] = []  //dataArray now only updated on MainActor
    
//  @MainActor
    @MyFirstGlobalActor func getData() async {  //running on the actor
        
        //HEAVY COMPLEX METHODS  мы не хотим забивать мейн-тред тяжелыми задачами
        
        let data = await manager.getDataFromDataBase()
        await MainActor.run(body: {
            self.dataArray = data
        })
    }
}

struct GlobalActors: View {
    
    @StateObject private var viewModel = GlobalActorsViewModel()
    
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
            await viewModel.getData()
        }
    }
}

struct GlobalActors_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActors()
    }
}

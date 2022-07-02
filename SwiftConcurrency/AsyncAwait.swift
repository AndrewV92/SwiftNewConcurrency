//
//  AsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 02.07.2022.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)           }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2: \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1: \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        })
    }
}

struct AsyncAwait: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }.onAppear {
            Task {
                await viewModel.addAuthor1()
                /*
                код исполняется только когда await закончит выполнение
                functions calls the same Task, but threads switching automatically
                switch back to MainActor for UI updating(like dispatchqueue.main)
                awaits is just suspention points
                */
                let finalText = "Final text : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
            //viewModel.addTitle1()
            //viewModel.addTitle2()
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}

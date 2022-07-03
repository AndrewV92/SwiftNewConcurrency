//
//  Tasks.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 03.07.2022.
//

import SwiftUI


class TaskViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/2000") else {return}
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("Image returned")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/2000") else {return}
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
            self.image2 = UIImage(data: data)
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
}


struct TaskHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me") {
                    Tasks()
                }
            }
        }
    }
}

struct Tasks: View {
    
    @StateObject private var viewModel = TaskViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {                                     //лучший способ описывать таски, автоматический кансел
            await viewModel.fetchImage()            //Но нужно делать иногда Task.checkCancellation() для                                           проверки кансела, иногда процесс продолжается
        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            /*
            Task(priority: .userInitiated) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")  //25
            }
            Task(priority: .high) {
                //try? await Task.sleep(nanoseconds: 2_000_000_000) //finishes last, priority is not an order
                await Task.yield() // пропускает вперед
                print("high : \(Thread.current) : \(Task.currentPriority)")  //25
            }
            Task(priority: .medium) {
                print("medium : \(Thread.current) : \(Task.currentPriority)")  //21
            }
            Task(priority: .low) {
                print("Low : \(Thread.current) : \(Task.currentPriority)")  //17
            }
            Task(priority: .utility) {
                print("utility : \(Thread.current) : \(Task.currentPriority)")  //17
            }
            Task(priority: .background) {
                print("background : \(Thread.current) : \(Task.currentPriority)")  //9
            }
            */
            
            /*
            Task(priority: .low) {
                print("low : \(Thread.current) : \(Task.currentPriority)")
                Task {
                    print("low : \(Thread.current) : \(Task.currentPriority)")
                    //child Task inherits parent metadata
                Task.detached {
                    print("detached : \(Thread.current) : \(Task.currentPriority)")
                    //Так не наследует, но так делать не стоит, смотри документацию 🐓
                    }
                }
            }
             */
            
            

        }
    }


struct Tasks_Previews: PreviewProvider {
    static var previews: some View {
        Tasks()
    }
}


/*
 userInitiated : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 25)
 medium : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 21)
 high : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 25)
 Low : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 17)
 utility : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 17)
 background : <_NSMainThread: 0x600001fdca80>{number = 1, name = main} : TaskPriority(rawValue: 9)
 */

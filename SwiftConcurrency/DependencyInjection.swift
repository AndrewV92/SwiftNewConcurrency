//
//  DependencyInjection.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 08.07.2022.
//

import SwiftUI
import Combine

struct PostsModel: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostsModel], Error>
}

class ProductionDataService: DataServiceProtocol {
    
    //static let instance = PProductionDataSetvice() //Singleton
    
    //let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map( { $0.data } )
            .decode(type: [PostsModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}


class MockDataService: DataServiceProtocol {

    let testData: [PostsModel]
    
    init(data: [PostsModel]?) {
        self.testData = data ?? [
            PostsModel(userId: 1, id: 1, title: "One", body: "one"),
            PostsModel(userId: 2, id: 2, title: "Two", body: "two")]
    }
    
    func getData() -> AnyPublisher<[PostsModel], Error> {
        Just(testData)
            .tryMap( {$0 } )
            .eraseToAnyPublisher()
    }
}

class DependencyInjectionViewModel: ObservableObject {
    
    @Published var dataArray: [PostsModel] = []
    var cancellables = Set<AnyCancellable>()
    //let dataService: ProductionDataSetvice
    let dataService: DataServiceProtocol
    
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            } .store(in: &cancellables)
    }
    
}

struct DependencyInjection: View {
    
    @StateObject private var viewModel: DependencyInjectionViewModel
    
    init(dataSetvice: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: DependencyInjectionViewModel(dataService: dataSetvice))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray) { post in
                    Text(post.title)
                }
            }
        }
    }
}

struct DependencyInjection_Previews: PreviewProvider {
    //same injections, but for learning simplified
    
    //prodaction data service
    //static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    //static let dataService = MockDataService(data: nil)
    
    static let dataService = MockDataService(data: [PostsModel(userId: 1234, id: 1234, title: "test", body: "test")])
    
    static var previews: some View {
        DependencyInjection(dataSetvice: dataService)
    }
}


//Problems with Singletons
//1.They are global
//2. Can't customize the init
//3. Can't swap out dependencies

//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 04.07.2022.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                }
            }
            .navigationTitle("Async let")
            .onAppear {
                Task {
                    do {
                        async let fetchImage1 = fetchImage()
                        
                        //async let fetchTitle1 = fetchTitle()
                        //let (image, title) = await (try fetchImage1, fetchTitle1)
                        //только fetchImage throws
                        
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()

                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        /*
                        let image1 = try await fetchImage()
                        self.images.append(image1)
                        
                        let image2 = try await fetchImage()
                        self.images.append(image2)
                        
                        let image3 = try await fetchImage()
                        self.images.append(image3)
                        
                        let image4 = try await fetchImage()
                        self.images.append(image4)
                         */
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        return "newTitle"
    }
    
    func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}

//
//  Sendable.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 12.07.2022.
//

import SwiftUI

/// The UnsafeSendable protocol indicates that value of the given type
/// can be safely used in concurrent code, but disables some safety checking
/// at the conformance site.

actor CurrentUserManager {
    
    func updateDataBase(userInfo: MyUserInfoClass) {
        
    }
}

struct MyUserInfo: Sendable {
    let name: String
}

final class MyUserInfoClass: @unchecked Sendable {  //Non-final class 'MyUserInfoClass' cannot conform to 'Sendable'; use                                                          '@unchecked Sendable'. Need to be final
    var name: String  // to have var instead let(mutable class) use @unchecked - WARNING dangerous 🐓🐓🐓
    private var name1: String //or we can make private var + func with queue(lock), less 🐓 better just use Structs
    
    let queue = DispatchQueue(label: "MyApp.MyUserInfoClass")
    
    init(name: String) {
        self.name = name
        self.name1 = name
    }
    
    func updateName(name: String) {
        queue.async {
        self.name1 = name
        }
    }
}

class SendableViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyUserInfoClass(name: "info")
        
        await manager.updateDataBase(userInfo: info)
    }
}

struct SendableView: View {
    
    @StateObject private var viewModel = SendableViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

struct Sendable_Previews: PreviewProvider {
    static var previews: some View {
        SendableView()
    }
}

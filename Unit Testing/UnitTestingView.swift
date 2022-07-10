//
//  UnitTestingView.swift
//  SwiftConcurrency
//
//  Created by Андрей Воробьев on 10.07.2022.
//

import SwiftUI

struct UnitTestingView: View {
    
    @StateObject private var viewModel: UnitTestingViewModel
    
    init(isPremuim: Bool) {
        _viewModel = StateObject(wrappedValue: UnitTestingViewModel(isPremium: isPremuim))
    }
    
    var body: some View {
        Text(viewModel.isPremium.description)
    }
}

struct UnitTestingView_Previews: PreviewProvider {
    static var previews: some View {
        UnitTestingView(isPremuim: true)
    }
}

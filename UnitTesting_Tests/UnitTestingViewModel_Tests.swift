//
//  UnitTestingViewModel_Tests.swift
//  UnitTesting_Tests
//
//  Created by Андрей Воробьев on 10.07.2022.
//

import XCTest
import Combine
@testable import SwiftConcurrency

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct or class]_[variable or function]_[expected result]

// Testing Structure: Given, When, Then

class UnitTestingViewModel_Tests: XCTestCase {
    
    var viewModel: UnitTestingViewModel?
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        viewModel = UnitTestingViewModel(isPremium: Bool.random())
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func test_UnitTestingViewModel_isPremium_shouldBeTrue() {
        // Given
        let userIsPremuim: Bool = true
        // When
        let vm = UnitTestingViewModel(isPremium: userIsPremuim)
        // Then
        XCTAssertTrue(vm.isPremium)
    }
    
    func test_UnitTestingViewModel_isPremium_shouldBeFalse() {
        // Given
        let userIsPremuim: Bool = false
        // When
        let vm = UnitTestingViewModel(isPremium: userIsPremuim)
        // Then
        XCTAssertFalse(vm.isPremium)
    }
    
    func test_UnitTestingViewModel_isPremium_shouldBeInjectedValue() {
        // Given
        let userIsPremuim: Bool = Bool.random()
        // When
        let vm = UnitTestingViewModel(isPremium: userIsPremuim)
        // Then
        XCTAssertEqual(vm.isPremium, userIsPremuim)
    }
    
    func test_UnitTestingViewModel_isPremium_shouldBeInjectedValue_stress() {
        for _ in 0..<10 {
        // Given
        let userIsPremuim: Bool = Bool.random()
        // When
        let vm = UnitTestingViewModel(isPremium: userIsPremuim)
        // Then
        XCTAssertEqual(vm.isPremium, userIsPremuim)
        }
    }
    
    func test_UnitTestingViewModel_dataArray_shouldBeEmpty() {
        // Given
        
        // When
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // Then
        XCTAssertTrue(vm.dataArray.isEmpty)
        XCTAssertEqual(vm.dataArray.count, 0)
    }
    
    func test_UnitTestingViewModel_dataArray_shouldAddItems() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let loopCount: Int = Int.random(in: 1..<100)
        for _ in 0..<loopCount {
            vm.addItem(item: UUID().uuidString)
        }
        // Then
        XCTAssertTrue(!vm.dataArray.isEmpty)
        XCTAssertFalse(vm.dataArray.isEmpty)
        XCTAssertEqual(vm.dataArray.count, loopCount)
        XCTAssertNotEqual(vm.dataArray.count, 0)
        XCTAssertGreaterThan(vm.dataArray.count, 0)
        
    }
    
    func test_UnitTestingViewModel_dataArray_shouldNotAddBlankString() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        vm.addItem(item: "")
        // Then
        XCTAssertTrue(vm.dataArray.isEmpty)        
    }
    
    func test_UnitTestingViewModel_dataArray_shouldNotAddBlankString2() {
        // Given
        guard let vm = viewModel else { XCTFail()
            return}
        // When
        vm.addItem(item: "")
        // Then
        XCTAssertTrue(vm.dataArray.isEmpty)
    }
    
    func test_UnitTestingViewModel_selectedItem_shouldStartAsNil() {
        // Given
        
        // When
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // Then
        XCTAssertTrue(vm.selectedItem == nil)
        XCTAssertNil(vm.selectedItem)
    }
    
    func test_UnitTestingViewModel_selectedItem_shouldBeNilWhenSelectingInvalidItem() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        //select valid item
        let newItem = UUID().uuidString
        vm.addItem(item: newItem)
        vm.selectItem(item: newItem)
        //select invalid item
        vm.selectItem(item: UUID().uuidString)
        // Then
        XCTAssertNil(vm.selectedItem)
    }
    
    func test_UnitTestingViewModel_selectedItem_shouldBeSelected() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let newItem = UUID().uuidString
        vm.addItem(item: newItem)
        vm.selectItem(item: newItem)
        // Then
        XCTAssertNotNil(vm.selectedItem)
        XCTAssertEqual(vm.selectedItem, newItem)
    }
    
    func test_UnitTestingViewModel_selectedItem_shouldBeSelected_stress() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let loopCount: Int = Int.random(in: 1..<100)
        var itemsArray: [String] = []
        for _ in 0..<loopCount {
            let newItem = UUID().uuidString
            vm.addItem(item: newItem)
            itemsArray.append(newItem)
        }
        let randomItem = itemsArray.randomElement() ?? ""
        XCTAssertFalse(randomItem.isEmpty)
        vm.selectItem(item: randomItem)
        // Then
        XCTAssertNotNil(vm.selectedItem)
        XCTAssertEqual(vm.selectedItem, randomItem)
    }
    
    func test_UnitTestingViewModel_saveItem_shouldThrowError_itemNotFound() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let loopCount: Int = Int.random(in: 1..<100)
        for _ in 0..<loopCount {
            vm.addItem(item: UUID().uuidString)
        }
        // Then
        XCTAssertThrowsError(try vm.saveItem(item: UUID().uuidString))
        XCTAssertThrowsError(try vm.saveItem(item: UUID().uuidString), "Should throw Item Not Found") { error in
            let returnedError = error as? UnitTestingViewModel.DataError
            XCTAssertEqual(returnedError, UnitTestingViewModel.DataError.itemNotFound)
        }
    }
    
    func test_UnitTestingViewModel_saveItem_shouldThrowError_noData() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let loopCount: Int = Int.random(in: 1..<100)
        for _ in 0..<loopCount {
            vm.addItem(item: UUID().uuidString)
        }
        // Then
        
        do {
            try vm.saveItem(item: "")
        } catch let error {
            let returnedError = error as? UnitTestingViewModel.DataError
            XCTAssertEqual(returnedError, UnitTestingViewModel.DataError.noData)
        }
        
        XCTAssertThrowsError(try vm.saveItem(item: ""))
        XCTAssertThrowsError(try vm.saveItem(item: ""), "Should throw No Data Error") { error in
            let returnedError = error as? UnitTestingViewModel.DataError
            XCTAssertEqual(returnedError, UnitTestingViewModel.DataError.noData)
        }
    }
    
    func test_UnitTestingViewModel_saveItem_shouldSaveItem() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let loopCount: Int = Int.random(in: 1..<100)
        var itemArray: [String] = []
        for _ in 0..<loopCount {
            let newItem = UUID().uuidString
            vm.addItem(item: newItem)
            itemArray.append(newItem)
        }
        let randomItem = itemArray.randomElement() ?? ""
        XCTAssertFalse(randomItem.isEmpty)
        // Then
        XCTAssertNoThrow(try vm.saveItem(item: randomItem))
        
        do {
            try vm.saveItem(item: randomItem)
        } catch {
            XCTFail()
        }
    }
    
    func test_UnitTestingViewModel_downloadWithEscaping_shouldReturnItems() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let expectation = XCTestExpectation(description: "Should return items after 3 seconds")
        
        vm.$dataArray
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.downloadWithEscaping()
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(vm.dataArray.count, 0)
        
    }
    
    func test_UnitTestingViewModel_downloadWithCombine_shouldReturnItems() {
        // Given
        let vm = UnitTestingViewModel(isPremium: Bool.random())
        // When
        let expectation = XCTestExpectation(description: "Should return items after a seconds")
        
        vm.$dataArray
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.downloadWithCombine()
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(vm.dataArray.count, 0)
        
    }
    
    func test_UnitTestingViewModel_downloadWithCombine_shouldReturnItems2() {
        // Given
        let items = [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString]
        let dataService: NewDataServiceProtocol = NewMockDataService(items: items)
        let vm = UnitTestingViewModel(isPremium: Bool.random(), dataService: dataService)
        // When
        let expectation = XCTestExpectation(description: "Should return items after a seconds")
        
        vm.$dataArray
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        vm.downloadWithCombine()
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(vm.dataArray.count, 0)
        XCTAssertEqual(vm.dataArray.count, items.count)
        
    }  


}

//
//  ImageSearchTests.swift
//  ImageSearchTests
//
//  Created by andrey.marshak on 06.08.2023.
//

import ConcurrencyExtras
@testable import ImageSearch
import XCTest

final class ImageSearchTests: XCTestCase {
    override func invokeTest() {
        withMainSerialExecutor {
            super.invokeTest()
        }
    }

    func testInitial() async throws {
        let searchHistory = [
            "Item 0",
            "Item 1",
            "Item 2",
            "Item 3",
        ]

        let mockApiService = ApiServiceMock(responses: [:])
        let mockStateConsumer = StateConsumerMock<ImgSearch.State>()

        let viewModel = ImageSearchViewModel(apiService: mockApiService)
        viewModel.add(consumer: mockStateConsumer)

        let updateToCallsCount = mockStateConsumer.updateToCallsCount
        XCTAssertEqual(updateToCallsCount, 1)

        let lastState = try XCTUnwrap(mockStateConsumer.updateToReceivedNewState)
        guard case let ImgSearch.State.initial(snapshot, context) = lastState else {
            XCTFail("Invalid state. Expected ImgSearch.State.error. Got: \(lastState)")
            return
        }

        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .history), searchHistory.count)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 0)

        XCTAssertEqual(context.query, nil)
        XCTAssertEqual(context.page, 0)
        XCTAssertEqual(context.hasMore, true)
    }

    func testLoad() async throws {
        let bundle = Bundle(for: ImageSearchTests.self)
        let path = bundle.url(forResource: "search", withExtension: "json")!
        let data = try Data(contentsOf: path)

        let mockApiService = ApiServiceMock(responses: [
            "services/rest": .data(data),
        ])

        let mockStateConsumer = StateConsumerMock<ImgSearch.State>()

        let viewModel = ImageSearchViewModel(apiService: mockApiService)
        viewModel.add(consumer: mockStateConsumer)

        let query = "Test query"
        await viewModel.search(query: query)
        await Task.yield()

        let updateToCallsCount = mockStateConsumer.updateToCallsCount
        XCTAssertEqual(updateToCallsCount, 2)

        let lastState = try XCTUnwrap(mockStateConsumer.updateToReceivedNewState)
        guard case let ImgSearch.State.loaded(snapshot, context) = lastState else {
            XCTFail("Invalid state. Expected ImgSearch.State.loaded. Got: \(lastState)")
            return
        }

        XCTAssertEqual(context.query, query)
        XCTAssertEqual(context.page, 1)
        XCTAssertEqual(context.hasMore, false)

        XCTAssertEqual(snapshot.numberOfSections, 1)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 2)
    }

    func testErrorLoad() async throws {
        let mockApiService = ApiServiceMock(responses: [
            "services/rest": .error(ImgSearch.Error.loadFailed),
        ])

        let mockStateConsumer = StateConsumerMock<ImgSearch.State>()

        let viewModel = ImageSearchViewModel(apiService: mockApiService)
        viewModel.add(consumer: mockStateConsumer)

        let query = "Test query"
        await viewModel.search(query: query)
        await Task.yield()

        let updateToCallsCount = mockStateConsumer.updateToCallsCount
        XCTAssertEqual(updateToCallsCount, 2)

        let lastState = try XCTUnwrap(mockStateConsumer.updateToReceivedNewState)
        guard case let ImgSearch.State.error(snapshot, context, error) = lastState else {
            XCTFail("Invalid state. Expected ImgSearch.State.error. Got: \(lastState)")
            return
        }

        XCTAssertEqual(context.query, query)
        XCTAssertEqual(error, ImgSearch.Error.loadFailed)

        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .history), 0)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 0)
    }
}

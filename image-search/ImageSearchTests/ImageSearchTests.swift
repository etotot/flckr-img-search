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
    func testInitial() async throws {
        let searchHistory = [
            "Item 0",
            "Item 1",
            "Item 2",
            "Item 3",
        ]

        let mockApiService = ApiServiceMock(responses: [:])
        let viewModel = ImageSearchViewModel(
            apiService: mockApiService,
            searchHistoryService: .init(),
            queryStateProducer: MockStreamStateProducer<String>(state: .never)
        )

        let task = Task {
            let spy = StateConsumerSpy<ImgSearch.State>()

            for await state in viewModel.state {
                spy.consume(state: state)

                if case ImgSearch.State.initial = state { break }
            }

            return spy
        }

        let spy = await task.value

        let state = try XCTUnwrap(spy.updateToReceivedNewState)
        guard case let ImgSearch.State.initial(snapshot, context) = state else {
            XCTFail("Invalid state. Expected ImgSearch.State.error. Got: \(state)")
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

        let viewModel = ImageSearchViewModel(
            apiService: mockApiService,
            searchHistoryService: .init(),
            queryStateProducer: MockStreamStateProducer<String>(state: .never)
        )

        let task = Task {
            let spy = StateConsumerSpy<ImgSearch.State>()

            for await state in viewModel.state {
                spy.consume(state: state)
                if case ImgSearch.State.loaded = state { break }
            }

            return spy
        }

        let query = "Test query"
        await viewModel.search(query: query)

        let spy = await task.value
        XCTAssertEqual(spy.updateToCallsCount, 3)

        let state = try XCTUnwrap(spy.updateToReceivedNewState)
        guard case let ImgSearch.State.loaded(snapshot, context) = state else {
            XCTFail("Invalid state. Expected ImgSearch.State.loaded. Got: \(state)")
            return
        }

        XCTAssertEqual(context.query, query)
        XCTAssertEqual(context.page, 1)
        XCTAssertEqual(context.hasMore, false)

        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .history), 0)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 2)
    }

    func testErrorLoad() async throws {
        let mockApiService = ApiServiceMock(responses: [
            "services/rest": .error(ImgSearch.Error.loadFailed),
        ])

        let viewModel = ImageSearchViewModel(
            apiService: mockApiService,
            searchHistoryService: .init(),
            queryStateProducer: MockStreamStateProducer<String>(state: .never)
        )

        let task = Task {
            let spy = StateConsumerSpy<ImgSearch.State>()

            for await state in viewModel.state {
                spy.consume(state: state)
                if case ImgSearch.State.error = state { break }
            }

            return spy
        }

        let query = "Test query"
        await viewModel.search(query: query)

        let spy = await task.value
        XCTAssertEqual(spy.updateToCallsCount, 3)

        let state = try XCTUnwrap(spy.updateToReceivedNewState)
        guard case let ImgSearch.State.error(snapshot, context, error) = state else {
            XCTFail("Invalid state. Expected ImgSearch.State.error. Got: \(state)")
            return
        }

        XCTAssertEqual(context.query, query)
        XCTAssertEqual(error, ImgSearch.Error.loadFailed)

        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .history), 0)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 0)
    }

    func testSearch() async throws {
        let bundle = Bundle(for: ImageSearchTests.self)
        let path = bundle.url(forResource: "search", withExtension: "json")!
        let data = try Data(contentsOf: path)

        let mockApiService = ApiServiceMock(responses: [
            "services/rest": .data(data),
        ])

        let mockStateProducer = MockStateProducer<String>()
        let viewModel = ImageSearchViewModel(
            apiService: mockApiService,
            searchHistoryService: .init(),
            queryStateProducer: mockStateProducer
        )

        let task = Task {
            let spy = StateConsumerSpy<ImgSearch.State>()

            for await state in viewModel.state {
                spy.consume(state: state)
                if case ImgSearch.State.loaded = state { break }
            }

            return spy
        }

        let query = "query"
        await mockStateProducer.send(state: query)

        let spy = await task.value
        XCTAssertEqual(spy.updateToCallsCount, 3)

        let state = try XCTUnwrap(spy.updateToReceivedNewState)
        guard case let ImgSearch.State.loaded(snapshot, context) = state else {
            XCTFail("Invalid state. Expected ImgSearch.State.loaded. Got: \(state)")
            return
        }

        XCTAssertEqual(context.query, query)
        XCTAssertEqual(context.page, 1)
        XCTAssertEqual(context.hasMore, false)

        XCTAssertEqual(snapshot.numberOfSections, 2)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .history), 0)
        XCTAssertEqual(snapshot.numberOfItems(inSection: .photos), 2)

    }
}

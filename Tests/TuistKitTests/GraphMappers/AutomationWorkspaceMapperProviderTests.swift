import Foundation
import TuistAutomation
import TuistCache
import TuistGenerator
import XCTest

@testable import TuistCore
@testable import TuistCoreTesting
@testable import TuistKit
@testable import TuistSupportTesting

final class AutomationWorkspaceMapperProviderTests: TuistUnitTestCase {
    private var subject: AutomationWorkspaceMapperProvider!
    private var workspaceMapperProvider: MockWorkspaceMapperProvider!

    override func setUp() {
        super.setUp()
        workspaceMapperProvider = .init()
        subject = AutomationWorkspaceMapperProvider(
            workspaceMapperProvider: workspaceMapperProvider
        )
    }

    override func tearDown() {
        workspaceMapperProvider = nil
        subject = nil
        super.tearDown()
    }

    func test_map_when_disableAutogeneratedSchemes() throws {
        // When
        let got = subject.mapper(
            config: Config.test(
                generationOptions: [
                    .disableAutogeneratedSchemes,
                ]
            )
        )

        // Then
        let sequentialWorkspaceMapper = try XCTUnwrap(got as? SequentialWorkspaceMapper)
        XCTAssertEqual(
            sequentialWorkspaceMapper.mappers
                .filter { $0 is AutogeneratedProjectSchemeWorkspaceMapper }.count,
            1
        )
    }

    func test_map() throws {
        // When
        let got = subject.mapper(
            config: Config.test()
        )

        // Then
        let sequentialWorkspaceMapper = try XCTUnwrap(got as? SequentialWorkspaceMapper)
        XCTAssertEqual(
            sequentialWorkspaceMapper.mappers.filter { $0 is AutomationPathWorkspaceMapper }.count,
            1
        )
        XCTAssertEqual(
            sequentialWorkspaceMapper.mappers.filter { $0 is AutogeneratedProjectSchemeWorkspaceMapper }.count,
            0
        )
    }
}

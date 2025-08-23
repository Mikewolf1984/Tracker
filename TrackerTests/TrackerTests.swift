import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {
    func testLightTrackersViewController() throws {
        let trackersViewController = TrackersViewController()
        trackersViewController.configureForTests()
        trackersViewController.loadViewIfNeeded()
        assertSnapshots(matching: trackersViewController, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }
    func testDarkTrackersViewController() throws {
        let trackersViewController = TrackersViewController()
        trackersViewController.configureForTests()
        trackersViewController.loadViewIfNeeded()
        assertSnapshots(matching: trackersViewController, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}



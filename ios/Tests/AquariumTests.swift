import XCTest
@testable import PukupukuAquarium

@MainActor
final class AquariumTests: XCTestCase {
    func testPublicConstraintWinRequiresEveryCell() {
        let puzzle = Puzzle.representative
        let rows = ["00000", "00111", "11110", "00111", "11111"]
        let marks = rows.joined().map { $0 == "1" ? CellMark.water : CellMark.dry }
        XCTAssertTrue(puzzle.isSolved(marks))
        var unfinished = marks
        unfinished[0] = .unknown
        XCTAssertFalse(puzzle.isSolved(unfinished))
        var bad = marks
        bad[1] = .water
        XCTAssertFalse(puzzle.isSolved(bad))
    }

    func testSingleGestureVisitsOnceAndUndoesAsOneUnit() {
        let game = GameState()
        game.restart()
        game.mode = .dry
        game.beginStroke()
        game.accept(index: 0)
        game.accept(index: 0) // same cell visited again in one stroke
        game.accept(index: 1)
        game.endStroke()
        XCTAssertEqual(game.cells[0], .dry)
        XCTAssertEqual(game.cells[1], .dry)
        game.undo()
        XCTAssertEqual(game.cells[0], .unknown)
        XCTAssertEqual(game.cells[1], .unknown)
    }

    func testUndoCanRestoreChangedMark() {
        let game = GameState()
        game.restart()
        game.mode = .water
        game.beginStroke()
        game.accept(index: 7)
        game.endStroke()
        game.mode = .dry
        game.beginStroke()
        game.accept(index: 7)
        game.endStroke()
        XCTAssertEqual(game.cells[7], .dry)
        game.undo()
        XCTAssertEqual(game.cells[7], .water)
    }
}

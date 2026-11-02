import Foundation
import SwiftUI

enum CellMark: Int, Codable {
    case unknown = -1
    case dry = 0
    case water = 1
}

struct Puzzle {
    let regionRows: [String]
    let rowTotals: [Int]
    let columnTotals: [Int]

    static let representative = Puzzle(
        regionRows: ["ABBCC", "ADBCC", "ADDDE", "FFDDE", "FFGGG"],
        rowTotals: [0, 3, 4, 3, 5],
        columnTotals: [2, 2, 4, 4, 3]
    )

    let size = 5

    func region(_ row: Int, _ column: Int) -> Character {
        Array(regionRows[row])[column]
    }

    // This predicate uses public constraints, not a stored answer.
    func isSolved(_ cells: [CellMark]) -> Bool {
        guard cells.count == size * size && cells.allSatisfy({ $0 != .unknown }) else {
            return false
        }
        for row in 0..<size {
            let count = (0..<size).filter { cells[row * size + $0] == .water }.count
            if count != rowTotals[row] { return false }
        }
        for column in 0..<size {
            let count = (0..<size).filter { cells[$0 * size + column] == .water }.count
            if count != columnTotals[column] { return false }
        }
        for regionName in Set(regionRows.joined()) {
            var occupiedRows = [Int: CellMark]()
            for row in 0..<size {
                for column in 0..<size where region(row, column) == regionName {
                    let mark = cells[row * size + column]
                    if let prior = occupiedRows[row], prior != mark { return false }
                    occupiedRows[row] = mark
                }
            }
            // Water may occupy lower rows only, with one horizontal surface.
            let waterRows = occupiedRows.filter { $0.value == .water }.map(\.key)
            let dryRows = occupiedRows.filter { $0.value == .dry }.map(\.key)
            if let minWater = waterRows.min(), let maxDry = dryRows.max(), minWater < maxDry {
                return false
            }
        }
        return true
    }
}

@MainActor
final class GameState: ObservableObject {
    let puzzle = Puzzle.representative
    @Published private(set) var cells: [CellMark] = Array(repeating: .unknown, count: 25)
    @Published var mode: CellMark = .water
    @Published var soundEnabled = true
    @Published var hapticsEnabled = true
    @Published var bubblesEnabled = true
    @Published private(set) var pulseIndex: Int?
    @Published private(set) var pulseSequence: UInt64 = 0

    private var history: [[CellMark]] = []
    private var touchedThisStroke: Set<Int> = []
    private var strokeActive = false
    private let feedback = FeedbackEngine()
    private let storageKey = "pukupuku.native.representative.01.v1"

    var isSolved: Bool { puzzle.isSolved(cells) }
    var canUndo: Bool { !history.isEmpty }

    init() {
        if let raw = UserDefaults.standard.array(forKey: storageKey) as? [Int],
           raw.count == 25,
           raw.allSatisfy({ CellMark(rawValue: $0) != nil }) {
            cells = raw.compactMap(CellMark.init(rawValue:))
        }
    }

    func beginStroke() {
        guard !isSolved else { return }
        history.append(cells)
        if history.count > 100 { history.removeFirst() }
        touchedThisStroke.removeAll()
        strokeActive = true
        objectWillChange.send()
    }

    func accept(index: Int) {
        guard strokeActive && (0..<cells.count).contains(index) else { return }
        // Revisiting a cell in the same stroke must not toggle or replay feedback.
        guard touchedThisStroke.insert(index).inserted else { return }
        guard cells[index] != mode else { return }
        cells[index] = mode
        UserDefaults.standard.set(cells.map(\.rawValue), forKey: storageKey)
        pulseIndex = index
        pulseSequence &+= 1
        feedback.play(water: mode == .water, haptics: hapticsEnabled, sound: soundEnabled)
    }

    func endStroke() {
        strokeActive = false
        touchedThisStroke.removeAll()
        // Do not leave an empty gesture on the undo stack.
        if let previous = history.last, previous == cells { history.removeLast() }
    }

    func undo() {
        endStroke()
        guard let prior = history.popLast() else { return }
        cells = prior
        pulseIndex = nil
        UserDefaults.standard.set(cells.map(\.rawValue), forKey: storageKey)
    }

    func restart() {
        endStroke()
        history.append(cells)
        cells = Array(repeating: .unknown, count: 25)
        pulseIndex = nil
        UserDefaults.standard.set(cells.map(\.rawValue), forKey: storageKey)
    }
}

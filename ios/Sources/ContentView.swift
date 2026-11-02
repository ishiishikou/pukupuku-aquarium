import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    @State private var showRestart = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text("ぷくぷく水槽")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.38, blue: 0.47))
                    Text("なぞって水面をととのえよう")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 22)

                Picker("入力モード", selection: $game.mode) {
                    Text("≈  水を入れる").tag(CellMark.water)
                    Text("×  水を入れない").tag(CellMark.dry)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                AquariumBoard(game: game)
                    .padding(15)
                    .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 12)

                Text(game.isSolved ? "水槽がととのいました！" : "数字はその行・列の水マス数です")
                    .font(.headline)
                    .foregroundStyle(game.isSolved ? .green : .secondary)

                HStack(spacing: 12) {
                    Button("ひとつ戻す", action: game.undo)
                        .disabled(!game.canUndo)
                    Button("最初から") { showRestart = true }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                VStack(alignment: .leading, spacing: 8) {
                    Text("遊び方").font(.headline)
                    Text("太い線が水槽の境界。水は下からたまり、同じ水槽の同じ高さはすべて水か、すべて乾燥になります。")
                    Text("水／×を選んで、指を滑らせてみてください。同じマスを一度のなぞりで通り直しても二重入力されません。")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 4) {
                    Toggle("触覚", isOn: $game.hapticsEnabled)
                    Picker("振動の強さ", selection: $game.hapticStrength) {
                        ForEach(HapticStrength.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .disabled(!game.hapticsEnabled)
                    Toggle("泡の音", isOn: $game.soundEnabled)
                    Toggle("泡の動き", isOn: $game.bubblesEnabled)
                }
                .padding(15)
                .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)

                Text("実機検証用の単問ビルド。触覚・音・なぞりの快さはiPhoneで評価します。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.86, green: 0.98, blue: 0.96), Color(red: 0.87, green: 0.93, blue: 0.99)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        )
        .alert("最初から遊びますか？", isPresented: $showRestart) {
            Button("キャンセル", role: .cancel) {}
            Button("やり直す", role: .destructive) { game.restart() }
        } message: {
            Text("今の入力は消えます。")
        }
    }
}

private struct AquariumBoard: View {
    @ObservedObject var game: GameState
    @State private var previousPoint: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width - 34, 365)
            let cell = side / 5.0
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Color.clear.frame(width: 34, height: 28)
                    ForEach(0..<5, id: \.self) { column in
                        Text("\(game.puzzle.columnTotals[column])")
                            .font(.headline.monospacedDigit())
                            .frame(width: cell, height: 28)
                    }
                }
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { row in
                            Text("\(game.puzzle.rowTotals[row])")
                                .font(.headline.monospacedDigit())
                                .frame(width: 34, height: cell)
                        }
                    }
                    board(cell: cell, side: side)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: min(UIScreen.main.bounds.width - 64, 365) + 36)
    }

    private func board(cell: CGFloat, side: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { column in
                            tile(row: row, column: column, side: cell)
                        }
                    }
                }
            }
        }
        .frame(width: side, height: side)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    if previousPoint == nil { game.beginStroke() }
                    trace(from: previousPoint ?? drag.location, to: drag.location, cell: cell)
                    previousPoint = drag.location
                }
                .onEnded { drag in
                    trace(from: previousPoint ?? drag.location, to: drag.location, cell: cell)
                    previousPoint = nil
                    game.endStroke()
                }
        )
        .accessibilityLabel("水槽パズル。5行5列。水か乾燥を選んでなぞる")
    }

    private func trace(from start: CGPoint, to end: CGPoint, cell: CGFloat) {
        // Interpolate between drag events so rapid swipes do not skip cells.
        let delta = hypot(end.x - start.x, end.y - start.y)
        let steps = max(1, Int(ceil(delta / max(cell / 3, 1))))
        for step in 0...steps {
            let fraction = CGFloat(step) / CGFloat(steps)
            let x = start.x + (end.x - start.x) * fraction
            let y = start.y + (end.y - start.y) * fraction
            let column = Int(floor(x / cell))
            let row = Int(floor(y / cell))
            if (0..<5).contains(row), (0..<5).contains(column) {
                game.accept(index: row * 5 + column)
            }
        }
    }

    private func tile(row: Int, column: Int, side: CGFloat) -> some View {
        let index = row * 5 + column
        let region = game.puzzle.region(row, column)
        let top = row == 0 || game.puzzle.region(row - 1, column) != region
        let bottom = row == 4 || game.puzzle.region(row + 1, column) != region
        let left = column == 0 || game.puzzle.region(row, column - 1) != region
        let right = column == 4 || game.puzzle.region(row, column + 1) != region
        let mark = game.cells[index]

        return ZStack {
            Rectangle()
                .fill(mark == .water ? Color(red: 0.30, green: 0.74, blue: 0.87) :
                      mark == .dry ? Color(red: 0.92, green: 0.96, blue: 0.96) :
                      Color(red: 0.98, green: 0.99, blue: 0.99))
            if mark == .water {
                Text("≈").font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(.white)
            } else if mark == .dry {
                Text("×").font(.system(size: 29, weight: .light)).foregroundStyle(.gray)
            } else {
                Circle().fill(.gray.opacity(0.25)).frame(width: 4, height: 4)
            }
            // Decorative feedback only; does not reveal unentered answers.
            if game.bubblesEnabled && game.pulseIndex == index {
                BubblePulse(sequence: game.pulseSequence)
            }
            Path { p in
                if top { p.move(to: .zero); p.addLine(to: CGPoint(x: side, y: 0)) }
                if bottom { p.move(to: CGPoint(x: 0, y: side)); p.addLine(to: CGPoint(x: side, y: side)) }
                if left { p.move(to: .zero); p.addLine(to: CGPoint(x: 0, y: side)) }
                if right { p.move(to: CGPoint(x: side, y: 0)); p.addLine(to: CGPoint(x: side, y: side)) }
            }
            .stroke(Color(red: 0.16, green: 0.45, blue: 0.57), lineWidth: 3)
            Rectangle().stroke(.white.opacity(0.6), lineWidth: 0.6)
        }
        .frame(width: side, height: side)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(row + 1)行 \(column + 1)列、水槽\(String(region))、\(mark == .water ? "水" : mark == .dry ? "乾燥" : "未確定")")
    }
}

private struct BubblePulse: View {
    let sequence: UInt64
    @State private var expanded = false

    var body: some View {
        Circle()
            .stroke(.white.opacity(expanded ? 0 : 0.8), lineWidth: 2)
            .scaleEffect(expanded ? 1.1 : 0.2)
            .padding(7)
            .onAppear { animate() }
            .onChange(of: sequence) { _, _ in animate() }
            .allowsHitTesting(false)
    }
    private func animate() {
        expanded = false
        withAnimation(.easeOut(duration: 0.28)) { expanded = true }
    }
}

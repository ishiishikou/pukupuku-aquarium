import AVFoundation
import CoreHaptics
import Foundation

// One shared event origin for visible bubble, audio and haptic feedback.
// Physical timing and perceived comfort still require real-iPhone validation.
@MainActor
final class FeedbackEngine {
    private var engine: CHHapticEngine?
    private let audioEngine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var audioReady = false
    private var lastAudioTime: TimeInterval = 0

    init() {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                let haptic = try CHHapticEngine()
                haptic.isAutoShutdownEnabled = true
                haptic.resetHandler = { [weak haptic] in try? haptic?.start() }
                try haptic.start()
                engine = haptic
            } catch {
                engine = nil
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
            audioEngine.attach(player)
            audioEngine.connect(player, to: audioEngine.mainMixerNode, format: format)
            try audioEngine.start()
            player.play()
            audioReady = true
        } catch {
            audioReady = false
        }
    }

    func play(water: Bool, haptics: Bool, sound: Bool, strength: HapticStrength) {
        if haptics, let engine {
            do {
                // Differentiate water and dry, never encode correctness.
                let intensity: Float = strength == .soft ? (water ? 0.19 : 0.10) : (water ? 0.42 : 0.23)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: water ? 0.23 : 0.67)
                    ],
                    relativeTime: 0
                )
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                try engine.start()
                let playback = try engine.makePlayer(with: pattern)
                try playback.start(atTime: CHHapticTimeImmediate)
            } catch {
                // Haptic hardware or system settings may suppress playback.
            }
        }
        guard sound, audioReady else { return }
        let now = ProcessInfo.processInfo.systemUptime
        // Avoid unbounded queued overlapping notes during a fast swipe.
        guard now - lastAudioTime >= 0.045 else { return }
        lastAudioTime = now

        let rate = 44_100.0
        let frames = AVAudioFrameCount(4_410)
        let format = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames),
              let samples = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = frames
        for i in 0..<Int(frames) {
            let t = Double(i) / rate
            let envelope = exp(-44.0 * t) * (1 - exp(-160.0 * t))
            let sweep = water ? 460.0 - 1_500.0 * t : 320.0 + 950.0 * t
            samples[i] = Float(sin(2 * .pi * sweep * t) * envelope * 0.12)
        }
        if !audioEngine.isRunning { try? audioEngine.start() }
        if !player.isPlaying { player.play() }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }
}

//
//  SoundManager.swift
//  Pomodo
//
//  Handles audio playback for timer completion
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Play Completion Sound
    func playCompletionSound() {
        // Use system sound for now
        // In production, you'd bundle a custom sound file
        AudioServicesPlaySystemSound(1007) // Standard "received" sound

        // Alternative: Use custom sound file
        // playSound(named: "completion", extension: "wav")
    }

    // MARK: - Play Custom Sound
    func playSound(named name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file not found: \(name).\(ext)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}

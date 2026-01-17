//
//  SoundManager.swift
//  Pomodo (macOS)
//
//  Handles audio playback for timer completion
//

import AVFoundation
import AppKit

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Play Completion Sound
    func playCompletionSound() {
        // Use system sound
        NSSound.beep()

        // Alternative: Use system sound by name
        // NSSound(named: "Glass")?.play()

        // Or use custom sound file:
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

    // MARK: - Play System Sound
    func playSystemSound(name: String) {
        NSSound(named: name)?.play()
    }
}

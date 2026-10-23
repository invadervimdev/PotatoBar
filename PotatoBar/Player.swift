import AVFoundation
import SwiftUI
import AppKit

class PBPlayer: ObservableObject {
    private var startWorkPlayer: AVAudioPlayer
    private var endWorkPlayer: AVAudioPlayer
    private var workingPlayer: AVAudioPlayer
    
    @AppStorage("startWorkSound") var startWorkSound: String = "windup" {
        didSet {
            setStartWorkPlayer()
            playStartWork()
        }
    }
    @AppStorage("endWorkSound") var endWorkSound: String = "ding" {
        didSet {
            setEndWorkPlayer()
            playEndWork() }
    }
    
    @AppStorage("startWorkVolume") var startWorkVolume: Double = 1.0 {
        didSet { updateVolumes() }
    }
    @AppStorage("endWorkVolume") var endWorkVolume: Double = 1.0 {
        didSet { updateVolumes() }
    }
    @AppStorage("workingVolume") var workingVolume: Double = 1.0 {
        didSet { updateVolumes() }
    }
    
    let mp3Sounds = ["attention", "bell", "chime", "correct", "futuristic", "level-up"]
    let wavSounds = ["ding", "ticking", "windup"]
    
    var allAvailableSounds: [String] {
        return (mp3Sounds + wavSounds).sorted()
    }
    
    init() {
        let placeholder = NSDataAsset(name: "wav-ding")!.data
        do {
            workingPlayer = try AVAudioPlayer(data: placeholder)
            startWorkPlayer = try AVAudioPlayer(data: placeholder)
            endWorkPlayer = try AVAudioPlayer(data: placeholder)
        } catch {
            fatalError("Failed to init placeholder players")
        }
        
        workingPlayer = preparePlayer(soundName: "ticking")
        workingPlayer.numberOfLoops = -1
        
        updateVolumes()
    }
    
    func playStartWork() {
        startWorkPlayer.play()
    }
    
    func playEndWork() {
        endWorkPlayer.play()
    }
    
    func playWorking() {
        workingPlayer.play()
    }
    
    func stopWorking() {
        workingPlayer.stop()
    }
    
    private func setStartWorkPlayer() {
        startWorkPlayer = preparePlayer(soundName: startWorkSound)
        startWorkPlayer.prepareToPlay()
    }
    private func setEndWorkPlayer() {
        endWorkPlayer = preparePlayer(soundName: endWorkSound)
        endWorkPlayer.prepareToPlay()
    }
    
    private func preparePlayer(soundName: String) -> AVAudioPlayer {
        let assetName: String = mp3Sounds.contains(soundName) ? "mp3-\(soundName)" : "wav-\(soundName)"
        
        let fileType: AVFileType = mp3Sounds.contains(soundName) ? .mp3 : .wav
        
        guard let playerAsset = NSDataAsset(name: assetName) else {
            fatalError("Failed to find asset named: \(soundName)")
        }
        
        
        do {
            return try AVAudioPlayer(data: playerAsset.data, fileTypeHint: fileType.rawValue)
        } catch {
            fatalError("Error initializing player for \(soundName): \(error)")
        }
    }
    
    private func updateVolumes() {
        startWorkPlayer.setVolume(Float(startWorkVolume), fadeDuration: 0)
        endWorkPlayer.setVolume(Float(endWorkVolume), fadeDuration: 0)
        workingPlayer.setVolume(Float(workingVolume), fadeDuration: 0)
    }
}

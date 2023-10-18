//
//  PlayerUI.swift
//  SwiftUIPlayer
//
//  Created by Carlos Ceja.
//

import SwiftUI

import BrightcovePlayerSDK


struct PlayerUI: UIViewRepresentable {
    typealias UIViewType = BCOVPUIPlayerView
    
    let playbackController: BCOVPlaybackController
    
    func makeUIView(context: Context) -> BCOVPUIPlayerView {
        playbackController.delegate = context.coordinator
        
        let options = BCOVPUIPlayerViewOptions()
        options.showPictureInPictureButton = true
        
        let controlsView = BCOVPUIBasicControlView.withVODLayout()
        controlsView?.layout = customLayout(with: context)
        
        guard let _playerView = BCOVPUIPlayerView(playbackController: playbackController, options: options, controlsView: controlsView) else {
            return BCOVPUIPlayerView(frame: .zero)
        }
        
        return _playerView
    }
    
    func updateUIView(_ playerView: BCOVPUIPlayerView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    fileprivate func customLayout(with context: Context) -> (BCOVPUIControlLayout?) {
        
        let playbackLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPlayback, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
        let muteButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
        let pictureInPictureLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPictureInPicture, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
        pictureInPictureLayoutView?.isRemoved = true
        let spacerLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1.0)
        if let muteButtonLayoutView = muteButtonLayoutView {
            let muteButton = UIButton(frame: muteButtonLayoutView.frame)
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            let largeBold = UIImage(systemName: "speaker.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            muteButton.setImage(largeBold, for: .normal)
            muteButtonLayoutView.addSubview(muteButton)
            
            muteButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleMute(sender:)), for: .touchUpInside)
        }
        
        // Configure the standard layout lines.
        let standardLayoutLine1 = [playbackLayoutView, spacerLayoutView, muteButtonLayoutView, pictureInPictureLayoutView]
        let standardLayoutLines = [standardLayoutLine1]
        
        // Configure the compact layout lines.
        let compactLayoutLine1 = [playbackLayoutView, spacerLayoutView, muteButtonLayoutView, pictureInPictureLayoutView]
        let compactLayoutLines = [compactLayoutLine1]
        
        // Put the two layout lines into a single control layout object.
        let layout = BCOVPUIControlLayout(standardControls: standardLayoutLines, compactControls: compactLayoutLines)
        
        return layout
    }
    
    
    final class Coordinator: NSObject, BCOVPlaybackControllerDelegate {
        
        private var player: AVPlayer?
        
        @objc
        final func handleMute(sender: UIButton) {
            guard let player = player else { return }
            player.isMuted = !player.isMuted
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
            let largeBold = UIImage(systemName: player.isMuted ? "speaker.slash.fill" : "speaker.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            
            sender.setImage(largeBold, for: .normal)
        }
        
        func playbackController(_ controller: BCOVPlaybackController?, didAdvanceTo session: BCOVPlaybackSession?) {
            guard let player = session?.player else { return }
            self.player = player
        }
    }
}

struct PlayerUI_Previews: PreviewProvider {
    
    static var playbackController = BCOVPlayerSDKManager.shared()?.createPlaybackController()
    
    static var previews: some View {
        PlayerUI(playbackController: playbackController!)
    }
}

//
//  PlayerViewController.swift
//  MyMusicPlayer
//
//  Created by mac on 24/12/2020.
//

import UIKit
import AVFoundation
import MediaPlayer
import WatchConnectivity

class PlayerViewController: UIViewController,AVAudioPlayerDelegate,WCSessionDelegate,EndDelegate{
    
    @IBOutlet var volume_slider: UISlider!
    
    @IBOutlet var music_slider: UISlider!
    @IBOutlet var cover_iv: UIImageView!
    
    @IBOutlet var song_label: UILabel!
    
    @IBOutlet var artist_label: UILabel!
    
    @IBOutlet var starttime_label: UILabel!
    @IBOutlet var endtime_label: UILabel!
    
    @IBOutlet var pause_button: UIButton!
    
    var session : WCSession!
    var playStatePhone: String = "pause"
    var playStateWatch: String = "playing"
    var changSong: String = "next"
    @IBOutlet var holder2: UIView!
    
    public var position: Int = 0
    public var songs: [Song] = []
    var song: Song = Song(name: "", artistName: "", imageName: "", trackName: "")
    
    @IBOutlet var holder: UIView!
    
    var player: AVAudioPlayer?
    
    var timer: Timer? = nil
    var time1 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        configure()

        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    func configure() {
        
        //set up player
        
        song = songs[position]
        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.audioSessionInterrupted(_:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted , object: AVAudioSession.sharedInstance())
        do{
            player = try AVAudioPlayer(contentsOf: URL(string: urlString!)!)
            
            player!.delegate = self
            player!.volume = 0.5
            player!.play()
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
           print("error occurred")
        }

        
        //set up user interface elements
        cover_iv.image = UIImage(named: song.imageName)
        song_label.text = song.name
        artist_label.text = song.artistName
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        let durationMinutes = Int(player!.duration / 60)
        let durationSeconds = Int(player!.duration - Double(durationMinutes * 60))
         
        endtime_label.text = "\(durationMinutes):\(durationSeconds)"
        
         playStatePhone = "playing"
        let reg = ["song": song.name, "artist": song.artistName, "playState":
                    playStatePhone,"position": position ] as [String : Any]
        session.transferCurrentComplicationUserInfo(reg)
       
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lyrics"{
        let vc  = segue.destination as! LyricsViewController
        vc.songname = songs[position].name
        vc.songartist = songs[position].artistName
        }else{
            let vc  = segue.destination as! PlaylistViewController
            vc.delegate = self
        }
    }
    
    func childDone (position: Int){
        player?.stop()
        self.position = position
        print("position = \(self.position)")
        configure()
    }
    
    @IBAction func pause_button(_ sender: Any) {
        if player?.isPlaying == true  {
            playStatePhone = "pause"
            let reg = [ "song": song.name, "artist": song.artistName, "playState":playStatePhone,"position":position] as [String : Any]
            session.transferCurrentComplicationUserInfo(reg)
            
            player?.pause()
            timer?.invalidate()
            pause_button.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            
        }else{
            playStatePhone = "playing"
            let reg = [ "song": song.name, "artist": song.artistName, "playState":playStatePhone,"position":position] as [String : Any]
            session.transferCurrentComplicationUserInfo(reg)
    
            player?.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            pause_button.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
        }
        
    }
    
    @IBAction func back_button(_ sender: Any) {
        if position > 0  {
            position = position - 1
            player?.stop()
            configure()
        }
    }
    
    @IBAction func next_button(_ sender: Any) {
        if(( position + 1 ) == songs.count ){
            position = 0
        }else{
       position = position + 1
        }
        player?.stop()
        
        configure()
    }
    
    @IBAction func playlist_button(_ sender: Any) {
        self.performSegue(withIdentifier: "play_list", sender: self)
    }
    
    @IBAction func lyrics_button(_ sender: Any) {
        self.performSegue(withIdentifier: "lyrics", sender: self)
    }

    @IBAction func voluem_slider(_ sender: Any) {
        let value = volume_slider.value
        player?.volume = value
    }
    
    @IBAction func music_slider(_ sender: Any) {
        player?.stop()
        player?.currentTime = Double(music_slider.value) * Double(player!.duration)
        player?.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,successfully flag: Bool){
        if flag {
                player.stop()
            if(( position + 1 ) == songs.count){
                position = 0
            }else{
           position = position + 1
            }
            timer?.invalidate()
            
            configure()
        }
    }
    
    
    @objc func updateProgress(){
        let currentTimeMinutes = Int(player!.currentTime / 60)
        let currentTimeSeconds = Int(player!.currentTime - Double(currentTimeMinutes * 60))
        starttime_label.text = "\(currentTimeMinutes):\(currentTimeSeconds)"
        music_slider.value = Float(player!.currentTime / player!.duration)
    }
    

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        DispatchQueue.main.async {
            let data = applicationContext as [String: Any]
            
            self.changSong = data["changSong"] as! String
            let isclick: Int = data["isclick"] as! Int
            self.playStateWatch = data["playState"] as! String
            
            if isclick == 1 {
            switch self.changSong {
        case "next":
            
            if(( self.position + 1 ) == self.songs.count ){
                self.position = 0
            }else{
                self.position = self.position + 1
            }
            self.player?.stop()
            
            self.configure()
            break
        case "last":
            if self.position > 0  {
                self.position = self.position - 1
                self.player?.stop()
                
                self.configure()
            }
            break
        default:
            break
        }
            }
        else {
            if self.playStateWatch == "pause"{
                self.player?.pause()
                self.playStatePhone = "pause"
                let reg = [ "song": self.song.name, "artist": self.song.artistName, "playState":self.playStatePhone,"position":self.position] as [String : Any]
                session.transferCurrentComplicationUserInfo(reg)
                self.pause_button.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
                
            }else{
                self.player?.play()
                self.playStatePhone = "playing"
                let reg = [ "song": self.song.name, "artist": self.song.artistName, "playState":self.playStatePhone,"position":self.position] as [String : Any]
                session.transferCurrentComplicationUserInfo(reg)
                self.pause_button.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
                
            }
        }
        }}

    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        if let error = error {
         print(error.localizedDescription)
         }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    @objc  func audioSessionInterrupted(_ notification:Notification)
       {
           print("interruption received: \(notification)")
       }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player!.rate == 0.0 {
                self.player!.play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player!.rate == 1.0 {
                self.player!.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songs[position].name

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player!.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player!.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player!.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}


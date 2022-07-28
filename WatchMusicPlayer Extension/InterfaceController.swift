//
//  InterfaceController.swift
//  WatchMusicPlayer Extension
//
//  Created by mac on 12/01/2021.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var song: WKInterfaceLabel!
    @IBOutlet var artist: WKInterfaceLabel!
    @IBOutlet var playButton: WKInterfaceButton!
    
    var changSong: String = "next"
    var playStateWatch: String = "playing"
    var playStatePhone: String = "playing"
    var isclick: Int = 0
    
    var session : WCSession!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func playLastSong() {
        changSong = "last"
        isclick = 1
        
        let reg = [ "changSong":
                        changSong,"playState":playStateWatch,"isclick": isclick] as [String : Any]
        do{ try session.updateApplicationContext(reg)}
        catch{
            print("send application context failed")
        }
        isclick = 0
       /*if(session.isReachable){
    session.sendMessage(reg, replyHandler: { (response) -> Void in
        print(response)
       }, errorHandler: { error in
        print("error sending last")
       })
        }*/
    }
    
    @IBAction func pauseSong() {
        
        if playStatePhone == "playing" {
            playStateWatch = "pause"
            
            
            let reg = [ "playState":
                        playStateWatch,"changSong":
                            changSong,"isclick": isclick] as [String : Any]
            do{ try session.updateApplicationContext(reg)}
            catch{
                print("send application context failed")
            }
            self.playButton.setBackgroundImage(UIImage(systemName: "pause.fill"))
           
        }else{
            playStateWatch = "playing"
            
            let reg = [ "playState":
                        playStateWatch,"changSong":
                            changSong,"isclick": isclick] as [String : Any]
            do{ try session.updateApplicationContext(reg)}
            catch{
                print("send application context failed")
            }
            self.playButton.setBackgroundImage(UIImage(systemName: "play.fill"))
            
        }
    }
    
    @IBAction func playNextSong() {
        changSong = "next"
        isclick = 1
        let reg = [ "changSong":
                        changSong,"playState":playStateWatch,"isclick": isclick] as [String : Any]
        
        do{ try session.updateApplicationContext(reg)}
        catch{
            print("send application context failed")
        }
        isclick = 0
        
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
        let data = userInfo as [String : Any]
        
            self.song.setText(data["song"] as! String)
            self.artist.setText(data["artist"] as! String)
            self.playStatePhone = data["playState"]! as! String
        
            if self.playStatePhone == "pause" {
            self.playButton.setBackgroundImage(UIImage(systemName: "play.fill"))
            
        }else{
            self.playButton.setBackgroundImage(UIImage(systemName: "pause.fill"))
        }
    }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
         print(error.localizedDescription)
         }
    }
}

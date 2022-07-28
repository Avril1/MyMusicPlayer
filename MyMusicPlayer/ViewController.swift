//
//  ViewController.swift
//  MyMusicPlayer
//
//  Created by mac on 24/12/2020.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    
    
    
    
    
    
    var songs = [Song]()
    var showView: String = ""
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
        table.delegate = self
        table.dataSource = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if showView == "playerview"{
        let d = segue.destination as! PlayerViewController
        let pos = table.indexPathForSelectedRow?.row
        let position = pos
        d.position = position!
        d.songs = songs
        }
    }
    
    @IBAction func addSongs(_ sender: Any) {
        
        //through iTunes
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
        in: .userDomainMask)[0]
        print("documentsPath=\(documentsPath)")
            let fm = FileManager.default
            let allfiels = try? fm.contentsOfDirectory(atPath: documentsPath.path)
        print("allfiels:\(allfiels)")
        let musicName = allfiels![0]
        print("musicName = \(musicName)")
            let musicPathURL = documentsPath.appendingPathComponent(musicName)
        print("musicPathURL = \(musicPathURL)")
        
        player = try! AVAudioPlayer(contentsOf: musicPathURL)
        player.prepareToPlay()

        player.play()
    }
    
    func configureSongs(){
        
        songs.append(Song(name: "endless love", artistName: "Mariah Carey", imageName: "endless", trackName: "EndlessLove"))
        songs.append(Song(name: "lucky one", artistName: "Mich", imageName: "lucky", trackName: "luckyone"))
        songs.append(Song(name: "romeo's tune", artistName: "Pajaro Sunrise", imageName: "tune", trackName: "Romeo'sTune"))
    }
    
    @IBAction func search_button(_ sender: Any) {
        showView = "showdetails"
        performSegue(withIdentifier: "search_segue", sender: self)
        showView = ""
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let song = songs[indexPath.row]
        //configure
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.artistName
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: song.imageName)
 
        
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 17)
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showView = "playerview"
        self.performSegue(withIdentifier: "id-del-segue", sender: self)
        showView = ""
    }
    

}

struct Song {
    let name: String
    let artistName: String
    let imageName: String
    let trackName: String
    
}


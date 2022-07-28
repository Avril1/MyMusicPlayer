//
//  PlaylistViewController.swift
//  MyMusicPlayer
//
//  Created by mac on 13/01/2021.
//

import UIKit

class PlaylistViewController: UITableViewController{
    
    
    public var songs: [Song] = []
    public var position: Int = 0
    var delegate: EndDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
    
    }
    
    func configureSongs(){
        
        songs.append(Song(name: "endless love", artistName: "Mariah Carey", imageName: "endless", trackName: "EndlessLove"))
        songs.append(Song(name: "lucky one", artistName: "Mich", imageName: "lucky", trackName: "luckyone"))
        songs.append(Song(name: "romeo's tune", artistName: "Pajaro Sunrise", imageName: "tune", trackName: "Romeo'sTune"))
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let song = songs[indexPath.row]
        //configure
        cell.textLabel?.text = song.name + " - " + song.artistName
        
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 12)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.childDone(position: indexPath.row)
        dismiss(animated: true, completion: nil)
    }
    

}
protocol EndDelegate {
 func childDone (position: Int)
}

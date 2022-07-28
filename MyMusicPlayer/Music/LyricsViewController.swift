//
//  LyricsViewController.swift
//  MyMusicPlayer
//
//  Created by mac on 21/01/2021.
//

import UIKit
import Foundation

class LyricsViewController: UIViewController {

    @IBOutlet var label_lyrics: UILabel!
    var songname: String = ""
    var songartist: String = ""
    var name: String = ""
    var artist: String = ""
    var lyrics: String = ""
    
    var  id_track: Int = 0
    var  id_artist: Int = 0
    var id_album: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.string(forKey: songname) != nil{
        lyrics = UserDefaults.standard.string(forKey: songname)!
            label_lyrics.text = lyrics
        }
    }
    
    @IBAction func searchLyrics(_ sender: Any) {
        
        print(songname)
        print(songartist)
        
        let nameString:[String] = songname.components(separatedBy: " ")
        var i: Int = 0
        while i < nameString.count {
           
            name = name + nameString[i] + "%20"
            i = i + 1
        }
        
        let artistString:[String] = songartist.components(separatedBy: " ")
        var n: Int = 0
        while n < artistString.count {
            
            artist = artist + artistString[n] + "%20"
            n = n + 1
        }
        
        print(name)
        print(artist)
        let request1 = NSMutableURLRequest(url: NSURL(string: "https://api.happi.dev/v1/music?q=\(name)\(artist)&limit=&apikey=9295456K5sFS6cozukHrfFXWVKEppAnSXeYFTR7wFBrntqF3UOgTZXRn&type=")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request1.httpMethod = "GET"
        

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request1 as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                            print(jsonData)

                    if jsonData["length"] as! Int == 0 {
                        self.lyrics = "No lyrics found"
                    }else{
                        let result = jsonData["result"] as! [[String:Any]]
                    self.id_track = result[0]["id_track"] as! Int
                    self.id_artist = result[0]["id_artist"] as! Int
                    self.id_album = result[0]["id_album"] as! Int
                    print(self.id_artist)
                    print(self.id_album)
                    print(self.id_track)
                   
                    let request2 = NSMutableURLRequest(url: NSURL(string: "https://api.happi.dev/v1/music/artists/\( self.id_artist)/albums/\( self.id_album)/tracks/\( self.id_track)/lyrics?apikey=9295456K5sFS6cozukHrfFXWVKEppAnSXeYFTR7wFBrntqF3UOgTZXRn")! as URL,
                                                            cachePolicy: .useProtocolCachePolicy,
                                                        timeoutInterval: 10.0)
                    
                    request2.httpMethod = "GET"
                    
                    let session2 = URLSession.shared
                    let dataTask2 = session2.dataTask(with: request2 as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
                        if (error != nil) {
                            print(error)
                        } else {
                            do {
                                
                                let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                                        print(jsonData)

                                    let result = jsonData["result"] as! [String:Any]
                                self.lyrics = result["lyrics"] as! String
                                
                                           }catch{
                                               
                                           }
                        }
                    })

                    dataTask2.resume()
                    }
                               }catch{
                                   
                               }
            }
        })
        dataTask.resume()
        
        
        
        Thread.sleep(forTimeInterval: 3)
        self.label_lyrics.text = self.lyrics
        UserDefaults.standard.setValue(self.lyrics, forKey: songname)
        
    }
    

    
   

}

//
//  SearchDetailsViewController.swift
//  MyMusicPlayer
//
//  Created by mac on 22/01/2021.
//

import UIKit

class SearchDetailsViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet var search_tf: UITextField!
    @IBOutlet var song_label: UILabel!
    @IBOutlet var artist_label: UILabel!
    @IBOutlet var album_label: UILabel!
    @IBOutlet var cover_imageView: UIImageView!
    
    var song: String = ""
    var artist: String = ""
    var album: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search_tf.delegate = self
        
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func search_button(_ sender: Any) {
        var searchText: [String] = (search_tf.text?.components(separatedBy: " "))!
        var urlText: String = ""
        var i: Int = 0
        while i < searchText.count {
            urlText = urlText + searchText[i] + "%20"
            i = i + 1
        }
        
        let request1 = NSMutableURLRequest(url: NSURL(string: "https://api.happi.dev/v1/music?q=\(urlText)&limit=&apikey=9295456K5sFS6cozukHrfFXWVKEppAnSXeYFTR7wFBrntqF3UOgTZXRn&type=")! as URL,
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
                        self.song = "No result found"
                        self.artist = "No result found"
                        self.album = "No result found"
                    }else{
                        let result = jsonData["result"] as! [[String:Any]]
                    self.song = result[0]["track"] as! String
                    self.artist = result[0]["artist"] as! String
                    self.album = result[0]["album"] as! String
                    let id_album: Int = result[0]["id_album"] as! Int
                        let url = URL(string:"https://api.happi.dev/v1/music/cover/\(id_album)")
                        self.getData(from:url!) { data, response, error in
                                guard let data = data, error == nil else { return }
                            print(response?.suggestedFilename ?? url!.lastPathComponent)
                                print("Download Finished")
                                DispatchQueue.main.async() { [weak self] in
                                    self?.cover_imageView.image = UIImage(data: data)
                                }
                            }
                    } }
                catch{
                                   
                               }
            }
        })
        dataTask.resume()
        Thread.sleep(forTimeInterval: 3)
        song_label.text = song
        artist_label.text = artist
        album_label.text = album
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

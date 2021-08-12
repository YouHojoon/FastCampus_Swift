//
//  SearchViewController.swift
//  MyNetflix
//
//  Created by joonwon lee on 2020/04/02.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension SearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {
            return UICollectionViewCell()
        }
        
        DispatchQueue.main.async {
//            cell.movieThumbnail?.image = self.thumbnailImageToPath(self.movies[indexPath.item].thumbnailPath)
            
            let url = URL(string: self.movies[indexPath.item].thumbnailPath)
            cell.movieThumbnail.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func thumbnailImageToPath(_ path: String) -> UIImage? {
        let url = URL(string: path)!
        do{
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        }catch{return nil}
       
    }
    
}
extension SearchViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        let item = AVPlayerItem(url: URL(string: movie.previewURL)!)
        let sb = UIStoryboard(name: "Player", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        vc.player.replaceCurrentItem(with: item)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 8
        let itemSpacing: CGFloat = 10
        
        let width = (collectionView.bounds.width - 2*itemSpacing - 2*margin) / 3
        let height = width * 10/7
        
        return CGSize(width: width, height: height)
    }
}

extension SearchViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchBar.resignFirstResponder()
        
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else {return}
        
        SearchAPI.search(searchTerm){movies in
            self.movies = movies
            DispatchQueue.main.async {
                self.resultCollectionView.reloadData()
            }
        }
        
    }
}

class SearchAPI {
    static func search(_ term:String, completion: @escaping ([Movie]) -> Void){
        
        
        let session = URLSession(configuration: .default)
        
        var urlComponet = URLComponents(string: "https://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name:"media", value: "movie")
        let entityQuery = URLQueryItem(name:"entity",value: "movie")
        let termQuery = URLQueryItem(name:"term",value: term)
        
        urlComponet.queryItems?.append(mediaQuery)
        urlComponet.queryItems?.append(entityQuery)
        urlComponet.queryItems?.append(termQuery)
        
        let dataTask = session.dataTask(with: urlComponet.url!){(data,response,error) in
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
                completion([])
                return
            }
            
            guard let resultData = data else{
                completion([])
                return
            }
            
            let movies = SearchAPI.parseMovies(resultData)
            print("\(movies.first!)")
            completion(movies)
        }
        
        dataTask.resume()
    }
    
    static func parseMovies(_ data: Data) -> [Movie]{
        let decoder = JSONDecoder()
        do{
            let response = try decoder.decode(Response.self, from: data)
            return response.movies
        }catch let error{
            print("parsing error: \(error.localizedDescription)")
            return []
        }
    }
}

class ResultCell: UICollectionViewCell{
    @IBOutlet weak var movieThumbnail: UIImageView!
}

struct Movie: Codable {
    let title: String
    let director: String
    let thumbnailPath: String
    let previewURL: String
    
    enum CodingKeys: String, CodingKey{
        case title = "trackName"
        case director = "artistName"
        case thumbnailPath = "artworkUrl30"
        case previewURL = "previewUrl"
    }
}

struct Response: Codable {
    let resultCount: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey{
        case resultCount
        case movies = "results"
    }
}

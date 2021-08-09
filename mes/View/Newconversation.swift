//
//  Newconversation.swift
//  mes
//
//  Created by Chun Hei Law on 8/7/21.
//

import Foundation
import SDWebImage

class Newconversation: UITableViewCell{
    static let identifier = "Newconversation"
    
    private let userimage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        return image
    }()
    
    private let nameLabel: UILabel = {
        let name = UILabel()
        name.font = .systemFont(ofSize: 22, weight: .medium)
        return name
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userimage)
        contentView.addSubview(nameLabel)
        contentView.layoutMargins = .zero
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userimage.frame = CGRect(x:10, y: 0, width: 50, height: 50)
    
        userimage.contentMode = .scaleAspectFit
        nameLabel.frame = CGRect(x: userimage.right + 10, y: 0, width: contentView.width-20-userimage.width, height: 50)
    }
    
    public func configure(with model: searchresult){
        nameLabel.text = model.name
        let path = "images/\(model.email)_profile_picture_png"
        StorageSet.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async{
                    self?.userimage.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get imageurl \(error)")
            }
        })
    }
}

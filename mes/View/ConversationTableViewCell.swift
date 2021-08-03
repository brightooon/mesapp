//
//  ConversationTableViewCell.swift
//  mes
//
//  Created by Chun Hei Law on 8/3/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 7, y: 7, width: 80, height: 80)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 10 - userImageView.width, height: (contentView.height - 20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom + 1, width: contentView.width - 10 - userImageView.width, height: (contentView.height - 20)/2)
    }
    public func configure(with model: conversation){
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        let path = "images/\(model.targetemail)_profile_picture_png"
        StorageSet.shared.downloadURL(for: path, completion: {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed: \(error)")
            }
        })
    }
}

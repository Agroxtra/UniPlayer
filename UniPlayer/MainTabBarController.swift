//
//  MainTabBarController.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 31.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class MainTabBarController : UITabBarController {
    private var isBarBig = false
    private weak var bar: UIView!
    private weak var barHeightConstraint: NSLayoutConstraint!
    private weak var songTitleLabel: UILabel!
    private weak var artistLabel: UILabel!
    private weak var artworkImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        self.bar = view
        self.bar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bar.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor).isActive = true
        self.barHeightConstraint = self.bar.heightAnchor.constraint(equalToConstant: self.tabBar.bounds.height)
        self.barHeightConstraint.isActive = true
        self.bar.backgroundColor = .red
        
        if let container = self.view.subviews.first { // MARK: a bit pfusch
            container.translatesAutoresizingMaskIntoConstraints = false
            container.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            container.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            container.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            container.bottomAnchor.constraint(equalTo: self.bar.topAnchor).isActive = true
        }
        
        let button = UIButton(frame: .zero)
        button.setTitle("⬆︎", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.bar.addSubview(button)
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.heightAnchor.constraint(lessThanOrEqualToConstant: self.tabBar.bounds.height).isActive = true

        let imgView = UIImageView(frame: .zero)
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .green
        self.bar.addSubview(imgView)
        self.artworkImgView = imgView
        self.artworkImgView.translatesAutoresizingMaskIntoConstraints = false
        self.artworkImgView.widthAnchor.constraint(equalTo: self.artworkImgView.heightAnchor).isActive = true
        self.artworkImgView.heightAnchor.constraint(equalToConstant: self.tabBar.bounds.height * 0.8).isActive = true
        self.artworkImgView.centerYAnchor.constraint(equalTo: self.bar.centerYAnchor).isActive = true
        self.artworkImgView.leftAnchor.constraint(equalTo: self.bar.leftAnchor, constant: 5).isActive = true
        
        let labelView = UIView(frame: .zero)
        self.bar.addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.centerYAnchor.constraint(equalTo: self.bar.centerYAnchor).isActive = true
        labelView.leftAnchor.constraint(equalTo: self.artworkImgView.rightAnchor, constant: 20).isActive = true
        labelView.rightAnchor.constraint(greaterThanOrEqualTo: button.leftAnchor).isActive = true
        
        let titleLbl = UILabel(frame: .zero)
        labelView.addSubview(titleLbl)
        titleLbl.text = "Test Title"
        titleLbl.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        titleLbl.sizeToFit()
        self.songTitleLabel = titleLbl
        self.songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.songTitleLabel.rightAnchor.constraint(greaterThanOrEqualTo: labelView.rightAnchor).isActive = true
        self.songTitleLabel.topAnchor.constraint(equalTo: labelView.topAnchor, constant: 0).isActive = true
        self.songTitleLabel.leftAnchor.constraint(equalTo: labelView.leftAnchor, constant: 0).isActive = true
        
        let artistLabel = UILabel(frame: .zero)
        artistLabel.text = "Test Artist"
        artistLabel.sizeToFit()
        labelView.addSubview(artistLabel)
        self.artistLabel = artistLabel
        self.artistLabel.translatesAutoresizingMaskIntoConstraints = false
        self.artistLabel.topAnchor.constraint(equalTo: self.songTitleLabel.bottomAnchor, constant: 5).isActive = true
        self.artistLabel.leftAnchor.constraint(equalTo: labelView.leftAnchor).isActive = true
        self.artistLabel.rightAnchor.constraint(greaterThanOrEqualTo: labelView.rightAnchor).isActive = true
        self.artistLabel.bottomAnchor.constraint(equalTo: labelView.bottomAnchor).isActive = true

        
    }
    
    @objc
    private func buttonPressed(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.isBarBig = !self.isBarBig

            self.barHeightConstraint.constant = (self.isBarBig ? 150 : self.tabBar.bounds.height)
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
                sender.transform = sender.transform.rotated(by: .pi)
            })
            
        }
    }
}

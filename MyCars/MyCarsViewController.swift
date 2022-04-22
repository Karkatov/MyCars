//
//  ViewController.swift
//  MyCars
//
//  Created by Duxxless on 20.04.2022.
//

import UIKit
import CoreData
import SnapKit

class MyCarsViewController: UIViewController {
    
    let carsImageView: UIImageView = {
        let imageVew = UIImageView()
        imageVew.contentMode = .scaleAspectFit
        return imageVew
    }()
    let myChoiceImageView: UIImageView = {
        let imageVew = UIImageView()
        imageVew.contentMode = .scaleAspectFit
        return imageVew
    }()
    let segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["1","2","3"])
        return segment
    }()
    let modelLabel = UILabel()
    let raitingLabel = UILabel()
    let numberOfTripsLabel = UILabel()
    let lastTimeStartedLabel = UILabel()
    
    let startEngineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start engine", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        return button
    }()
    let rateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rate", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        return button
    }()
    var context: NSManagedObjectContext!
    var cars = [Car]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        getDataFromFile()
    }

    private func setView() {
        
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true

        view.addSubview(carsImageView)
        view.addSubview(myChoiceImageView)
        view.addSubview(segmentedControl)
        view.addSubview(modelLabel)
        view.addSubview(raitingLabel)
        view.addSubview(numberOfTripsLabel)
        view.addSubview(lastTimeStartedLabel)
        view.addSubview(startEngineButton)
        view.addSubview(rateButton)
        
        makeConstraints()
        setDefaultValue()
        setButton()
        getDataFromFile()
    }
    
    private func makeConstraints() {
        
        carsImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(200)
        }
        segmentedControl.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.bottom.equalTo(carsImageView).inset(-100)
        }
        modelLabel.snp.makeConstraints { make in
            make.top.equalTo(carsImageView).inset(-20)
            make.left.equalTo(20)
        }
        lastTimeStartedLabel.snp.makeConstraints { make in
            make.bottom.equalTo(carsImageView).inset(-20)
            make.left.equalTo(20)
        }
        numberOfTripsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(lastTimeStartedLabel).inset(-30)
            make.left.equalTo(20)
        }
        raitingLabel.snp.makeConstraints { make in
            make.bottom.equalTo(carsImageView).inset(-20)
            make.right.equalTo(-20)
        }
        startEngineButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(20)
        }
        rateButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.right.equalTo(-20)
        }
    }
    
    private func setDefaultValue() {
        title = "111"
        carsImageView.image = UIImage(named: "bmwX6")
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemGray3
        
        numberOfTripsLabel.text = "numberOfTrips"
        numberOfTripsLabel.font = .systemFont(ofSize: 20)

        modelLabel.font = UIFont.boldSystemFont(ofSize: 30)
        modelLabel.text = "model"
        
        raitingLabel.text = "raiting"
        raitingLabel.font = UIFont.systemFont(ofSize: 20)
        
        lastTimeStartedLabel.font = .systemFont(ofSize: 20)
        lastTimeStartedLabel.text = "lastTimeStarted"
        
    }
    
    private func getDataFromFile() {
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        for dictionary in dataArray {
            
            guard let entity =  NSEntityDescription.entity(forEntityName: "Cars", in: context) else { return }
                let car = Car(entity: entity, insertInto: context)
                
                let carDictionary = dictionary as! [String : AnyObject]
                car.mark = carDictionary["mark"] as? String
                car.model = carDictionary["model"] as? String
                car.rating = carDictionary["rating"] as! Double
                car.lastStarted = carDictionary["lastStarted"] as? Date
                car.timesDriven = carDictionary["timesDriven"] as! Int16
                car.myChoice = carDictionary["myChoice"] as! Int16
                
                let imageName = carDictionary["imageName"] as! String
                let image = UIImage(named: imageName)
                let imageData = image?.pngData()
                car.imageData = imageData
                
                
                if let colorDictionary = carDictionary["tintColor"] as? [String : Float] {
                    car.tintColor = getColor(colorDictionary: colorDictionary)
                }
                cars.append(car)

        }
    }
    
    private func getColor(colorDictionary: [String : Float]) -> UIColor {
        guard let red = colorDictionary["red"],
                 let green = colorDictionary["green"],
                 let blue = colorDictionary["blue"] else { return UIColor() }
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
        return color
    }
    
    private func setButton() {
        startEngineButton.addTarget(self, action: #selector(startEnginePressed), for: .touchUpInside)
        rateButton.addTarget(self, action: #selector(rateItPressed), for: .touchUpInside)
    }
    
    @objc func startEnginePressed() {
        
    }
    
    @objc func rateItPressed() {
        
    }
}

extension MyCarsViewController {
    
}

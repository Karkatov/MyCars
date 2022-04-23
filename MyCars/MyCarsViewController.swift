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
    var segmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Lamborgini", "Ferrari", "Mercedes", "Nissan", "BMW"])
        return segment
    }()
    let modelLabel = UILabel()
    let raitingLabel = UILabel()
    let numberOfTripsLabel = UILabel()
    let lastTimeStartedLabel = UILabel()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
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
    var cars: [Car] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = Car.fetchRequest()
        do {
            cars = try context.fetch(fetchRequest)
            if cars.isEmpty {
                getDataFromFile()
            } else {
                insertDataFrom(selectedCar: cars[0])
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //deleteCarsInfo()
        setView()
        
        
        
        
    }
    
    private func setView() {
        
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemYellow
        segmentedControl.addTarget(self, action: #selector(showCar(segmentedControl:)), for: .valueChanged)
        numberOfTripsLabel.font = .systemFont(ofSize: 20)
        modelLabel.font = UIFont.boldSystemFont(ofSize: 30)
        raitingLabel.font = UIFont.systemFont(ofSize: 20)
        lastTimeStartedLabel.font = .systemFont(ofSize: 20)
        
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
        setButton()
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
    
    private func getDataFromFile() {
        print(cars)
        guard cars.isEmpty else { return }
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
        for dictionary in dataArray {
            
            guard let entity =  NSEntityDescription.entity(forEntityName: "Car", in: context) else { return }
            let car = Car(entity: entity, insertInto: context)
            
            let carDictionary = dictionary as! [String : AnyObject]
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoice = carDictionary["myChoice"] as! Bool
            
            let imageName = carDictionary["imageName"] as! String
            let image = UIImage(named: imageName)
            let imageData = image?.pngData()
            car.imageData = imageData
            
            if let colorDictionary = carDictionary["tintColor"] as? [String : Float] {
                car.tintColor = getColor(colorDictionary: colorDictionary)
            }
            cars.append(car)
            print(cars)
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            insertDataFrom(selectedCar: cars.first!)
        }
    }
    
    private func getColor(colorDictionary: [String : Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else { return UIColor() }
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
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
    
    @objc func showCar(segmentedControl: UISegmentedControl) {
        guard segmentedControl == self.segmentedControl else { return }
        let segmentIndex = segmentedControl.selectedSegmentIndex
        insertDataFrom(selectedCar: cars[segmentIndex])
    }
}

extension MyCarsViewController {
    
    private func deleteCarsInfo() {
        let fetchRequest = Car.fetchRequest()
        guard let cars = try? context.fetch(fetchRequest) else { return }
        for car in cars {
            context.delete(car)
        }
        guard ((try? context.save()) != nil) else { return }
    }
    
    private func insertDataFrom(selectedCar car: Car) {
        carsImageView.image = UIImage(data: car.imageData!)
        title = car.mark
        modelLabel.text = car.model
        myChoiceImageView.isHidden = !(car.myChoice)
        raitingLabel.text = "Рейтинг: \(car.rating) / 10"
        numberOfTripsLabel.text = "Kоличество поездок: \(car.timesDriven)"
        lastTimeStartedLabel.text = "Bремя поездки: \(dateFormatter.string(from: car.lastStarted!))"
        segmentedControl.selectedSegmentTintColor = car.tintColor as? UIColor
    }
}


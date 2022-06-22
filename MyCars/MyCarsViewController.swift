

import UIKit
import CoreData
import SnapKit

class MyCarsViewController: UIViewController {
    
    let modelLabel = UILabel()
    let raitingLabel = UILabel()
    let numberOfTripsLabel = UILabel()
    let lastTimeStartedLabel = UILabel()
    var context: NSManagedObjectContext!
    var car = Car()
    var cars: [Car] = []
    var timeUse: [Trip] = []
    var tableView = UITableView()
    var identifier = "Cell"
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
        let segment = UISegmentedControl(items: ["Lamborgini", "Ferrari", "BMW", "Mercedes", "Nissan"])
        return segment
    }()
    lazy var shortDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    lazy var mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    let startEngineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Начать поездку", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        return button
    }()
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отчистить", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.isEnabled = false
        return button
    }()
    let setRateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оценка", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 7
        button.backgroundColor = .systemYellow
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequest()
        setTableView()
        setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest = Trip.fetchRequest()
        let sort = NSSortDescriptor(key: "timeUse", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            timeUse = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if timeUse.isEmpty {
            clearButton.isEnabled = false
        } else {
            clearButton.isEnabled = true
        }
    }
    
    private func setView() {
        view.backgroundColor = .white
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemYellow
        segmentedControl.addTarget(self, action: #selector(showCar(segmentedControl:)), for: .valueChanged)
        numberOfTripsLabel.font = .systemFont(ofSize: 18)
        modelLabel.font = UIFont.boldSystemFont(ofSize: 30)
        raitingLabel.font = UIFont.systemFont(ofSize: 18)
        lastTimeStartedLabel.font = .systemFont(ofSize: 18)
        makeConstraints()
        setButton()
    }
    
    private func makeConstraints() {
        view.addSubview(carsImageView)
        view.addSubview(myChoiceImageView)
        view.addSubview(segmentedControl)
        view.addSubview(modelLabel)
        view.addSubview(raitingLabel)
        view.addSubview(numberOfTripsLabel)
        view.addSubview(lastTimeStartedLabel)
        view.addSubview(startEngineButton)
        view.addSubview(clearButton)
        view.addSubview(setRateButton)
        
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
            make.width.equalTo(135)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(20)
        }
        clearButton.snp.makeConstraints { make in
            make.width.equalTo(135)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.right.equalTo(-20)
        }
        setRateButton.snp.makeConstraints { make in
            make.top.equalTo(raitingLabel).inset(30)
            make.right.equalTo(raitingLabel)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        tableView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(segmentedControl.snp.bottom).inset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(40)
        }
    }
    
    private func fetchRequest() {
        let fetchRequest = Car.fetchRequest()
        do {
            cars = try context.fetch(fetchRequest)
            car = cars.first ?? Car()
            if cars.isEmpty {
                getDataFromFile()
            } else {
                insertDataFrom(selectedCar: car)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getDataFromFile() {
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
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        setRateButton.addTarget(self, action: #selector(setRate), for: .touchUpInside)
    }
    
    @objc func showCar(segmentedControl: UISegmentedControl) {
        guard segmentedControl == self.segmentedControl else { return }
        let segmentIndex = segmentedControl.selectedSegmentIndex
        insertDataFrom(selectedCar: cars[segmentIndex])
    }
    
    private func deleteInfo() {
        let fetchRequest = Trip.fetchRequest()
        guard let trips = try? context.fetch(fetchRequest) else { return }
        for trip in trips {
            context.delete(trip)
        }
        
        let fetchRequestCar = Car.fetchRequest()
        guard let cars = try? context.fetch(fetchRequestCar) else { return }
        for car in cars {
            car.timesDriven = 0
            car.rating = 0
        }
        
        guard ((try? context.save()) != nil) else { return }
        clearButton.isEnabled = false
        tableView.reloadData()
    }
    
    @objc func setRate() {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        car = cars[segmentIndex]
        if car.rating == 5 {
            car.rating = 0
        } else {
            car.rating += 1
        }
        insertDataFrom(selectedCar: car)
        
        guard ((try? context.save()) != nil) else { return }
    }
    
    private func insertDataFrom(selectedCar car: Car) {
        carsImageView.image = UIImage(data: car.imageData!)
        title = car.mark
        modelLabel.text = car.model
        myChoiceImageView.isHidden = !(car.myChoice)
        raitingLabel.text = "Рейтинг: \(Int(car.rating)) / 5"
        numberOfTripsLabel.text = "Kоличество поездок: \(car.timesDriven)"
        lastTimeStartedLabel.text = "Дата поездки: \(shortDateFormatter.string(from: car.lastStarted!))"
        segmentedControl.selectedSegmentTintColor = car.tintColor as? UIColor
    }
    
    private func setTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    @objc func startEnginePressed() {
       
        let currentlyTime = mediumDateFormatter.string(from: Date())
        saveTimeUse(time: currentlyTime, car: title!)
        
        let segmentIndex = segmentedControl.selectedSegmentIndex
        car = cars[segmentIndex]
        car.timesDriven += 1
        car.lastStarted = Date()
        insertDataFrom(selectedCar: car)
        
        guard ((try? context.save()) != nil) else { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        clearButton.isEnabled = true
    }
    
    @objc func clearPressed() {
        deleteInfo()
        insertDataFrom(selectedCar: car)
    }
    
    private func saveTimeUse(time: String, car: String) {
        let object = Trip(context: context)
        object.timeUse = time
        object.car = car
        guard ((try? context.save()) != nil) else { return }
        timeUse.insert(object, at: 0)
    }
}

extension MyCarsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeUse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        guard !timeUse.isEmpty else { return cell }
        let time = timeUse[indexPath.row]
        cell.textLabel?.text = time.car
        cell.detailTextLabel?.text = time.timeUse
        return cell
    }
}



import UIKit
import CoreData
import SnapKit

class CarsViewController: UIViewController {
    
    let modelLabel = UILabel()
    let raitingLabel = UILabel()
    let numberOfTripsLabel = UILabel()
    let lastTimeStartedLabel = UILabel()
    var car = Car()
    var cars: [Car] = []
    var trips = [Trip]()
    var tableView = UITableView()
    var identifier = "Cell"
    var context: NSManagedObjectContext!
    var segmentIndex = 0
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
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        StorageManager.shared.fetchRequestTrips { optionalTrips in
            if let newTrips = optionalTrips, !newTrips.isEmpty {
                trips = newTrips
                clearButton.isEnabled = true
            } else {
                clearButton.isEnabled = false
            }
        }
    }
}

// MARK: - Metods UITableViewDelegate, UITableViewDataSource

extension CarsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        guard !trips.isEmpty else { return cell }
        let time = trips[indexPath.row]
        cell.textLabel?.text = time.car
        cell.detailTextLabel?.text = time.timeUse
        return cell
    }
}

// MARK: - Metods
extension CarsViewController {
    private func configure() {
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
        StorageManager.shared.fetchRequestCar { fetchCars in
            if let fetchCars = fetchCars, !fetchCars.isEmpty {
                cars = fetchCars
                insertDataFrom(selectedCar: cars.first!)
            } else {
                StorageManager.shared.getDataFromFile { carsFromFile in
                    cars = carsFromFile
                    insertDataFrom(selectedCar: cars.first!)
                }
            }
        }
    }
    
    private func setButton() {
        startEngineButton.addTarget(self, action: #selector(startEnginePressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        setRateButton.addTarget(self, action: #selector(setRate), for: .touchUpInside)
    }
    
    @objc func showCar(segmentedControl: UISegmentedControl) {
        guard segmentedControl == self.segmentedControl else { return }
        segmentIndex = segmentedControl.selectedSegmentIndex
        insertDataFrom(selectedCar: cars[segmentIndex])
    }
    
    private func deleteInfo() {
        StorageManager.shared.deleteInfo()
        segmentedControl.selectedSegmentIndex = 0
        clearButton.isEnabled = false
        tableView.reloadData()
    }
    
    @objc func setRate() {
        segmentIndex = segmentedControl.selectedSegmentIndex
        StorageManager.shared.saveRate(cars[segmentIndex])
        insertDataFrom(selectedCar: cars[segmentIndex])
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
        StorageManager.shared.saveDetailOfTrip(currentlyTime, car: title!) { trip in
            trips.insert(trip, at: 0)
        }
        segmentIndex = segmentedControl.selectedSegmentIndex
        StorageManager.shared.newTrip(cars[segmentIndex])
        insertDataFrom(selectedCar: cars[segmentIndex])
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .fade)
        clearButton.isEnabled = true
    }
    
    @objc func clearPressed() {
        deleteInfo()
        insertDataFrom(selectedCar: cars.first!)
    }
}


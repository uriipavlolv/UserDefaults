//
//  ViewController.swift
//  UserDefauldsTest
//
//  Created by Alex on 18.03.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit

struct People: Codable {
    let name: String
    let age: Int
    let sexType: SexType
}

class Person: NSObject, NSCoding {
    
    let name: String
    let secondName: String
    let age: Int
    let sexType: SexType
    let city: String
    
    init(name: String, secondName: String, age: Int, sexType: SexType, city: String) {
        self.name = name
        self.secondName = secondName
        self.age = age
        self.sexType = sexType
        self.city = city
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: UserDefaultsKeys.name)
        coder.encode(secondName, forKey: UserDefaultsKeys.secondName)
        coder.encode(self.age, forKey: UserDefaultsKeys.age)
        coder.encode(sexType.rawValue, forKey: UserDefaultsKeys.sex)
        coder.encode(city, forKey: UserDefaultsKeys.city)
    }
    
    required init?(coder: NSCoder) {
        name        = coder.decodeObject(forKey: UserDefaultsKeys.name) as? String ?? ""
        secondName  = coder.decodeObject(forKey: UserDefaultsKeys.secondName) as? String ?? ""
        age         = coder.decodeInteger(forKey: UserDefaultsKeys.age)
        let sexStr  = coder.decodeObject(forKey: UserDefaultsKeys.sex) as? String ?? ""
        city        = coder.decodeObject(forKey: UserDefaultsKeys.city) as? String ?? ""
        sexType = SexType(rawValue: sexStr) ?? .male
    }
}

enum SexType: String, CaseIterable, Codable {
    case male = "Мужской"
    case female = "Женский"
}

let sexArr = SexType.allCases

enum UserDefaultsKeys {
    static let name = "name"
    static let secondName = "secondName"
    static let age = "age"
    static let sex = "sex"
    static let city = "city"
    static let person = "person"
    static let people = "people"
}

class ViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBOutlet weak var sexSegmentControl: UISegmentedControl!
    @IBOutlet weak var cityPickerView: UIPickerView!
    
    var person: Person!
    
    let ageArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let cityArray = ["qqqqq", "wwwww", "eeeee", "rrrrr", "ttttt", "yyyyyy", "uuuuuu", "iiiiii", "oooooo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        secondNameTextField.delegate = self
        agePickerView.dataSource = self
        agePickerView.delegate = self
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        
        sexSegmentControl.setTitle(SexType.male.rawValue, forSegmentAt: 0)
        sexSegmentControl.setTitle(SexType.female.rawValue, forSegmentAt: 1)
        
    }

    @IBAction func loadButtonPress() {
        
        // MARK: - load simple
        
        nameTextField.text = UserDefaults.standard.string(forKey: UserDefaultsKeys.name)
        secondNameTextField.text = UserDefaults.standard.string(forKey: UserDefaultsKeys.secondName)
        let age = UserDefaults.standard.integer(forKey: UserDefaultsKeys.age)
        if let index = ageArray.firstIndex(of: age) {
            agePickerView.selectRow(index, inComponent: 0, animated: true)
        }

        if let sexStr = UserDefaults.standard.string(forKey: UserDefaultsKeys.sex), let sex = SexType.init(rawValue: sexStr), let index = sexArr.firstIndex(of: sex) {
            sexSegmentControl.selectedSegmentIndex = index
        }

        if let city = UserDefaults.standard.string(forKey: UserDefaultsKeys.city), let index = cityArray.firstIndex(of: city) {
            cityPickerView.selectRow(index, inComponent: 0, animated: true)
        }
        
        // MARK: - load Class Object
        
        if let personData = UserDefaults.standard.object(forKey: UserDefaultsKeys.person) as? Data,
            let loadPerson = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(personData) as? Person {
            print("load person: \(loadPerson.name) \(loadPerson.secondName) \(loadPerson.age.description) \(loadPerson.sexType.rawValue) \(loadPerson.city)")
        }
        
        // MARK: - load Struct Object
        
        if let peopleData = UserDefaults.standard.object(forKey: UserDefaultsKeys.people) as? Data,
            let loadPeople = try? JSONDecoder().decode(People.self, from: peopleData) {
            print("load people: \(loadPeople.name) \(loadPeople.age.description) \(loadPeople.sexType.rawValue)")
        }
        
    }
    
    @IBAction func saveButtonPress() {
        
        // MARK: - save simple
        
        if let name = nameTextField.text, !name.isEmpty {
            UserDefaults.standard.set(name, forKey: UserDefaultsKeys.name)
        }

        if let secondName = secondNameTextField.text, !secondName.isEmpty {
            UserDefaults.standard.set(secondName, forKey: UserDefaultsKeys.secondName)
        }

        UserDefaults.standard.set(ageArray[agePickerView.selectedRow(inComponent: 0)], forKey: UserDefaultsKeys.age)

        let index = sexSegmentControl.selectedSegmentIndex
        let sexStr = sexArr[index].rawValue
        UserDefaults.standard.set(sexStr, forKey: UserDefaultsKeys.sex)

        UserDefaults.standard.set(cityArray[cityPickerView.selectedRow(inComponent: 0)], forKey: UserDefaultsKeys.city)
        
        
        // MARK: - save Class Object
        
        let person = Person(name: nameTextField.text!,
                            secondName: secondNameTextField.text!,
                            age: ageArray[agePickerView.selectedRow(inComponent: 0)],
                            sexType: sexArr[sexSegmentControl.selectedSegmentIndex],
                            city: cityArray[cityPickerView.selectedRow(inComponent: 0)])
        print("ready person: \(person.name) \(person.secondName) \(person.age.description) \(person.sexType.rawValue) \(person.city)")
        
        if let savePerson = try? NSKeyedArchiver.archivedData(withRootObject: person, requiringSecureCoding: false) {
            UserDefaults.standard.set(savePerson, forKey: UserDefaultsKeys.person)
        }
        
        // MARK: - save Struct Object
        
        let people = People(name: nameTextField.text!, age: ageArray[agePickerView.selectedRow(inComponent: 0)], sexType: sexArr[sexSegmentControl.selectedSegmentIndex])
        if let peopleData = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(peopleData, forKey: UserDefaultsKeys.people)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField { nameTextField.resignFirstResponder() }
        if textField == secondNameTextField { secondNameTextField.resignFirstResponder() }
        return true
    }
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == agePickerView { return 1 }
        if pickerView == cityPickerView { return 1 }
        return 0
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePickerView { return ageArray.count }
        if pickerView == cityPickerView { return cityArray.count }
        return 0
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == agePickerView { return ageArray[row].description }
        if pickerView == cityPickerView { return cityArray[row].description }
        return "-"
    }
}




struct Model : OLSTestable, OLSCalculable, IVCalculable, IVTestable, LogProb, ImportableFromTextFile, oddObservationQuantileSpotter, CSVImportable, CoreDataAnalysable, Codable{
    
    var name : String?
    var allObservations = [Observation]()
    var chosenX = [[Double]](){
        didSet{
            k = chosenX[0].count - 1
            n = chosenX.count
        }
    }
    var chosenY = [[Double]](){
        didSet{
            var tmp = [Double]()
            chosenY.forEach(){row in
                tmp.append(row[0])
            }
            flatY = tmp
        }
    }
    var chosenXHeader = [String]()
    var chosenYHeader = ""
    var flatY = [Double]()
    
    var withHeaders = false
    var observationLabeled = false
    var headers = [String]()
    var labels : [String]?{
        get{
            if observationLabeled{
                var tmp = [String]()
                allObservations.forEach { (obs) in
                    tmp.append(obs.label!)
                }
                return tmp
            }else{
                return nil
            }
        }
    }
    var n = 0
    var k = 0
    
    init(withHeaders : Bool, observationLabeled : Bool, path : String){
        let result = importFromTextFile(withHeaders: withHeaders, observationLabeled: observationLabeled, path: path)
        self.allObservations = result.observations
        self.n = result.n
        self.withHeaders = result.headered
        self.observationLabeled = result.labeled
        self.k = result.observations[0].observationArray.count
        if !withHeaders{
            for i in 0..<allObservations[0].observationArray.count{
                headers.append(String(UnicodeScalar(i+65)!))
            }
        }
    }
    init(path : String){
        self.withHeaders = false
        self.observationLabeled = false
        let result = loadDataFromCSV(path: path)
        self.allObservations = result.observations
        self.withHeaders = result.headered
        self.observationLabeled = result.labeled
        self.headers = result.headers
        self.n = allObservations.count
        self.k = allObservations[0].observationArray.count
    }
    init(){
        withHeaders = false
        observationLabeled = false
    }
}

enum ModelParametersCategory : String{
    case Critical = "Critical"
    case Warning = "Warning"
    case Normal = "Normal"
    case NAN = "Nan"
    case Other = "Other"
}

struct ModelParameters{
    let name : String
    var category : ModelParametersCategory
    let value : Double
    var description : String
    var imageName : String
    var videoName : String?
    var isLess : Bool?
    var variable : String?
    init(name : String, isLess : Bool? = nil,  criticalFloor : Double? = nil, warningFloor : Double? = nil, value : Double, description : String, imageName : String, videoName : String? = nil, variable : String? = nil){
        self.variable = variable
        self.description = description
        self.imageName = imageName
        self.videoName = videoName
        self.name = name
        self.value = value
        self.isLess = isLess
        
        if criticalFloor == nil || warningFloor == nil{
            self.category = .Other
        }else{
            if value.isNaN{
                self.category = .NAN
            }else if isLess!{
                if value <= criticalFloor! {
                    self.category = .Critical
                }
                else if value <= warningFloor! {
                    self.category = .Warning
                }
                else{
                    self.category = .Normal
                }
            }else{
                if value >= criticalFloor! {
                    self.category = .Critical
                }
                else if value >= warningFloor! {
                    self.category = .Warning
                }
                else{
                    self.category = .Normal
                }
            }
        }
        
       
    }
}

struct ModelParametersShort{
    let name : String
    var category : ModelParametersCategory
    let value : Double
    var isLess : Bool
    var criticalFloor : Double?
    var warningFloor : Double?
    var variable : String?
    
    init(name : String, value : Double, isLess : Bool, criticalFloor : Double?, warningFloor : Double?, variable : String?){
        self.name = name
        self.value = value
        self.isLess = isLess
        self.warningFloor = warningFloor
        self.criticalFloor = criticalFloor
        self.variable = variable
        if criticalFloor == nil || warningFloor == nil{
            self.category = .Other
        }else{
            if value.isNaN{
                self.category = .NAN
            }else if isLess{
                if value <= criticalFloor! {
                    self.category = .Critical
                }
                else if value <= warningFloor! {
                    self.category = .Warning
                }
                else{
                    self.category = .Normal
                }
            }else{
                if value >= criticalFloor! {
                    self.category = .Critical
                }
                else if value >= warningFloor! {
                    self.category = .Warning
                }
                else{
                    self.category = .Normal
                }
            }
        }
        
    }
}



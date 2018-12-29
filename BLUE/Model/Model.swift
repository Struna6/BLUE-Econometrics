


struct Model : OLSTestable, OLSCalculable, ImportableFromTextFile, Transposable, oddObservationQuantileSpotter, CSVImportable, Codable{
    var allObservations = [Observation]()
    var chosenX = [[Double]](){
        didSet{
            k = chosenX[0].count - 1
        }
    }
    var chosenY = [[Double]](){
        didSet{
            flatY = transposeArray(array: chosenY, rows: n, cols: 1)[0]
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
}

struct ModelParameters{
    let name : String
    var category : ModelParametersCategory
    let value : Double
    var description : String
    var imageName : String
    var videoName : String?
    var isLess : Bool
    
    init(name : String, isLess : Bool,  criticalFloor : Double, warningFloor : Double, value : Double, description : String, imageName : String, videoName : String?){
        self.description = description
        self.imageName = imageName
        (videoName?.isEmpty)! ? self.videoName = videoName : nil
        self.name = name
        self.value = value
        self.isLess = isLess

        if isLess{
            if value <= criticalFloor {
                self.category = .Critical
            }
            else if value <= warningFloor {
                self.category = .Warning
            }
            else{
                self.category = .Normal
            }
        }else{
            if value >= criticalFloor {
                self.category = .Critical
            }
            else if value >= warningFloor {
                self.category = .Warning
            }
            else{
                self.category = .Normal
            }
        }
       
    }
}

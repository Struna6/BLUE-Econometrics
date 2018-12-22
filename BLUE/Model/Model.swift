


struct Model : OLSCalculable, ImportableFromTextFile, Transposable, Codable{
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
    
    var withHeaders : Bool
    var observationLabeled : Bool
    var headers = [String]()
    var n : Int = 0
    var k : Int = 0
    
    init(withHeaders : Bool, observationLabeled : Bool, path : String){
        self.withHeaders = withHeaders
        self.observationLabeled = observationLabeled
        let result = importFromTextFile(withHeaders: withHeaders, observationLabeled: observationLabeled, path: path)
        self.allObservations = result.observations
        self.n = result.n
        self.headers = result.header!
        if !withHeaders{
            for i in 0..<allObservations[0].observationArray.count{
                headers.append(String(UnicodeScalar(i+65)!))
            }
        }
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
    let webLink : String
    
    init(name : String, criticalFloor : Double, warningFloor : Double, value : Double, webLink : String){
        self.webLink = webLink
        self.name = name
        self.value = value
        if value <= criticalFloor {
            self.category = .Critical
        }
        else if value <= warningFloor {
            self.category = .Warning
        }
        else{
            self.category = .Normal
        }
    }
}

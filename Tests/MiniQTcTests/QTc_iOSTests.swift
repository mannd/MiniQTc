//
//  QTc_iOSTests.swift
//  QTc_iOSTests
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017, 2018 EP Studios. All rights reserved.
//

import XCTest
@testable import MiniQTc

class QTc_iOSTests: XCTestCase {
    // Add formulas to these arrays as they are created
    let qtcFormulas: [Formula] = [.qtcBzt, .qtcFrd, .qtcFrm, .qtcHdg]
    // Accuracy for all non-integral measurements
    let delta = 0.0000001
    let roughDelta = 0.1
    let veryRoughDelta = 0.5  // accurate to nearest half integer
    let veryVeryRoughDelta = 1.0 // accurate to 1 integer
    // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
    // Note this table is not accurate within 0.5 bpm when converting back from interval to rate
    let rateIntervalTable: [(rate: Double, interval: Double)] = [(20, 3000),  (25, 2400),
                                                                 (30, 2000), (35, 1714), (40, 1500),
                                                                 (45, 1333), (50, 1200), (55, 1091),
                                                                 (60, 1000), (65, 923), (70, 857), (75, 800),
                                                                 (80, 750), (85, 706), (90, 667), (95, 632),
                                                                 (100, 600), (105, 571), (110, 545), (115, 522),
                                                                 (120, 500), (125, 480), (130, 462), (135, 444),
                                                                 (140, 429), (145, 414), (150, 400), (155, 387),
                                                                 (160, 375), (165, 364), (170, 353), (175, 343),
                                                                 (180, 333), (185, 324), (190, 316), (195, 308),
                                                                 (200, 300), (205, 293), (210, 286), (215, 279),
                                                                 (220, 273), (225, 267), (230, 261), (235, 255),
                                                                 (240, 250), (245, 245), (250, 240), (255, 235),
                                                                 (260, 231), (265, 226), (270, 222), (275, 218),
                                                                 (280, 214), (285, 211), (290, 207), (295, 203),
                                                                 (300, 200), (305, 197), (310, 194), (315, 190),
                                                                 (320, 188), (325, 185), (330, 182), (335, 179),
                                                                 (340, 176), (345, 174), (350, 171), (355, 169),
                                                                 (360, 167), (365, 164), (370, 162), (375, 160),
                                                                 (380, 158), (385, 156), (390, 154), (395, 152),
                                                                 (400, 150)]
    // uses online QTc calculator: http://www.medcalc.com/qtc.html, random values
    let qtcBztTable: [(qt: Double, interval: Double, qtc: Double)] = [(318, 1345, 274), (451, 878, 481), (333, 451, 496)]
    // TODO: Add other hand calculated tables for each formula
    // table of calculated QTc from
    let qtcMultipleTable: [(rate: Double, rrInSec: Double, rrInMsec: Double, qtInMsec: Double,
        qtcBzt: Double, qtcFrd: Double, qtcFrm: Double, qtcHDG: Double)] =
        [(88, 0.682, 681.8, 278, 336.7, 315.9, 327.0, 327.0), (112, 0.536, 535.7, 334, 456.3, 411.2, 405.5, 425.0),
         (47, 1.2766, 1276.6, 402, 355.8, 370.6, 359.4, 379.3), (132, 0.4545, 454.5, 219, 324.8, 284.8, 303, 345)]
    
    // TODO: Add new formulae here
    let qtcRandomTable: [(qtInSec: Double, rrInSec: Double, qtcMyd: Double, qtcRtha: Double,
        qtcArr: Double, qtcKwt: Double, qtcDmt: Double)] = [(0.217, 1.228, 0.191683142324075,
                                                             0.20357003257329, 0.188180853891965, 0.206138989195107, 0.199352096980993),
                                                            (0.617, 1.873, 0.422349852160997, 0.521139348638548,
                                                             0.540226253226725,0.527412865616186 , 0.476131661614717),
                                                            (0.441, 0.024, 4.19557027148694, 6.419, 0.744999998985912,
                                                             1.12043270968093, 2.05783877711859),
                                                            (0.626, 1.938, 0.419771215123981, 0.525004471964224,
                                                             0.545939267391605, 0.530561692609049, 0.47631825370458),
                                                            (0.594, 1.693, 0.432192914133319, 0.512952155936208,
                                                             0.527461134835087, 0.520741518839723, 0.477915505801712),
                                                            (0.522, 0.670, 0.664846401046771, 0.607701492537313,
                                                             0.585658505426308, 0.576968100296572, 0.615887811579245),
                                                            (0.162, 0.238, 0.385533865286431, 0.334890756302521,
                                                             0.400524764066341, 0.231937395103792, 0.29308171977912),
                                                            (0.449, 0.738, 0.539436462235939, 0.50213369467028,
                                                             0.496257865770434, 0.484431360905827, 0.509024942553452),
                                                            (0.364, 0.720, 0.443887132523326, 0.411185185185185,
                                                             0.415398777435965, 0.395155707875796, 0.416891521344714),
                                                            (0.279, 0.013, 3.84399149834848, 7.33984615384616,
                                                             0.583, 0.826263113547243, 1.67704840828666),
                                                            (0.184, 0.384, 0.328005981451736, 0.282388888888889,
                                                             0.347039639944786, 0.233741064151123, 0.27320524164178)]

    // QTp random test intervals
    let qtIntervals =
[0.587, 0.628, 0.774, 0.44, 0.61, 0.564, 0.322, 0.652, 0.611, 0.771, 0.522, 0.282, 0.255, 0.542, 0.4, 0.706, 0.301, 0.389, 0.486, 0.499]
    let rrIntervals = 
[1.04, 1.741, 0.803, 0.744, 0.462, 1.741, 0.814, 1.492, 1.217, 1.316, 1.072, 1.729, 1.631, 0.876, 0.738, 1.325, 1.066, 0.57, 0.603, 0.821]
    let qtpBztMaleResults =
[0.377327444005866, 0.488203748449354, 0.331557988894854, 0.319145108062148, 0.251491152925903, 0.488203748449354, 0.333821209631743, 0.451945571944233, 0.40817557496744, 0.42445305983112, 0.383088501524126, 0.486518344977864, 0.472529258353385, 0.346301025121209, 0.317855627604735, 0.425901984029189, 0.382014921174553, 0.279343874105018, 0.287316376143094, 0.335253486186199]
    let qtpBztFemaleResults = [0.407921561087423, 0.527787836161464, 0.358441069075518, 0.345021738445565, 0.271882327487463, 0.527787836161464, 0.360887794196479, 0.488589807507279, 0.441270891856692, 0.4588681727904, 0.414149731377433, 0.525965778354448, 0.510842441463119, 0.374379486617523, 0.343627705518633, 0.460434577328854, 0.41298910397249, 0.30199337741083, 0.310612298533075, 0.362436201282377]
    let qtpFrdResults =
[0.386559422661292, 0.458991603861966, 0.354631247099717, 0.345723947150657, 0.294952767914911, 0.458991603861966, 0.356243229467337, 0.435974838280842, 0.407350896973457, 0.41810989654274, 0.390484152137325, 0.457934624637034, 0.449113873741475, 0.365067512187644, 0.344792072153498, 0.41906087001553, 0.389754273515837, 0.316346792990953, 0.322337565550937, 0.357261488417636]
    let qtpHdgResults = [0.395038461538462, 0.435689833429064, 0.365240348692403, 0.354870967741935, 0.268727272727273, 0.435689833429064, 0.367007371007371, 0.425624664879357, 0.409722267871816, 0.416212765957447, 0.39805223880597, 0.435271255060729, 0.431622317596566, 0.37613698630137, 0.353723577235772, 0.416754716981132, 0.397500938086304, 0.311789473684211, 0.321870646766169, 0.3681071863581]
    let ages = [45, 43, 36, 49, 32, 57, 23, 45, 26, 31, 54, 45, 50, 49, 29, 26, 42, 47, 36, 42]

    // mocks for testing formula sources
    class TestQtcFormulas: QTcFormulaSource {
        static func qtcCalculator(formula: Formula) -> QTcCalculator {
            return QTcCalculator(formula: formula, longName: "TestLongName", shortName: "TestShortName", reference: "TestReference", equation: "TestEquation", baseEquation: { x, y, sex, age in x + y}, classification: .other, publicationDate: "1901")
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testConversions() {
        // sec <-> msec conversions
        XCTAssertEqual(QTc.secToMsec(1), 1000)
        XCTAssertEqual(QTc.secToMsec(2), 2000)
        XCTAssertEqual(QTc.msecToSec(1000), 1)
        XCTAssertEqual(QTc.msecToSec(2000), 2)
        XCTAssertEqual(QTc.msecToSec(0), 0)
        XCTAssertEqual(QTc.secToMsec(0), 0)
        XCTAssertEqual(QTc.msecToSec(2000), 2)                
        XCTAssertEqual(QTc.msecToSec(1117), 1.117, accuracy: delta)
        
        // bpm <-> sec conversions
        XCTAssertEqual(QTc.bpmToSec(1), 60)
        // Swift divide by zero doesn't throw
        XCTAssertNoThrow(QTc.bpmToSec(0))
        XCTAssert(QTc.bpmToSec(0).isInfinite)
        XCTAssertEqual(QTc.bpmToSec(0), Double.infinity)
        XCTAssertEqual(QTc.bpmToSec(0.333), 180.18018018018, accuracy: delta)
        
        // bpm <-> msec conversions
        // we'll check published conversion table with rough accuracy
        // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
        XCTAssertEqual(QTc.bpmToMsec(215), 279, accuracy: veryRoughDelta)
        for (rate, interval) in rateIntervalTable {
            XCTAssertEqual(QTc.bpmToMsec(rate), interval, accuracy: veryRoughDelta)
            XCTAssertEqual(QTc.msecToBpm(interval), rate, accuracy: veryVeryRoughDelta)
        }
    }
    
    func testQTcFunctions() {
        // QTcBZT (Bazett)
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec:0.3, rrInSec:1.0), 0.3, accuracy: delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec:300, rrInMsec:1000), 300, accuracy:delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 0.3, rate: 60), 0.3, accuracy: delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 300, rate: 60), 300, accuracy: delta)
        for (qt, interval, qtc) in qtcBztTable {
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qt, rrInMsec: interval), qtc, accuracy: veryRoughDelta)
        }
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 456, rate: 77), 516.6, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 369, rrInMsec: 600), 476.4, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 2.78, rate: 88), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)
        
        // QTcFRD (Fridericia)
        let qtcFrd = QTc.qtcCalculator(formula: .qtcFrd)
        XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: 456, rate: 77), 495.5, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: 369, rrInMsec: 600), 437.5, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 2.78, rate: 88), 3.1586, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.1586, accuracy: roughDelta)
        
        // run through multiple QTcs
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        for (rate, rrInSec, rrInMsec, qtInMsec, qtcBztResult, qtcFrdResult, qtcFrmResult, qtcHdgResult) in qtcMultipleTable {
            // all 4 forms of QTc calculation are tested for each calculation
            // QTcBZT
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qtInMsec, rate: rate), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)
            
            // QTcFRD
            XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            
            
            // QTcFRM
            XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            
            // QTcHDG
            XCTAssertEqual(try! qtcHdg.calculate(qtInMsec: qtInMsec, rate: rate), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)
            
        }
        
        // handle zero RR
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        // handle zero QT and RR
        XCTAssert(try! qtcFrd.calculate(qtInMsec: 0, rrInMsec: 0).isNaN)
        // handle negative RR
        XCTAssert(try! qtcBzt.calculate(qtInMsec: 300, rrInMsec: -100).isNaN)
        
    }
    
    // Most QTc functions will have QTc == QT at HR 60 (RR 1000 msec)
    func testEquipose() {
        let sampleQTs = [0.345, 1.0, 0.555, 0.114, 0, 0.888]
        // Subset of QTc formulae, only including non-exponential formulas
        let formulas: [Formula] = [.qtcBzt, .qtcFrd, .qtcHdg, .qtcFrm]
        
        for formula in formulas {
            let qtc = QTc.qtcCalculator(formula: formula)
            for qt in sampleQTs {
                XCTAssertEqual(try! qtc.calculate(qtInSec: qt, rrInSec: 1.0), qt)
            }
        }
    }
    
    func testQTcConvert() {
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 356.89, rrInMsec: 891.32), QTc.secToMsec(try! qtcBzt.calculate(qtInSec: 0.35689, rrInSec: 0.89132)))
        XCTAssertEqual(try! qtcHdg.calculate(qtInSec: 0.299, rrInSec: 0.5), QTc.msecToSec(try! qtcHdg.calculate(qtInMsec: 299, rate: 120)))
        XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: 843, rrInMsec: 300), try! qtcFrm.calculate(qtInMsec: 843, rate: 200))
    }
    
    
    func testMockSourceFormulas() {
        let qtcTest = QTc.qtcCalculator(formulaSource: TestQtcFormulas.self, formula: .qtcBzt)
        XCTAssertEqual(qtcTest.formula, .qtcBzt)
        XCTAssertEqual(qtcTest.longName, "TestLongName")
        XCTAssertEqual(qtcTest.shortName, "TestShortName")
        XCTAssertEqual(qtcTest.reference, "TestReference")
        XCTAssertEqual(qtcTest.equation, "TestEquation")
        XCTAssertEqual(qtcTest.publicationDate, "1901")
        XCTAssertEqual(try! qtcTest.calculate(qtInSec: 5, rrInSec: 7), 12)
    }
    
    func testClassification() {
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        XCTAssertEqual(qtcBzt.classification, .power)
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        XCTAssertEqual(qtcFrm.classification, .linear)
    }
    
    func testAbnormalQTc() {
        var qtcTest = QTcTest(value: 440, units: .msec, valueComparison: .greaterThan)
        var measurement = QTcMeasurement(qtc: 441, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 439, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 440, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 0.439, units: .sec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 0.441, units: .sec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        qtcTest = QTcTest(value: 440, units: .msec, valueComparison: .greaterThanOrEqual)
        measurement = QTcMeasurement(qtc: 440, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual)
        measurement = QTcMeasurement(qtc: 350, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 351, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual, sex: .female)
        measurement = QTcMeasurement(qtc: 311, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .male)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual, sex: .female, age: 18, ageComparison: .lessThan)
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female, age: 15)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        var testSuite = QTcTestSuite(name: "test", qtcTests: [qtcTest], reference: "test", description: "test")
        var result = testSuite.abnormalQTcTests(qtcMeasurement: measurement)
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result[0].severity == .abnormal)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
        
        
        measurement = QTcMeasurement(qtc: 355, units: .msec, sex: .female, age: 15)
        result = testSuite.abnormalQTcTests(qtcMeasurement: measurement)
        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
        
        let qtcTest2 = QTcTest(value: 440, units: .msec, valueComparison: .greaterThan, severity: .moderate)
        testSuite = QTcTestSuite(name: "test2", qtcTests: [qtcTest, qtcTest2], reference: "test", description: "test")
        measurement = QTcMeasurement(qtc: 500, units: .msec)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .moderate)
    }
    
    func testAbnormalQTcCriteria() {
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .schwartz1985) {
            var measurement = QTcMeasurement(qtc: 445, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            XCTAssert(testSuite.severity(measurement: measurement).isAbnormal())
            measurement = QTcMeasurement(qtc: 0.439, units: .sec)
            XCTAssertFalse(testSuite.severity(measurement: measurement).isAbnormal())
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .fda2005) {
            var measurement = QTcMeasurement(qtc: 455, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .mild)
            measurement = QTcMeasurement(qtc: 485, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .moderate)
            measurement = QTcMeasurement(qtc: 600, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .severe)
            measurement = QTcMeasurement(qtc: 450, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .aha2009) {
            var measurement = QTcMeasurement(qtc: 450, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            measurement = QTcMeasurement(qtc: 460, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            // we leave out the sex here to get undefined value
            measurement = QTcMeasurement(qtc: 460, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
            measurement = QTcMeasurement(qtc: 459, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 390, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .esc2005) {
            var measurement = QTcMeasurement(qtc: 450, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            measurement = QTcMeasurement(qtc: 460, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 461, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            // we leave out the sex here to make sure we get an undefined value
            measurement = QTcMeasurement(qtc: 461, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
            measurement = QTcMeasurement(qtc: 459, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 290, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .goldenberg2006) {
            var m = QTcMeasurement(qtc: 445, units: .msec) // requires age and sex
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male, age: 20)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 10)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .male, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .schwartz1993) {
            var m = QTcMeasurement(qtc: 445, units: .msec) // requires sex
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male, age: 20)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 10)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 451, units: .msec, sex: .male, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .mild)
            m = QTcMeasurement(qtc: 451, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
        }
        // test short QTc
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .gollob2011) {
            var m = QTcMeasurement(qtc: 0.345, units: .sec)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 315, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .severe)
            m = QTcMeasurement(qtc: 370, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 369.99999, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .mild)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .mazzanti2014) {
            var m = QTcMeasurement(qtc: 360, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 335, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
        }
        
    }
    

    func testCutoffs() {
        let test = AbnormalQTc.qtcTestSuite(criterion: .schwartz1985)
        let cutoffs = test?.cutoffs(units: .sec)
        XCTAssertEqual(cutoffs![0].value, 0.44)
        let cutoffsMsec = test?.cutoffs(units: .msec)
        XCTAssertEqual(cutoffsMsec![0].value, 440.0)
    }

    typealias formulaTest = (formula: Formula, result: Double)
    typealias formulaTests = [formulaTest]

    func testShortNames() {
        for formula in qtcFormulas {
            XCTAssertEqual(QTc.qtcCalculator(formula: formula).shortName.prefix(3), "QTc")
        }
    }
}

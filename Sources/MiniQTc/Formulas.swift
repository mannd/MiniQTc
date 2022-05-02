//
//  Formulas.swift
//  Formulas
//
//  Created by David Mann on 9/18/17.
//  Copyright © 2017, 2018 EP Studios. All rights reserved.
//

import Foundation

/// Source for all QTc and QTp formulas
struct Formulas: QTcFormulaSource {
    
    static let errorMessage = "Formula not found!"
    
    // These functions are required by the protocols used by this class
    static func qtcCalculator(formula: Formula) -> QTcCalculator {
        guard let calculator = qtcDictionary[formula] else {
            fatalError(errorMessage)
        }
        return calculator
    }
    
    // Power QTc formula function
    // These have form QTc = QT / pow(RR, exp)
    private static func qtcExp(qtInSec: Double, rrInSec: Double, exp: Double) -> Sec {
        return qtInSec / pow(rrInSec, exp)
    }
    
    // Linear QTc formula function
    // These have form QTc = QT + α(1 - RR)
    private static func qtcLinear(qtInSec: Double, rrInSec: Double, alpha: Double) -> Sec {
        return qtInSec + alpha * (1 - rrInSec)
    }

    // This is the data source for the formulas.  Potentially this could be a database, but there
    // aren't that many formulas, so for now the formulas are inlined here.
    static let qtcDictionary: [Formula: QTcCalculator] =
        [.qtcBzt:
            QTcCalculator(formula: .qtcBzt,
                          longName: "Bazett",
                          shortName: "QTcBZT",
                          reference: """
                                        original: Bazett HC. An analysis of the time-relations of electrocardiograms. Heart 1920;7:353–370.
                                        reprint: Bazett H. C. An analysis of the time‐relations of electrocardiograms. Annals of Noninvasive Electrocardiology. 2006;2(2):177-194. doi:10.1111/j.1542-474X.1997.tb00325.x
                                        """,
                          equation: "QT/\u{221A}RR",
                          baseEquation: {qtInSec, rrInSec, _, _ in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 0.5)},
                          classification: .power,
                          notes: "Oldest, most commonly used formula, but inaccurate at extremes of heart rate.  Healthy subjects: 20 men, age 14 - 40 (including one with age labeled \"Boy\"), 19 women, age 20 - 53.  Majority of subjects in their 20s.",
                          publicationDate: "1920",
                          numberOfSubjects: 39),
         .qtcFrd:
            QTcCalculator(formula: .qtcFrd,
                          longName: "Fridericia",
                          shortName: "QTcFRD",
                          reference: "Fridericia LS. Die Systolendauer im Elektrokardiogramm bei normalen Menschen und bei Herzkranken. Acta Medica Scandinavica. 1920;53(1):469-486. doi:10.1111/j.0954-6820.1920.tb18266.x",
                          equation: "QT/\u{221B}RR",
                          baseEquation: {qtInSec, rrInSec, _, _ in qtcExp(qtInSec: qtInSec, rrInSec: rrInSec, exp: 1 / 3.0)},
                          classification: .power,
                          notes: "50 normal subjects, 28 men, 22 women, ages 2 to 81, most (35) age 20 to 40.  HR range 51-135.",
                          publicationDate: "1920",
                          numberOfSubjects: 50),
         .qtcFrm:
            QTcCalculator(formula: .qtcFrm,
                          longName: "Framingham",
                          shortName: "QTcFRM",
                          reference: "Sagie A, Larson MG, Goldberg RJ, Bengtson JR, Levy D. An improved method for adjusting the QT interval for heart rate (the Framingham Heart Study). American Journal of Cardiology. 1992;70(7):797-801. doi:10.1016/0002-9149(92)90562-D",
                          equation: "QT + 0.154*(1-RR)",
                          baseEquation: {qtInSec, rrInSec, _, _ in qtcLinear(qtInSec: qtInSec, rrInSec: rrInSec, alpha: 0.154)},
                          classification: .linear,
                          notes: "5,018 subjects, 2,239 men and 2,779 women, from Framingham Heart Study.  Mean age 44 years (28-62). CAD, subjects on AADs or tricyclics or with extremes of HR excluded.",
                          publicationDate: "1992",
                          numberOfSubjects: 5018),
         .qtcHdg:
            QTcCalculator(formula: .qtcHdg,
                          longName: "Hodges",
                          shortName: "QTcHDG",
                          reference: "Hodges M, Salerno D, Erlien D. Bazett’s QT correction reviewed: Evidence that a linear QT correction for heart rate is better. J Am Coll Cardiol. 1983;1:1983.",
                          equation: "QT + 1.75*(HR-60)",
                          baseEquation: {qtInSec, rrInSec, _, _ in qtInSec + 0.00175 * (QTc.secToBpm(rrInSec) - 60)},
                          classification: .rational,
                          notes: "607 normal subjects, 303 men, 304 women, ages from 20s to 80s.",
                          publicationDate: "1983",
                          numberOfSubjects: 607),
    ]
    
}

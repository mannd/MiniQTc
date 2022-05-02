# MiniQTc

## Minimal Swift package version of the QTc library
This QTc Swift package includes a multitude of formulas for QTc and QTp calculation, both common and obscure.  It is intended for use in iOS and macOS programs.  It is written in Swift but can be used in Objective C projects.  This library is free to use in your own apps and programs.  Usages include designing simple QTc calculators to medical research involving calculated QTc and QTp intervals.  For more background on this project, see the blog post [Hacking the QTc](https://www.epstudiossoftware.com/hacking-the-qtc/).


## Installation
Install this library via the Xcode Swift package manager.

## Using the library

### Formulas
QTc and QTp formulas are labeled based on the proposed standard nomenclature of [Rabkin et al.](https://www.wjgnet.com/1949-8462/full/v7/i6/315.htm#B16).  The QT interval normally shortens with increasing heart rate.  QTc formulas try to correct the QT interval for heart rate and assume the QT = QTc at a heart rate of 60.  Ideally in an individual subject, the QTc will not change at different heart rates.  QTp formulas predict the "normal" QT based on heart rate.  Don't confuse the QTp with the same term QTp used in some recent studies to indicate a corrected QT interval measured to the the peak, rather than the end of the T wave.  Over the years many QTc and QTp formulas have been developed.  The most commonly used is still Bazett's 1920 QTc formula, despite its flaws.

Use the enum `Formula` to select QTc or QTp formulas:

	public enum Formula {
		// QTc formulas
		case qtcBzt  // Bazett
		case qtcFrd  // Fridericia
		case qtcFrm  // Framingham
		case qtcHdg  // Hodges

### Calculators
The easiest way to get a calculator for a specific formula is to generate one using this static factory class:

	let calculator = QTc.calculator(formula: .qtcBzt) // generates a Bazett QTc calculator (Swift)

	Calculator calculator = [QTc calculatorWithFormula: Formula.qtcBzt]; // Qbjective C

Most of the following examples are given as Swift code.  See [Apple's reference](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) for more information on calling Swift functions from Objective C.

Here is a QTp calculator:

	let calculator = QTc.calculator(formula: .qtpFrd) // Friedericia QTp calculator

QTc and QTp calculators have types of `QTcCalculator` and `QTpCalculator` and are subclasses of the base class `Calculator`.  Using a calculator generated in this way to calculate a QTc or QTp requires passing a `QtMeasurement` struct to the calculator.

### QtMeasurement

The `QtMeasurement` struct is a convenient way to package the measurements required for a QTc or QTp calculation.  It is defined as:

	public struct QtMeasurement {
		public let qt: Double? // an optional, since QT not needed for QTp
		public let intervalRate: Double  // RR interval or HR
		public let units: Units // may be .msec or .sec
		public let intervalRateType: IntervalRateType // may be .bpm or .interval
		public let sex: Sex = .unspecified // .male or .female, not required by many formulas
		public let age: Int? = nil  // may be nil as not always needed
	}

Units can be `.msec` or `.sec`, and `IntervalRateType` either `.bpm` or `.interval` (meaning the heart rate is given as beats per minute or an RR interval).  `Sex` is `.male`, `.female`, or `.unspecified` (not all formulas require sex or age).  A complete example for calculating a QTc interval using the Bazett formula is as follows.

	let qtMeasurement = QtMeasurement(qt: 367.0, intervalRate: 777.0, units: .msec, intervalRateType: .interval)
	let qtcBztCalculator = QTc.calculator(formula: .qtcBzt)
	let qtc = qtcBztCalculator.calculate(qtMeasurement) // qtc = 416.34711041

Note that if the `QtMeasurement` units are msec, the calculator returns a result in msec; if the units are secs, the result is in secs.

### More ways to calculate (aka the less easy way)
If you are less interested in a universal calculator object that handles QTc and QTp calculations the same way, you can instantiate specific QTc and QTp calculator classes.  These classes don't require use of the `QtMeasurement` struct. You can pass to their calculate methods parameters in secs or msecs directly.

For example:

	let qtcBztCalculator = QTc.qtcCalculator(formula: .qtcBzt) // Swift

	QTcCalculator qtcBztCalculator = [QTc qtcCalculatorWithFormula: Formula.qtcBzt]; // Objective C

Then use the calculator to calculate the QTc:

	let qtcBzt = qtcBztCalculator.calculate(qtInSec: 0.334, rrInSec: 0.785) // Swift

	double qtcBzt = [qtcBztCalculator calculateWithQtInSec: 0.334 rrInSec: 0.785]; // Objective C

### Calculate functions
When using the `QTcCalculator` or `QTpCalculator` classes, each calculate function has 4 different signatures, using QT in sec or msec, RR in sec or msec or heart rate in beats per minute.  Functions using msec parameters return QTc in msec, while those using sec parameters return QTc in seconds.  All interval/rate parameters are `Double` in Swift, `double` in Objective C.  For example:

	let qtcInMsec = qtcBztCalculator.calculate(qtInMsec: 402, rate 72) // returns QTc in msec
	let qtcInSec = qtcBztCalculator.calculate(qtInSec: 0.402, rate 72) // returns QTc in sec

### Other calculator variables and functions
You can get other information from the calculator instance, for example:

	let qtcCalculator = QTc.qtcCalculator(formula: .qtcBzt)
    let longName = qtcCalculator.longName // "Bazett"
    let shorName = qtcCalculator.shortName // "QTcBZT"
	let reference = qtcCalculator.reference // literature reference in AMA style
	let notes = qtcCalculator.notes // facts about this formula
	let classification = qtcCalculator.classification // .power
	// this is the type of mathematical equation: .power, .linear, .exponential, etc.
	let date = qtcCalculator.publicationDate // year of publication
	let numberOfSubjects = qtcCalculator.numberOfSubjects // number of subjects studied

## Normal values
Just as there are many formulas to correct or predict QT intervals, there are numerous proposals aimed at defining normal QTc intervals.  The QTc library contains a number of these abnormal QTc definitions, along with supporting literature references.

The enum `Criterion` in *AbnormalQTc.swift* lists previously defined QTc criteria.

	public enum Criterion: String {
		case schwartz1985
		case schwartz1993
		case fda2005
		case esc2005
		// etc.

Retrieve a test suite from `AbnormalQTc` and use it to test if a QTc is normal or not.

	// returns a QTcTestSuite? struct
	if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .schwartz1985)
		let m = QTcMeasurement(qtc: 455, units: .msec, .sex: .male)
		let severity = testSuite.severity(measurement: m) // == .abnormal
	}

Notice the struct `QTcMeasurement` which is used to pass the QTc along with other parameters, including units, sex, and age (the latter two are optional parameters).  The results are given as one of the constants of the struct `Severity`.  These constants are `.undefined`, `.normal`, `.borderline`, `.abnormal`, `.mild`, `.moderate`, `.severe`, and `.error.`  The method `Severity.isAbnormal() -> Bool` returns true if a result is `.abnormal`, `.mild`, `.moderate`, `.severe`, or `.error.`  The three constants `.mild`, `.moderate`, and `.severe` are used in the FDA criterion (`.fda2005`) for prolonged QTc.  See the source code in *AbnormalQTc.swift* for more information.

## Errors
### Mathematical errors
Some QTc formulas have the potential for division by zero or performing fractional power operations on negative numbers.  Parameters are not checked for these problematic inputs.  Division by zero (generally if the RR interval is zero) will result in the value `Double.infinity`, and zero divided by itself (generally if the QT and RR are both zero) or a fractional root of a negative number (if the RR is negative) will result in `Double.nan`.  Thus if input parameters are not checked for sanity, it is necessary to check results as follows:

	let qtc = QTc.qtcCalculator(formula: .qtcBzt).calculate(qtInMsec: qt, rrInMsec: rr)
	if qtc == Double.infinity || qtc.isNaN {
		Error("Division by zero or root of negative number!")
		return
	} else {
		// carry on
	}

Of course your other option is never to send these bad parameters to the formulas:

	if qt <= 0 || rr <= 0 {
		Error("QT and RR can't be less than or equal to zero!")
		return
	} else {
		let qtc = QTc.qtcCalculator(formula: .qtcBzt).calculate(qtInMsec: qt, rrInMsec: rr)
	}

### Exceptions
Calculate methods of calculators can throw exceptions in certain situations.  For example, if you have a qt of nil in your `QtMeasurement` struct and pass this to a calculate method of a QTc calculator, a `CalculationError.qtMissing` exception will be thrown.  Similarly if a calculator from a formula requires that a sex parameter is provided and it isn't, a `CalculationError.sexRequired` exception will be thrown.  See the `CalculationError` enum in *QTc.swift* for a complete list of possible exceptions.  Make sure you code includes exception handling for the calculate functions.  For example,

	guard let qtc = try? calculator.calculate(qtInMsec: qt, rrInMsec: rr) else {
		assertionFailure("Calculate threw an exception.")
	}
	print(String(format: "QTc = %.f", qtc))

## Conversion functions
The QTc library includes static functions to do common conversions, between seconds, milliseconds and heart rate, e.g.:

	let intervalInSec = 0.890
	let intervalInMsec = QTc.secToMsec(intervalInSec) // = 890
	let rate = QTc.msecToBpm(intervalInMsec) // = 67.41573

These functions don't throw, but as with the calculate functions, division by zero will result in Double.infinity.

## Tests
The QTc library includes numerous unit tests to confirm accuracy.

## Contributing
If you know of QTc or QTp formulas which are omitted here and should be included, please email me at [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com) or contact me on Twitter (@manndmd).

## Demo program
[**EP QTc**](https://github.com/mannd/EP-QTc) is a demo program that is available for download on the [Apple App Store](https://itunes.apple.com/us/app/ep-qtc/id1393849228?platform=ipad&preserveScrollPosition=true&platform=ipad#platform/ipad&platform=ipad).  With it, you can calculate all the QTc and QTp formulas at once, see graphs of intervals, determine statistics on the formulas, investigate each formula individually, and just generally have a bunch of good clean EP QT fun.

## References
See the file *Formulas.swift* for an updated list of references.

## License
This MiniQTc library is open source, and licensed under the 
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).  When used with Apple devices via the iTunes App Store, it is subject to the [standard Apple iOS license agreement](http://images.apple.com/legal/sla/docs/AppleStoreApp.pdf).

## Copyright
Copyright © 2017-2022 [EP Studios, Inc.](http://www.epstudiossoftware.com)

## Acknowledgments
Thanks to Marian Stiehler for help in acquiring the original literature that forms the basis of these QTc and QTp formulas.

Thanks to Dr. Simon Rabkin at the University of British Columbia for corresponding with me regarding the QT interval, and for his and his team's fine work on the [nomenclature and categorization](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4478566/) of the numerous QT formulas which formed a basis and inspiration for this app.  I also thank the multitude of investigators who over the years have attacked the problematic QT interval, using math in an attempt to flatten nature's heart rate versus repolarization curve.

The universal library template was created based on this helpful [Medium post](https://medium.com/@ataibarkai/create-a-universal-swift-library-for-ios-os-x-watchos-and-tvos-2aa26a8190dc) by Atai Barkai.

## Author
David Mann, MD

Email: [mannd@epstudiossoftware.com](mailto:mannd@epstudiossoftware.com) 
Website: [https://www.epstudiossoftware.com](https://www.epstudiossoftware.com) 


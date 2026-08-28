import 'package:get/get.dart';

class DiamondEducationController extends GetxController {
  // Hero Section Data
  final String heroTitle = 'understandingYourDiamond'.tr;
  final String heroDescription = 'diamondEducationHeroDescription'.tr;

  // Lab Grown Section Data
  final String labGrownTitle = 'labGrownDiamonds'.tr;
  final String labGrownDescription = 'labGrownDescription'.tr;
  final String labGrownImage = "assets/shapes/Diamonf.webp";

  // Lab Grown Methods
  final String methodsTitle = 'Two primary methods are used to create lab-grown diamonds:';
  final String hphtTitle = 'High Pressure High Temperature (HPHT)';
  final String hphtDescription = "When the natural diamond seed is placed into the HPHT reactor, a high temperature and pressure are applied to generate a diamond. The diamond is then cut and polished.";
  final String cvdTitle = 'Chemical Vapor Deposition (CVD)';
  final String cvdDescription = 'A diamond seed is placed in a vacuum chamber filled with carbon-rich gas. The gas is heated and carbon atoms are deposited onto the seed, building up layer by layer to form a diamond crystal.';
  final String labGrownResult = 'The result is a diamond that is chemically, physically, and optically identical to a mined diamond. Even expert gemologists cannot distinguish between them without specialized equipment.';

  // Natural Diamond Section Data
  final String naturalTitle = 'naturalDiamonds'.tr;
  final String naturalDescription = 'naturalDescription'.tr;
  final String naturalImage = "assets/web/showcase/real2.jpg";

  // Natural Diamond Details
  final String formationTitle = 'Formation Process:';
  final String formationDescription = 'At depths of 100-150 miles below the Earth\'s surface, carbon atoms crystallize at temperatures of 2,000°F and pressures of 725,000 pounds per square inch.';
  final String journeyTitle = 'Journey to Surface:';
  final String journeyDescription = 'These diamonds are brought to the Earth\'s surface through volcanic eruptions in a type of rock called kimberlite, where they can be mined.';
  final String naturalUniqueness = 'Each natural diamond is unique, with its own characteristics and "fingerprint" of its formation formed over billions of years. This rarity and natural origin contribute to their enduring value and emotional significance.';
  final String naturalLegacy = 'Natural diamonds have been symbols of love, commitment, and status for centuries, making them cherished heirlooms passed down through generations.';

  // Natural Diamond Features
  final List<Map<String, String>> naturalFeatures = const [
    {
      'title': 'Rare & Precious',
      'description': 'Formed over billions of years deep within the Earth, each natural diamond is a unique geological wonder.',
      'icon': 'assets/web/education/rare-precise.png',
    },
    {
      'title': 'Timeless Legacy',
      'description': 'Natural diamonds have been treasured for centuries and often become cherished family heirlooms passed down through generations.',
      'icon': 'assets/web/education/timeless-legacy.png',
    },
    {
      'title': 'Investment Value',
      'description': 'Natural diamonds, especially rare colors and large sizes, have historically held and appreciated in value over time.',
      'icon': 'assets/web/education/investment-value.png',
    },
    {
      'title': 'Certified Authenticity',
      'description': 'Each natural diamond is graded and certified by world-renowned gemological laboratories ensuring quality and authenticity.',
      'icon': 'assets/web/education/certified-grey.png',
    },
  ];

  // Lab Grown Features
  final List<Map<String, String>> labFeatures = const [
    {
      'title': 'Identical Brilliance',
      'description': 'Lab-grown diamonds possess the same chemical, physical, and optical properties as mined diamonds. Indistinguishable to the naked eye.',
      'icon': 'assets/web/home-icon/briliance.png',
    },
    {
      'title': 'Environmentally Conscious',
      'description': 'Significantly reduced environmental impact compared to traditional mining. A sustainable choice for the eco-conscious buyer.',
      'icon': 'assets/web/home-icon/environment.png',
    },
    {
      'title': 'Ethically Sourced',
      'description': 'Complete traceability and transparency. No concerns about conflict diamonds or unethical mining practices.',
      'icon': 'assets/web/home-icon/ethical.png',
    },
    {
      'title': 'Exceptional Value',
      'description': 'Typically 40-60% less expensive than comparable natural diamonds, allowing you to maximize size and quality.',
      'icon': 'assets/web/education/coin.png',
    },
  ];

  // Comparison Data
  final List<Map<String, String>> comparisonData = const [
    {'property': 'Chemical Composition', 'natural': 'Pure Carbon (C)', 'labGrown': 'Pure Carbon (C)'},
    {'property': 'Crystal Structure', 'natural': 'Cubic Crystal System', 'labGrown': 'Cubic Crystal System'},
    {'property': 'Hardness (Mohs Scale)', 'natural': '10 (Hardest)', 'labGrown': '10 (Hardest)'},
    {'property': 'Refractive Index', 'natural': '2.417 - 2.419', 'labGrown': '2.417 - 2.419'},
    {'property': 'Origin', 'natural': 'Earth (1-3 billion years)', 'labGrown': 'Laboratory (2-6 weeks)'},
    {'property': 'Environmental Impact', 'natural': 'Higher Mining', 'labGrown': 'Lower Controlled'},
    {'property': 'Price Point', 'natural': 'Premium', 'labGrown': '40-60% Less'},
    {'property': 'Resale Value', 'natural': 'Generally Higher', 'labGrown': 'Developing Market'},
    {'property': 'Certification', 'natural': 'GIA, IGI, HRD, etc.', 'labGrown': 'GIA, IGI, SGL, etc.'},
  ];

  // 4Cs Data
  final List<Map<String, String>> fourCsData = const [
    {
      'title': 'Cut',
      'description': "The most important factor affecting a diamond's brilliance. Refers to how well the diamond's facets interact with light. Grades range from Excellent to Poor."
    },
    {
      'title': 'Color',
      'description': 'Measures the absence of color in a diamond. The scale runs from D (colorless) to Z (light yellow or brown). D–F grades are considered colorless and most valuable.'
    },
    {
      'title': 'Clarity',
      'description': 'Evaluates the presence of internal inclusions and external blemishes. Grades range from IF (Internally Flawless) to I3 (Included). Most inclusions are invisible to the naked eye.'
    },
    {
      'title': 'Carat',
      'description': "Measures the diamond's weight, not size. One carat equals 0.2 grams. Larger diamonds are rarer and more valuable, but cut quality affects how large a diamond appears."
    },
  ];

  // Certification Data
  final List<Map<String, String>> certificationData = const [
    {
      'title': 'GIA',
      'description': "Gemological Institute of America – The world's most trusted authority in diamond grading"
    },
    {
      'title': 'IGI',
      'description': "International Gemological Institute – Leading laboratory for both natural and lab-grown diamonds"
    },
    {
      'title': 'KDT',
      'description': "KDT Diamond certification – Our in-house quality assurance for exceptional standards"
    },
  ];

  // Section Titles
  final String comparisonTitle = 'sideBySideComparison'.tr;
  final String comparisonDescription = 'comparisonDescription'.tr;
  final String fourCsTitle = 'understandingThe4Cs'.tr;
  final String fourCsDescription = 'fourCsDescription'.tr;
  final String certifiedTitle = 'certifiedExcellence'.tr;
  final String certifiedDescription = "Every diamond at KDT comes with certification from leading gemological institutes. These independent laboratories evaluate and document each diamond's characteristics using the highest standards in the industry.";
}
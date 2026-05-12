enum HouseCountType {
  one,
  two,
  threePlus,
}

class AcquisitionTaxInput {
  final int price;
  final HouseCountType houseCount;
  final bool regulatedArea;

  const AcquisitionTaxInput({
    required this.price,
    required this.houseCount,
    required this.regulatedArea,
  });
}

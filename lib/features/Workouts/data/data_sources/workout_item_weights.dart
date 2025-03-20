enum FreeWeights {
  w2_5(2.5),
  w5(5.0),
  w7_5(7.5),
  w10(10.0),
  w12_5(12.5),
  w15(15.0),
  w17_5(17.5),
  w20(20.0),
  w22_5(22.5),
  w25(25.0),
  w27_5(27.5),
  w30(30.0),
  w32_5(32.5),
  w35(35.0),
  w37_5(37.5),
  w40(40.0),
  w42_5(42.5),
  w45(45.0),
  w47_5(47.5),
  w50(50.0);

  final double weight;

  const FreeWeights(this.weight);

  @override
  String toString() => '$weight kg';
}

enum MachineWeights {
  w1(1),
  w2(2),
  w3(3),
  w4(4),
  w5(5),
  w6(6),
  w7(7),
  w8(8),
  w9(9),
  w10(10),
  w11(11),
  w12(12),
  w13(13),
  w14(14),
  w15(15),
  w16(16),
  w17(17),
  w18(18),
  w19(19),
  w20(20);

  final int weight;

  const MachineWeights(this.weight);

  @override
  String toString() => '$weight bar';
}

sealed class PinState {
  const PinState();
}

class PinDisabled extends PinState {
  const PinDisabled();
}

class PinEnabled extends PinState {
  final bool isUnlocked;

  const PinEnabled({this.isUnlocked = false});

  PinEnabled copyWith({bool? isUnlocked}) =>
      PinEnabled(isUnlocked: isUnlocked ?? this.isUnlocked);
}

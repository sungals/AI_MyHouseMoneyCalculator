sealed class PinState {
  const PinState();
}

class PinDisabled extends PinState {
  const PinDisabled();
}

class PinEnabled extends PinState {
  final bool isUnlocked;
  final bool requireAuthOnLaunch;

  const PinEnabled({
    this.isUnlocked = false,
    this.requireAuthOnLaunch = true,
  });

  PinEnabled copyWith({
    bool? isUnlocked,
    bool? requireAuthOnLaunch,
  }) =>
      PinEnabled(
        isUnlocked: isUnlocked ?? this.isUnlocked,
        requireAuthOnLaunch: requireAuthOnLaunch ?? this.requireAuthOnLaunch,
      );
}

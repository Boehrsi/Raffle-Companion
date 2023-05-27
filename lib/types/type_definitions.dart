typedef OnWinnerSubmit = void Function(String mail, String game, String key);

typedef OnPlatformChange = void Function([String? name]);
typedef OnPlatformDelete = void Function(String name);

typedef OnMailPresetChange = void Function([String? name, String? text]);
typedef OnMailPresetDelete = void Function(String name);

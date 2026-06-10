class Validators {
  static final _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
  static final _passwordRegExp = RegExp(r'^(?=.*\d)(?=.*[^\w\s]).{8,}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите email';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Некорректный email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Минимум 8 символов, 1 цифра и 1 спецсимвол';
    }
    return null;
  }
}

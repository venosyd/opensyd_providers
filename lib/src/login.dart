///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.login;

import 'dart:async';
import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import 'util/_module_.dart';

///
/// provedor de autenticacao
///
class LoginProvider {
  ///
  LoginProvider(
    this._host,
    this._db,
    this.logindb,
  ) : _http = HttpProvider(
          host: _host,
          api: _LoginAPI.api,
        );

  ///
  factory LoginProvider.build(
    bool devmode,
    Database database,
    String logindb, {
    bool securedev = false,
  }) =>
      LoginProvider(
        loginHost(devmode, securedev),
        database,
        logindb,
      );

  ///
  static const String SECRET_SAUCE =
      'c394637108ae3fb38e5c2acc8dd673521906f7942518a21658e3a0243d94475d';

  ///
  final String _host;

  ///
  final HttpProvider _http;

  ///
  final Database _db;

  ///
  final String logindb;

  ///
  String _token;

  ///
  String _email;

  ///
  String _phone;

  ///
  set token(dynamic token) {
    _token = token as String;
    _db.save('$_host-tk', _token);
  }

  ///
  set email(dynamic email) {
    _email = email as String;
    _db.save('$_host-em', _email);
  }

  ///
  set phone(dynamic phone) {
    _phone = phone as String;
    _db.save('$_host-ph', _phone);
  }

  ///
  Future<String> get token async {
    _token ??= await _db.retrieve('$_host-tk');
    return _token;
  }

  ///
  Future<String> get email async {
    _email ??= await _db.retrieve('$_host-em');
    return _email;
  }

  ///
  Future<String> get phone async {
    _phone ??= await _db.retrieve('$_host-ph');
    return _phone;
  }

  ///
  Future<bool> get islogged async =>
      ((await token) != null && (await token).isNotEmpty) &&
      (await token) != SECRET_SAUCE;

  ///
  Future<bool> get isnotlogged async => !(await islogged);

  ///
  Map<String, List<String>> _roles = {};

  ///
  Map<String, List<String>> get roles => _roles;

  ///
  bool _temporarytoken = false;

  ///
  ///
  ///
  Future<bool> verifyToken() async {
    if (!_temporarytoken) {
      final response = await _http.post([
        'LOGIN_BASE_URI',
        'LOGIN_$_host-tk',
      ], <String, dynamic>{
        'hash': '${await token}$logindb',
      });

      _temporarytoken = response['status'] == 'ok';

      Future.delayed(const Duration(minutes: 5), () => _temporarytoken = false);
    }

    return _temporarytoken;
  }

  ///
  Future<bool> check(String credential) async {
    final field = ValidateText.validateEmail(credential) ? 'email' : 'phone';

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_CHECK',
    ], <String, dynamic>{
      field: credential,
      'hash': logindb,
    });

    return response['meta'] == 'user-registered';
  }

  ///
  /// registra novo usuario
  ///
  Future<String> signup(String credential, String hashedpasswd) async {
    final field = ValidateText.validateEmail(credential) ? 'email' : 'phone';

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_SIGNUP',
    ], <String, dynamic>{
      field: credential,
      'hash': '$hashedpasswd$logindb',
    });

    if (response['status'] == 'ok') {
      token = response['authcode']; // save token
      email = ValidateText.validateEmail(credential) ? credential : '';
      phone = ValidateSpecialChar.validatePhone(credential) ? credential : '';

      verifyRoles(credential); // cacheia as roles

      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// registra novo usuario
  ///
  Future<String> oauthsignup(String email, String oAuthToken) async {
    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_OAUTH_SIGNUP',
    ], <String, dynamic>{
      'email': email,
      'hash': '$logindb$oAuthToken',
    });

    if (response['status'] == 'ok') {
      token = response['authcode']; // save token
      this.email = email;

      verifyRoles(email); // cacheia as roles

      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// registra novo usuario
  ///
  // ignore: non_constant_identifier_names
  Future<String> signup_user(String credential, String hashedpasswd) async {
    final field = ValidateText.validateEmail(credential) ? 'email' : 'phone';

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_SIGNUP',
    ], <String, dynamic>{
      field: credential,
      'hash': '$hashedpasswd$logindb',
    });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  /// loga usuario
  ///
  Future<String> login(String credential, String hashedpasswd) async {
    final field = ValidateText.validateEmail(credential) ? 'email' : 'phone';

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_LOGIN',
    ], <String, dynamic>{
      field: credential,
      'hash': '$hashedpasswd$logindb',
    });

    if (response['status'] == 'ok' && response['meta'] != 'no-user-yet') {
      token = response['authcode']; // save token
      email = ValidateText.validateEmail(credential) ? credential : '';
      phone = ValidateSpecialChar.validatePhone(credential) ? credential : '';

      verifyRoles(credential); // cacheia as roles

      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// loga usuario
  ///
  Future<String> oauthlogin(String email, String oAuthToken) async {
    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_OAUTH_LOGIN',
    ], <String, dynamic>{
      'email': email,
      'hash': '$logindb$oAuthToken',
    });

    if (response['status'] == 'ok' && response['meta'] != 'no-user-yet') {
      token = response['authcode']; // save token
      this.email = email;

      verifyRoles(email); // cacheia as roles

      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// desloga usuario
  ///
  Future<String> logout() async {
    _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_LOGOUT',
    ], <String, dynamic>{
      'hash': '${await token}$logindb',
    });
    _clear();

    return Responses.SUCCESS;
  }

  ///
  /// enable user
  ///
  Future<bool> isEnabled(String credential) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_IS_ENABLED',
    ], payload);

    return response['status'] == 'ok' && response['message'] == 'user-enabled';
  }

  ///
  /// enable user
  ///
  Future<String> enable(String credential) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_ENABLE',
    ], payload);

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  /// disable user
  ///
  Future<String> disable(String credential) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_DISABLE',
    ], payload);

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  /// retorna a ID unica deste usuario
  ///
  Future<String> uniqueID(String credential) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_UNIQUE_ID',
    ], payload);

    return response['status'] == 'ok'
        ? response['payload'] as String
        : Responses.FAILURE;
  }

  ///
  /// logout user of all sections
  ///
  Future<String> quitall(String credential) async {
    _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_QUIT_ALL',
    ], <String, dynamic>{
      'credential': credential,
      'hash': logindb,
    });

    if (credential == (await email) || credential == (await phone)) {
      _clear();
    }

    return Responses.SUCCESS;
  }

  ///
  /// logout user of all sections
  ///
  Future<String> resetPasswd(String credential) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_PASSW_RESET',
    ], payload);

    if (response['status'] == 'ok') {
      _clear();
      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// logout user of all sections
  ///
  Future<String> changeOldPasswd(
    String credential,
    String oldpasswd,
    String newpasswd,
  ) async {
    final payload = {
      'hash': '${await token}$oldpasswd$newpasswd$logindb',
      'credential': credential,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_CHANGE_OLD',
    ], payload);

    if (response['status'] == 'ok') {
      if (credential == (await email) || credential == (await phone)) {
        _clear();
      }

      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// usuario pede mudanca de senha
  ///
  Future<String> requireChange(
    String email,
    String title, [
    String service = 'Venosyd',
  ]) async {
    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_REQUIRE_PASSW_CHANGE',
    ], <String, dynamic>{
      'email': email,
      'service': service,
      'hash': logindb,
      'title': title ?? 'Recuperação de SENHA',
    });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  /// com hash na mao, muda senha
  ///
  Future<String> changePasswd({String newpasswd, String hash}) async {
    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_PASSW_CHANGE',
    ], <String, dynamic>{
      'hash': '$hash$newpasswd$logindb',
    });

    return response['status'] == 'ok' ? Responses.SUCCESS : Responses.FAILURE;
  }

  ///
  /// ask for info about user role
  ///
  Future<String> verifyRole(String role, [String email]) async =>
      (await verifyRoles(email ?? (await this.email))).contains(role)
          ? 'HAS IT'
          : 'DOESN\'T HAVE';

  ///
  /// ask for info about user role
  ///
  Future<List<String>> verifyRoles(
    String credential, [
    bool singleuser = false,
  ]) async {
    try {
      final cred = singleuser ? 'user' : credential;
      if (_roles[cred] != null) {
        return _roles[cred];
      }

      final payload = {
        'hash': '${await token}$logindb',
        'credential': credential,
      };

      final response = await _http.post([
        'LOGIN_BASE_URI',
        'LOGIN_ROLES',
      ], payload);

      if (response['status'] == 'ok') {
        final roles = json.decode(response['payload'] as String).cast<String>()
            as List<String>;

        _roles[cred] = roles;
        return roles;
      }
    } catch (exception, _) {
      print(exception);
    }

    return [];
  }

  ///
  /// give a user a role
  ///
  Future<String> giveRole(String credential, String role) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
      'role': role,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_ROLE_GIVE',
    ], payload);

    if (response['status'] == 'ok') {
      _roles[credential] = null; // invalida o cache forcando um update
      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// remove a user a role
  ///
  Future<String> removeRole(String credential, String role) async {
    final payload = {
      'hash': '${await token}$logindb',
      'credential': credential,
      'role': role,
    };

    final response = await _http.post([
      'LOGIN_BASE_URI',
      'LOGIN_ROLE_REMOVE',
    ], payload);

    if (response['status'] == 'ok') {
      _roles[credential] = null; // invalida o cache forcando um update
      return Responses.SUCCESS;
    }

    return Responses.FAILURE;
  }

  ///
  /// limpa TUTO
  ///
  void _clear() {
    _db.clear();
    _roles = {};
    _token = null;
    _email = null;
    _phone = null;
  }
}

///
abstract class _LoginAPI {
  static final Map<String, String> api = {
    'LOGIN_BASE_URI': '/login',
    'LOGIN_ECHO': '/echo',
    'LOGIN_CHECK': '/check',
    'LOGIN_SIGNUP': '/signup',
    'LOGIN_OAUTH_SIGNUP': '/oauth/signup',
    'LOGIN_LOGIN': '/login',
    'LOGIN_OAUTH_LOGIN': '/oauth/login',
    'LOGIN_LOGOUT': '/logout',
    'LOGIN_IS_ENABLED': '/is/enabled',
    'LOGIN_ENABLE': '/enable',
    'LOGIN_DISABLE': '/disable',
    'LOGIN_QUIT_ALL': '/quitall',
    'LOGIN_TOKEN': '/token',
    'LOGIN_UNIQUE_ID': '/unique',
    'LOGIN_ROLE': '/role',
    'LOGIN_ROLES': '/roles',
    'LOGIN_ROLE_GIVE': '/role/give',
    'LOGIN_ROLE_REMOVE': '/role/remove',
    'LOGIN_USERS_BY_ROLE': '/usersbyrole',
    'LOGIN_REQUIRE_PASSW_CHANGE': '/requirechange',
    'LOGIN_PASSW_CHANGE': '/change',
    'LOGIN_PASSW_RESET': '/reset',
    'LOGIN_CHANGE_OLD': '/change/old',
  };
}

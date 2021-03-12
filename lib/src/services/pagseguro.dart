///
/// venosyd © 2016-2021. sergio lisan <sels@venosyd.com>
///
library opensyd.dart.providers.exoservices.pagseguro;

import 'dart:convert';

import 'package:opensyd_dart/opensyd_dart.dart';

import '../login.dart';
import '../util/_module_.dart';

///
/// Cliente para o pagseguro-java-backend
///
class PagSeguroProvider {
  ///
  PagSeguroProvider(
    String host,
    this.login,
  ) : httpprovider = HttpProvider(
          host: host,
          api: {
            'PAGSEGURO_BASE_URL': '/pagseguro',
            'PAGSEGURO_TOKEN': '/token',
            'PAGSEGURO_CREDENTIAL': '/credential',
            'PAGSEGURO_SESSION': '/session',
            'PAGSEGURO_CC_BRAND': '/ccbrand',
            'PAGSEGURO_CC_TOKEN': '/cctoken',
            'PAGSEGURO_CC_PARCELAS': '/get-parcelas',
            'PAGSEGURO_CHECKOUT_DO': '/do-checkout',
            'PAGSEGURO_CHECKOUT_SEE': '/see-checkout',
            'PAGSEGURO_PLAN_CREATE': '/create-plan',
            'PAGSEGURO_SUBSCRIPTION_DO': '/do-subscription',
            'PAGSEGURO_SUBSCRIPTION_SEE': '/see-subscription',
            'PAGSEGURO_SUBSCRIPTION_CANCEL': '/cancel-subscription',
          },
        );

  ///
  final HttpProvider httpprovider;

  ///
  final LoginProvider login;

  ///{String conta}
  Future<String> token({String conta}) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_TOKEN',
    ], <String, dynamic>{
      'conta': conta,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return (response['status'] == 'ok'
        ? response['payload']
        : Responses.FAILURE) as String;
  }

  ///
  Future<String> credential({String conta}) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CREDENTIAL',
    ], <String, dynamic>{
      'conta': conta,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return (response['status'] == 'ok'
        ? response['payload']
        : Responses.FAILURE) as String;
  }

  ///
  Future<String> createSession({String conta}) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_SESSION',
    ], <String, dynamic>{
      'conta': conta,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return (response['status'] == 'ok'
        ? response['payload']
        : Responses.FAILURE) as String;
  }

  ///
  Future<Map<String, dynamic>> createPlan(
    String planoNome,
    String planoSigla,
    String planoURLCancelamento,
    String planoPreco, {
    String conta,
    String periodoGratuito = '1', // em dias
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_PLAN_CREATE',
    ], <String, dynamic>{
      'conta': conta,
      'planoNome': planoNome,
      'planoSigla': planoSigla,
      'planoURLCancelamento': planoURLCancelamento,
      'planoPreco': planoPreco,
      'trialPeriod': periodoGratuito,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<String> getCCBrand(
    String sessionID,
    String ccBin, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CC_BRAND',
    ], <String, dynamic>{
      'conta': conta,
      'sessionID': sessionID,
      'ccBin': ccBin,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return (response['status'] == 'ok'
        ? response['payload']
        : Responses.FAILURE) as String;
  }

  ///
  Future<Map<String, dynamic>> getParcelas(
    String sessionID,
    String amount,
    String ccBrand, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CC_PARCELAS',
    ], <String, dynamic>{
      'conta': conta,
      'sessionID': sessionID,
      'amount': amount,
      'ccBrand': ccBrand,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<String> getCCToken(
    String sessionID,
    String amount,
    String ccNumero,
    String ccCVV,
    String ccMesExpiracao,
    String ccAnoExpiracao, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CC_TOKEN',
    ], <String, dynamic>{
      'conta': conta,
      'sessionID': sessionID,
      'amount': amount,
      'ccNumero': ccNumero,
      'ccCVV': ccCVV,
      'ccMesExpiracao': ccMesExpiracao,
      'ccAnoExpiracao': ccAnoExpiracao,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return (response['status'] == 'ok'
        ? response['payload']
        : Responses.FAILURE) as String;
  }

  ///
  Future<Map<String, dynamic>> doCheckout(
    String sessionID,
    String itemDescricao,
    String itemSigla,
    String clienteNome,
    String clienteCPF,
    String clienteDDD,
    String clientePhone,
    String clienteEmail,
    String clienteHash,
    String amount,
    String ccNumero,
    String ccCVV,
    String ccMesExpiracao,
    String ccAnoExpiracao,
    String ccDiaNascimento,
    String parcelas, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CHECKOUT_DO',
    ], <String, dynamic>{
      'conta': conta,
      'sessionID': sessionID,
      'itemDescricao': itemDescricao,
      'itemSigla': itemSigla,
      'clienteNome': clienteNome,
      'clienteCPF': clienteCPF,
      'clienteDDD': clienteDDD,
      'clientePhone': clientePhone,
      'clienteEmail': clienteEmail,
      'clienteHash': clienteHash,
      'amount': amount,
      'ccNumero': ccNumero,
      'ccCVV': ccCVV,
      'ccMesExpiracao': ccMesExpiracao,
      'ccAnoExpiracao': ccAnoExpiracao,
      'ccDiaNascimento': ccDiaNascimento,
      'parcelas': parcelas,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<Map<String, dynamic>> seeCheckout(
    String checkoutCode, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_CHECKOUT_SEE',
    ], <String, dynamic>{
      'conta': conta,
      'checkoutCode': checkoutCode,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<Map<String, dynamic>> doSubcription(
    String sessionID,
    String planID,
    String planSigla,
    String planPreco,
    String clienteNome,
    String clienteCPF,
    String clienteDDD,
    String clientePhone,
    String clienteEmail,
    String clienteHash,
    String enderecoRua,
    String enderecoNumero,
    String enderecoDistrito,
    String enderecoCidade,
    String enderecoEstado,
    String enderecoCEP,
    String ccNumero,
    String ccCVV,
    String ccMesExpiracao,
    String ccAnoExpiracao,
    String ccDiaNascimento, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_SUBSCRIPTION_DO',
    ], <String, dynamic>{
      'conta': conta,
      'sessionID': sessionID,
      'planoID': planID,
      'planoSigla': planSigla,
      'planoPreco': planPreco,
      'clienteNome': clienteNome,
      'clienteCPF': clienteCPF,
      'clienteDDD': clienteDDD,
      'clientePhone': clientePhone,
      'clienteEmail': clienteEmail,
      'clienteHash': clienteHash,
      'enderecoRua': enderecoRua,
      'enderecoNumero': enderecoNumero,
      'enderecoDistrito': enderecoDistrito,
      'enderecoCidade': enderecoCidade,
      'enderecoEstado': enderecoEstado,
      'enderecoCEP': enderecoCEP,
      'ccNumero': ccNumero,
      'ccCVV': ccCVV,
      'ccMesExpiracao': ccMesExpiracao,
      'ccAnoExpiracao': ccAnoExpiracao,
      'ccDiaNascimento': ccDiaNascimento,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<Map<String, dynamic>> seeSubscription(
    String subscriptionCode, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_SUBSCRIPTION_SEE',
    ], <String, dynamic>{
      'conta': conta,
      'subscriptionCode': subscriptionCode,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }

  ///
  Future<Map<String, dynamic>> cancelSubscription(
    String subscriptionID, {
    String conta,
  }) async {
    final response = await httpprovider.post([
      'PAGSEGURO_BASE_URL',
      'PAGSEGURO_SUBSCRIPTION_CANCEL',
    ], <String, dynamic>{
      'conta': conta,
      'subscriptionID': subscriptionID,
    }, headers: {
      'Authorization': 'Basic ${base64.encode((await login.token).codeUnits)}',
    });

    return response;
  }
}

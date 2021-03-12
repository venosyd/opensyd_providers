///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@$prodURL)
///
library opensyd.dart.providers.hosts;

String _devip;
String get devIP => _devip;
set devIP(String value) => _devip = value;

String _prodURL;
String get prodURL => _prodURL;
set prodURL(String value) => _prodURL = value;

///
String createHost({
  bool devmode = false,
  bool securedev = false,
  String servicePort,
  String devHost,
  String prodHost,
  String protocol = 'http',
}) =>
    devmode
        ? (((_devip ?? '').isNotEmpty && _devip != 'localhost')
            ? '$protocol${securedev ? 's' : ''}://$_devip:$servicePort'
            : '$protocol${securedev ? 's' : ''}://$devHost')
        : '${protocol}s://$prodHost';

///
String repositoryHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '7020',
      devHost: 'clouddata.localhost:8080',
      prodHost: 'clouddata.$prodURL',
    );

///
String loginHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '7030',
      devHost: 'login.localhost:8080',
      prodHost: 'login.$prodURL',
    );

///
String imagesHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '7040',
      devHost: 'images.localhost:8080',
      prodHost: 'images.$prodURL',
    );

///
String mailHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '7050',
      devHost: 'mail.localhost:8080',
      prodHost: 'mail.$prodURL',
    );

///
String addressHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '7060',
      devHost: 'address.localhost:8080',
      prodHost: 'address.$prodURL',
    );

/// wss-port: "8098"
String unsafeWebsocketHost(bool devmode, [bool securedev = false]) =>
    createHost(
      securedev: securedev,
      devmode: devmode,
      servicePort: '8098',
      devHost: 'localhost:8098',
      prodHost: prodURL,
      protocol: 'ws',
    );

/// ws-port: "8088"
String safeWebsocketHost(bool devmode, [bool securedev = false]) => createHost(
      devmode: devmode,
      securedev: securedev,
      servicePort: '8088',
      devHost: 'localhost:8088',
      prodHost: prodURL,
      protocol: 'ws',
    );

import 'dart:io';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:toast/toast.dart';
import 'package:validators/validators.dart';

import '../custom/loading.dart';
import '../data_model/city_response.dart';
import '../data_model/country_response.dart';
import '../data_model/state_response.dart';
import '../repositories/address_repository.dart';
import '../ui_elements/auth_ui.dart';

class AddressFieldPage extends StatefulWidget {
  final String? name;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;
  final String? registerBy;

  AddressFieldPage(
      {Key? key,
      this.name,
      this.email,
      this.password,
      this.confirmPassword,
      this.phoneNumber,
      this.registerBy})
      : super(key: key);

  @override
  _AddressFieldPageState createState() => _AddressFieldPageState();
}

class _AddressFieldPageState extends State<AddressFieldPage> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";
  bool _confirmPasswordVisible = false;
  bool _passwordVisible = false;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  //controllers

  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  onSelectCountryDuringAdd(country) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  onSelectStateDuringAdd(state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  onSelectCityDuringAdd(city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name;
    });
  }

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    print(
        "register Details======>${widget.name}-${widget.email}-${widget.password}-${widget.confirmPassword}-${widget.registerBy}");
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSignUp() async {
    Loading.show(context);

    var name = widget.name;
    var email = widget.email;
    var password = widget.password;
    var password_confirm = widget.confirmPassword;
    var address = _addressController.text.toString();
    var countries = _countryController.text.toString();
    var state = _stateController.text.toString();
    var city = _countryController.text.toString();
    var postalCode = _postalCodeController.text.toString();

    if (address == "") {
      ToastComponent.showDialog("Enter Address",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (countries == "") {
      ToastComponent.showDialog("Enter Countries",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (state == "") {
      ToastComponent.showDialog("Enter State",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (city == "") {
      ToastComponent.showDialog("Enter City",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (postalCode == "") {
      ToastComponent.showDialog("Enter Postalcode",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (postalCode.length > 6) {
      ToastComponent.showDialog("Enter only 6 digit pincode",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }else{
      print("Called");
      var signupResponse = await AuthRepository().getSignupResponse(
        name!,
        _register_by == 'email' ? email : _phone,
        password!,
        password_confirm!,
        _register_by,
        googleRecaptchaKey,
        address,
        _selected_city!.id!,
        _selected_state!.id!,
        _selected_country!.id!,
        postalCode,
        widget.phoneNumber!,
      );
      Loading.close();

      if (signupResponse.result == false) {
        var message = "";
        signupResponse.message.forEach((value) {
          message += value + "\n";
        });

        ToastComponent.showDialog(message, gravity: Toast.center, duration: 3);
      } else {
        ToastComponent.showDialog(signupResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(signupResponse);

        // redirect to main
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return Main();
            }), (newRoute) => false);

        // // push notification starts
        // if (OtherConfig.USE_PUSH_NOTIFICATION) {
        //   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
        //   await _fcm.requestPermission(
        //     alert: true,
        //     announcement: false,
        //     badge: true,
        //     carPlay: false,
        //     criticalAlert: false,
        //     provisional: false,
        //     sound: true,
        //   );
        //
        //   String? fcmToken = await _fcm.getToken();
        //
        //   if (fcmToken != null) {
        //     print("--fcm token--");
        //     print(fcmToken);
        //     if (is_logged_in.$ == true) {
        //       // update device token
        //       var deviceTokenUpdateResponse = await ProfileRepository()
        //           .getDeviceTokenUpdateResponse(fcmToken);
        //     }
        //   }
        // }
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    // return buildBody(context, _screen_width);
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      children: [
        // Stack(
        //   children: [
        //     Container(
        //       height: 290,
        //       width: _screen_width,
        //       child: Image.asset("assets/auth_background.png"),
        //     ),
        //     Positioned(
        //       child: Align(
        //         alignment: Alignment.topLeft,
        //         child: IconButton(
        //           onPressed: () {},
        //           icon: Icon(Icons.arrow_back_ios),
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //       top: 20,
        //       left: 95,
        //       child: Image.asset(
        //         "assets/location_image.png",
        //         height: 160,
        //         width: 210,
        //       ),
        //     )
        //   ],
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Select Your Location",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: SizedBox(
                width: 284,
                height: 39,
                child: Text(
                  "Switch on your location to stay in tune with what’s happening in your area",
                  style:
                      TextStyle(fontSize: 13, color: MyTheme.textfield_grey),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              // width: _screen_width * (3 / 4),
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                        "${AppLocalizations.of(context)!.address_ucf}",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      height: 60,
                      child: TextField(
                        controller: _addressController,
                        autofocus: false,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: "Enter Address"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                        "${AppLocalizations.of(context)!.country_ucf}",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      height: 40,
                      // width: 170,
                      child: TypeAheadField(
                        suggestionsCallback: (name) async {
                          var countryResponse = await AddressRepository()
                              .getCountryList(name: name);
                          return countryResponse.countries;
                        },
                        loadingBuilder: (context) {
                          return Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .loading_countries_ucf,
                                    style: TextStyle(
                                        color: MyTheme.medium_grey))),
                          );
                        },
                        itemBuilder: (context, dynamic country) {
                          //print(suggestion.toString());
                          return ListTile(
                            dense: true,
                            title: Text(
                              country.name,
                              style: TextStyle(color: MyTheme.font_grey),
                            ),
                          );
                        },
                        noItemsFoundBuilder: (context) {
                          return Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .no_country_available,
                                    style: TextStyle(
                                        color: MyTheme.medium_grey))),
                          );
                        },
                        onSuggestionSelected: (dynamic country) {
                          onSelectCountryDuringAdd(country);
                          print("Country Data ${_countryController}");
                        },
                        textFieldConfiguration: TextFieldConfiguration(
                          onTap: () {},
                          //autofocus: true,
                          controller: _countryController,
                          onSubmitted: (txt) {
                            // keep this blank
                          },
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: AppLocalizations.of(context)!
                                  .enter_country_ucf),
                        ),
                      ),
                    ),
                  ),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text(
                         "${AppLocalizations.of(context)!.state_ucf}",
                         style: TextStyle(
                             color: MyTheme.accent_color,
                             fontSize: 12,
                             fontWeight: FontWeight.w600),
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 10.0),
                       child: Container(
                         height: 40,
                         // width: 170,
                         child: TypeAheadField(
                           suggestionsCallback: (name) async {
                             if (_selected_country == null) {
                               var stateResponse = await AddressRepository()
                                   .getStateListByCountry(); // blank response
                               return stateResponse.states;
                             }
                             var stateResponse = await AddressRepository()
                                 .getStateListByCountry(
                                 country_id: _selected_country!.id,
                                 name: name);
                             return stateResponse.states;
                           },
                           loadingBuilder: (context) {
                             return Container(
                               height: 50,
                               child: Center(
                                   child: Text(
                                       AppLocalizations.of(context)!
                                           .loading_states_ucf,
                                       style: TextStyle(
                                           color: MyTheme.medium_grey))),
                             );
                           },
                           itemBuilder: (context, dynamic state) {
                             //print(suggestion.toString());
                             return ListTile(
                               dense: true,
                               title: Text(
                                 state.name,
                                 style: TextStyle(color: MyTheme.font_grey),
                               ),
                             );
                           },
                           noItemsFoundBuilder: (context) {
                             return Container(
                               height: 50,
                               child: Center(
                                   child: Text(
                                       AppLocalizations.of(context)!
                                           .no_state_available,
                                       style: TextStyle(
                                           color: MyTheme.medium_grey))),
                             );
                           },
                           onSuggestionSelected: (dynamic state) {
                             onSelectStateDuringAdd(state);
                             print("State Data ${_stateController}");
                           },
                           textFieldConfiguration: TextFieldConfiguration(
                             onTap: () {},
                             //autofocus: true,
                             controller: _stateController,
                             onSubmitted: (txt) {
                               // _searchKey = txt;
                               // setState(() {});
                               // _onSearchSubmit();
                             },
                             decoration: InputDecorations.buildInputDecoration_1(
                                 hint_text: AppLocalizations.of(context)!
                                     .enter_state_ucf),
                           ),
                         ),
                       ),
                     ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("${AppLocalizations.of(context)!.city_ucf}",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      height: 40,
                      // width: 170,
                      child: TypeAheadField(
                        suggestionsCallback: (name) async {
                          if (_selected_state == null) {
                            var cityResponse = await AddressRepository()
                                .getCityListByState(); // blank response
                            return cityResponse.cities;
                          }
                          var cityResponse = await AddressRepository()
                              .getCityListByState(
                              state_id: _selected_state!.id, name: name);
                          return cityResponse.cities;
                        },
                        loadingBuilder: (context) {
                          return Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .loading_cities_ucf,
                                    style: TextStyle(
                                        color: MyTheme.medium_grey))),
                          );
                        },
                        itemBuilder: (context, dynamic city) {
                          //print(suggestion.toString());
                          return ListTile(
                            dense: true,
                            title: Text(
                              city.name,
                              style: TextStyle(color: MyTheme.medium_grey),
                            ),
                          );
                        },
                        noItemsFoundBuilder: (context) {
                          return Container(
                            height: 50,
                            child: Center(
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .no_city_available,
                                    style: TextStyle(
                                        color: MyTheme.medium_grey))),
                          );
                        },
                        onSuggestionSelected: (dynamic city) {
                          onSelectCityDuringAdd(city);
                          print("City Data ${_cityController}");
                        },
                        textFieldConfiguration: TextFieldConfiguration(
                          onTap: () {},
                          //autofocus: true,
                          controller: _cityController,
                          onSubmitted: (txt) {
                            // keep blank
                          },
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: AppLocalizations.of(context)!
                                  .enter_city_ucf),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(AppLocalizations.of(context)!.postal_code,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      height: 40,
                      // width: 170,
                      child: TextField(
                        controller: _postalCodeController,
                        autofocus: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: AppLocalizations.of(context)!
                                .enter_postal_code_ucf),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 15,
                          width: 15,
                          child: Checkbox(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              value: _isAgree,
                              onChanged: (newValue) {
                                _isAgree = newValue;
                                setState(() {});
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            width: DeviceInfo(context).width! - 130,
                            child: RichText(
                                maxLines: 2,
                                text: TextSpan(
                                    style: TextStyle(
                                        color: MyTheme.font_grey,
                                        fontSize: 12),
                                    children: [
                                      TextSpan(
                                        text: "I agree to the",
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommonWebviewScreen(
                                                          page_name:
                                                              "Terms Conditions",
                                                          url:
                                                              "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                        )));
                                          },
                                        style: TextStyle(
                                            color: MyTheme.accent_color),
                                        text: " Terms Conditions",
                                      ),
                                      TextSpan(
                                        text: " &",
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommonWebviewScreen(
                                                          page_name:
                                                              "Privacy Policy",
                                                          url:
                                                              "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                        )));
                                          },
                                        text: " Privacy Policy",
                                        style: TextStyle(
                                            color: MyTheme.accent_color),
                                      )
                                    ])),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Container(
                      height: 45,
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 50,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6.0))),
                        child: Text(
                          AppLocalizations.of(context)!.sign_up_ucf,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isAgree!
                            ? () {
                                onPressSignUp();
                              }
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text(
                          AppLocalizations.of(context)!
                              .already_have_an_account,
                          style: TextStyle(
                              color: MyTheme.font_grey, fontSize: 12),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          child: Text(
                            AppLocalizations.of(context)!.log_in,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Login();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

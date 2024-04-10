import 'dart:io';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/google_recaptcha.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/address_field_page.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toast/toast.dart';
import 'package:validators/validators.dart';
import '../app_config.dart';
import '../custom/loading.dart';
import '../repositories/address_repository.dart';
import '../ui_elements/auth_ui.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
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

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
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
    _nameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
    super.dispose();
  }

  onPressNextPage() async {
    // Loading.show(context);

    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_your_name,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'email' && (email == "" || !isEmail(email))) {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_email,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_password,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.confirm_your_password,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .password_must_contain_at_least_6_characters,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.passwords_do_not_match,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddressFieldPage(
          name: name,
          email: email,
          password: password,
          confirmPassword: password_confirm,
          registerBy: _register_by,
          phoneNumber: _phone,
          // verify_by: _register_by,
          // user_id: signupResponse.user_id,
        );
      }));
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
            Container(
              width: _screen_width * (3 / 4),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Signup",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 20),
                    child: Text(
                      "Enter you email and password",
                      style: TextStyle(
                          fontSize: 16,
                          color:
                          MyTheme.textfield_grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!
                          .name_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0),
                    child: Container(
                      height: 36,
                      child: TextField(
                        controller: _nameController,
                        autofocus: false,
                        decoration: InputDecorations
                            .buildInputDecoration_1(
                            hint_text: "John Doe"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0),
                    child: Text(
                      _register_by == "email"
                          ? AppLocalizations.of(
                          context)!
                          .email_ucf
                          : AppLocalizations.of(
                          context)!
                          .phone_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_register_by == "email")
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 36,
                            child: TextField(
                              controller:
                              _emailController,
                              autofocus: false,
                              decoration: InputDecorations
                                  .buildInputDecoration_1(
                                  hint_text:
                                  "johndoe@example.com"),
                            ),
                          ),
                          otp_addon_installed.$
                              ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _register_by =
                                "phone";
                              });
                            },
                            child: Text(
                              AppLocalizations.of(
                                  context)!
                                  .or_register_with_a_phone,
                              style: TextStyle(
                                  color: MyTheme
                                      .accent_color,
                                  fontStyle:
                                  FontStyle
                                      .italic,
                                  decoration:
                                  TextDecoration
                                      .underline),
                            ),
                          )
                              : Container()
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 36,
                            child:
                            CustomInternationalPhoneNumberInput(
                              countries: countries_code,
                              onInputChanged:
                                  (PhoneNumber number) {
                                print(
                                    number.phoneNumber);
                                setState(() {
                                  _phone = number
                                      .phoneNumber;
                                });
                              },
                              onInputValidated:
                                  (bool value) {
                                print(value);
                              },
                              selectorConfig:
                              SelectorConfig(
                                selectorType:
                                PhoneInputSelectorType
                                    .DIALOG,
                              ),
                              ignoreBlank: false,
                              autoValidateMode:
                              AutovalidateMode
                                  .disabled,
                              selectorTextStyle:
                              TextStyle(
                                  color: MyTheme
                                      .font_grey),
                              // initialValue: PhoneNumber(
                              //     isoCode: countries_code[0].toString()),
                              textFieldController:
                              _phoneNumberController,
                              formatInput: true,
                              keyboardType: TextInputType
                                  .numberWithOptions(
                                  signed: true,
                                  decimal: true),
                              inputDecoration: InputDecorations
                                  .buildInputDecoration_phone(
                                  hint_text:
                                  "01XXX XXX XXX"),
                              onSaved:
                                  (PhoneNumber number) {
                                //print('On Saved: $number');
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _register_by = "email";
                              });
                            },
                            child: Text(
                              AppLocalizations.of(
                                  context)!
                                  .or_register_with_an_email,
                              style: TextStyle(
                                  color: MyTheme
                                      .accent_color,
                                  fontStyle:
                                  FontStyle.italic,
                                  decoration:
                                  TextDecoration
                                      .underline),
                            ),
                          )
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!
                          .password_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 36,
                          child: TextField(
                            controller:
                            _passwordController,
                            autofocus: false,
                            obscureText:
                            !_passwordVisible,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecorations
                                .buildInputDecoration_1(
                              hint_text:
                              "• • • • • • • •",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                        () {
                                      _passwordVisible =
                                      !_passwordVisible;
                                    },
                                  );
                                },
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons
                                      .visibility_off,
                                  color: MyTheme
                                      .accent_color,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .password_must_contain_at_least_6_characters,
                          style: TextStyle(
                              color: MyTheme
                                  .textfield_grey,
                              fontStyle:
                              FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!
                          .retype_password_ucf,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8.0),
                    child: Container(
                      height: 36,
                      child: TextField(
                        controller:
                        _passwordConfirmController,
                        autofocus: false,
                        obscureText:
                        !_confirmPasswordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecorations
                            .buildInputDecoration_1(
                          hint_text: "• • • • • • • •",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                    () {
                                  _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                                },
                              );
                            },
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons
                                  .visibility_off,
                              color:
                              MyTheme.accent_color,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (google_recaptcha.$)
                    Container(
                      height:
                      _isCaptchaShowing ? 350 : 50,
                      width: 300,
                      child: Captcha(
                            (keyValue) {
                          googleRecaptchaKey = keyValue;
                          setState(() {});
                        },
                        handleCaptcha: (data) {
                          if (_isCaptchaShowing
                              .toString() !=
                              data) {
                            _isCaptchaShowing = data;
                            setState(() {});
                          }
                        },
                        isIOS: Platform.isIOS,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0),
                    child: Container(
                      height: 45,
                      child: Btn.minWidthFixHeight(
                          minWidth:
                          MediaQuery.of(context)
                              .size
                              .width,
                          height: 50,
                          color: MyTheme.accent_color,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              const BorderRadius
                                  .all(
                                  Radius.circular(
                                      6.0))),
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600),
                          ),
                          onPressed: () {
                            onPressNextPage();
                          }),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Center(
                            child: Text(
                              AppLocalizations.of(context)!
                                  .already_have_an_account,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 12),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          child: Text(
                            AppLocalizations.of(
                                context)!
                                .log_in,
                            style: TextStyle(
                                color: MyTheme
                                    .accent_color,
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600),
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) {
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

        // Stack(
        //   children: [
        //     Container(
        //       child: Image.asset(
        //         "assets/auth_background.png",
        //         height: 300,
        //         width: _screen_width,
        //       ),
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
        //   ],
        // ),
      ],
    );
  }
}

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:toast/toast.dart';
import '../../custom/lang_text.dart';
import '../../custom/loading.dart';
import '../../repositories/address_repository.dart';
import 'login.dart';

class PhoneLogin extends StatefulWidget {
  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  String otpPin = '';

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  OtpFieldController _verificationController = OtpFieldController();

  // TextEditingController _emailController = TextEditingController();
  // TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    fetch_country();
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    Loading.show(context);
    if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_phone_number,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return Main();
    }), (newRoute) => false);
  }

  sendOtp() {
    showDialog(
      barrierDismissible: true,
      useSafeArea: true,
      context: context,
      builder: (_) => AlertDialog(
        // contentPadding: EdgeInsets.only(
        //     top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            "Enter OTP to Login",
            maxLines: 3,
            style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        content: OTPTextField(
          keyboardType: TextInputType.number,
          controller: _verificationController,
          length: 6,
          textFieldAlignment: MainAxisAlignment.spaceBetween,
          fieldWidth: 40,
          fieldStyle: FieldStyle.box,
          outlineBorderRadius: 15,
          style: TextStyle(fontSize: 16),
          onChanged: (pin) {
            print("Changed: " + pin);
          },
          onCompleted: (pin) {
            print("Completed: " + pin);
            setState(() {
              otpPin = pin;
            });
          },
        ),
        actions: [
          // TextButton(
          //   child: Text(
          //     "Send OTP",
          //     style: TextStyle(color: MyTheme.cinnabar),
          //   ),
          //   onPressed: () async {
          //     // var deliveryStatusChangeResponse =
          //     // await DeliveryRepository().getDeliveryOtpResponse(
          //     //     status: "delivered",
          //     //     order_id: order_id,
          //     //     otp: otpPin);
          //   },
          // ),
          TextButton(
            child: Text(
              LangText(context).local!.close_ucf,
              style: TextStyle(color: MyTheme.medium_grey),
            ),
            onPressed: () {
              // Navigator.pop(context, true);
              Navigator.of(_).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: MyTheme.accent_color,
            ),
            child: Text(
              LangText(context).local!.confirm_ucf,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              print("otp cehvk ${_verificationController}");
              // var getLoginResponse = await AuthRepository().loginUsingOTP(
              //     phoneNumber: _phoneNumberController.text.toString(),
              //     otp: otpPin.toString());
              Navigator.of(_).pop();
              // AuthHelper().setUserData(getLoginResponse);
              Future.delayed(Duration(seconds: 3), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Main();
                    },
                  ),
                );
              });

              // onConfirmMarkDelivered(order_id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.login_to} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _login_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.login_screen_phone,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 36,
                      child: CustomInternationalPhoneNumberInput(
                        countries: countries_code,
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                          setState(() {
                            _phone = number.phoneNumber;
                          });
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                        textStyle: TextStyle(color: MyTheme.font_grey),
                        initialValue:
                        PhoneNumber(isoCode: countries_code[0].toString()),
                        textFieldController: _phoneNumberController,
                        formatInput: true,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputDecoration:
                        InputDecorations.buildInputDecoration_phone(
                            hint_text: "01XXX XXX XXX"),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: MyTheme.textfield_grey, width: 1),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(12.0))),
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(6.0))),
                    child: Text(
                      "Sent OTP",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (_phoneNumberController.text.isEmpty) {
                        ToastComponent.showDialog(
                            "Need to fill the Mobile Number",
                            gravity: Toast.center,
                            duration: Toast.lengthLong);
                      } else {
                        // var optResponseData =
                        // await AuthRepository().getOtpMobile(
                        //   phoneNumber:
                        //   _phoneNumberController.text.trim().toString(),
                        // );
                        // Future.delayed(Duration(seconds: 2), sendOtp());
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 50,
                  color: MyTheme.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(6.0))),
                  child: Text(
                    AppLocalizations.of(context)!.or_login_with_an_email,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Login();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

## 4.9.6
* goRouter 사용시 ios 뒤로가기 런타임 에러 개선

## 4.9.5
* goRouter 사용시 안드로이드 뒤로가기 런타임 에러 개선 

## 4.9.4
* 상태관리 제거, statless 위젯으로 변경
* 최적화 

## 4.9.2
* Bootpay().removePaymentWindow(); 함수 추가 

## 4.9.1
* android ssl error 시 업데이트 안내하도록 개선 

## 4.9.0 
* 삼성폰 안드로이드 웹뷰 프리징 현상 개선 

## 4.8.7-beta.1
* extra-cupDeposit 삭제, payload에 deposit_price 추가 

## 4.8.6
* payload, extra, item 생성자 추가 

## 4.8.5
* 네이버페이 관련 옵션 추가 
* 모델 리팩토링 

## 4.8.4
* 개발모드 변경 가능하게 설정 

## 4.8.3
* js version update
* 카드지정, 제외카드 지정 버그 수정 

## 4.8.2
* direct card option added

## 4.8.0
* andorid gradle version 8 support

## 4.7.5
* ios webview version update

## 4.7.4
* inicis android scheme bug fixed

## 4.7.3
* 4.7.2 업데이트 픽스 
* 
## 4.7.2
* js sdk 버전 업데이트 

## 4.7.1
* 4.6.9 버전 핫 픽스 

## 4.7.0
* flutter web을 위한 Bootpay.dismiss(); 기능 추가 

## 4.6.9
* flutter web을 위한 show_close_button 옵션 추가 

## 4.6.8 
* browser_open_type option added 

## 4.6.6
* 네이버페이 뒤로가기 버튼 제거 

## 4.6.5
* 에스크로 옵션 추가 

## 4.6.4
* webview version update

## 4.6.3
* Bootpay.setLocale 기능 버그 수정 

## 4.6.2
* webview version update
* 결제 후 원래앱으로 돌아와서 결제되지 않는 현상 개선(Could not find specified service) 


## 4.6.0
* Transmitting staged metadata in a specific scenario

## 4.5.23
* Update pub.dev/score

## 4.5.2
* Improved the bug that onDone is not called when it is an iframe

## 4.5.1
* Webview version update

## 4.5.0
* Webview version update

## 4.4.5
* After bootpay.confirm(), you must keep the js error log that occurred when the rule was applied.

## 4.4.4
* params -> Metadata field data change, metadata transmission problem improved

## 4.4.3
* Improved closing if conditional after registering card automatic payment payment method

## 4.4.2
* User authentication age_limit default value 0 gray

## 4.4.1
* Add 100 won payment option extra.subscribe_test_payment when requesting automatic card payment
## 4.4.0
* Apply after forking to bootpay_webview_flutter 3.x version
* Fixed stats bug

## 4.3.5
* Fixed to the existing webview version, not the new webview version

## 4.3.4
* Confirm async Web bug fixed
* js 4.2.5 update
* Add age_limit for authentication

## 4.3.3
* confirm async Web support

## 4.3.2
* confirm async support
* If confirm is defined, confirm is executed,
* If confirm is not defined, confirmAsync is performed

## 4.3.1
* Support event async after request

## 4.2.7
* js 4.2.2 update
* Fixed a bug where debounce close was called repeatedly

## 4.2.6
* js 4.2.1 update

## 4.2.5
* js 4.2.0 update, insert progress bar at checkout
* 
## 4.2.4
* Fixed a bug where debounce close was called repeatedly

## 4.2.3
* Apply close event debounce
* delete closeHardware event
* Apply ios swipe back

## 4.2.2
* bootpay js 4.1.2 update, methods bug fix

## 4.2.1
* Distribution for bio and version synchronization

## 4.2.0
* bootpay js 4.1.0 update

## 4.1.4
* When the webview is popped, it is null, but there is a build phenomenon, so exception handling

## 4.1.3
* Flutter web regular payment, identity authentication bug fix

## 4.1.1
* Fix tablet judgment bug

## 4.1.0
* ipad resize

## 4.0.9
* ipad payment support

## 4.0.8
* Support password payment

## 4.0.7
* Flutter web support

## 4.0.6
* Fix bug where uuid is not guaranteed
## 4.0.5
* Modified so that version information is not sent when calling statistical functions (by the developer)

## 4.0.4
* Apply extra openType redirect default

## 4.0.3
* Delete print log part

## 4.0.2
* Add model for extra option

## 4.0.1
* Fixed regular payment, user authentication call function bug

## 4.0.0
* bootpay js major update

## 1.9.01
* Fixed session key bug related to statistics

## 1.9.0
* bootpay webview downgrade to 2.2.21

## 1.8.13
* Fixed a bug that crashes with webview_flutter in v2 webview android

## 1.8.12
* bootpay webview upgrade to 3.0.12

## 1.8.11
* bootpay webview downgrade to 2.3.0

## 1.8.1
* bootpay webview update to 3.0.11

## 1.8.0
* bootpay webview update to 3.0.1

## 1.7.7
* extra carrier option define default value

## 1.7.6
* Close Android back button - fix onCloseHardware bug

## 1.7.5
* Apply gradle 7.0 version for android 12, apply minSdk 21 or higher
* Fix android navgation url logic
* Naver Pay back button removed

## 1.7.4
* Fix quota bug

## 1.7.3
* Apply bootpay_webview_flutter 2.1.41

## 1.7.2
* There is a bug where the payment window does not open when there is a ' character in the product name, so exception handling

## 1.7.1
* Handle null condition in dismiss function

## 1.7.0
* Insert a close button when the Naver Pay payment screen appears

## 1.6.1
* Integration example update

## 1.6.0
* Apply bootpay webview 2.1.4
- android manifest external app package name update

## 1.5.0
* Changed function interface name for statistics
* Fixed a bug that missed the event when clicking bootpay closeButton

## 1.4.1
* Fixed warning message not appearing when calling Bootpay.transacntionConfirm

## 1.4.0
* analytics bootpay api added 

## 1.3.2
* null safety migration

## 1.3.1
* null safety migration
## 1.3.0
* Fixed a fatal bug where onReady could not be called when issuing a virtual account

## 1.2.1
* readme updates

## 1.1.9
* A javascript error warning message is displayed and resolved with an asynchronous call to that part

## 1.1.8
* Change field name applicationId => webApplicationId

## 1.1.7
* Fix bugs in methods when making web payments, diverge app and logic

## 1.1.6
* Removed comments added during debug

## 1.1.5
* Fix bugs in methods when making web payments

## 1.1.4
* Modified so that the warning message does not remain when bootpay request

## 1.1.3
* Remove isMaterialStyle parameter

## 1.1.2
* update webview version

## 1.1.1
* methods bug fix

## 1.1.0
* Version redistribution

## 1.0.6
* webview navigation bug fix

## 1.0.5
* Changed the function so that it does not automatically close after onClose is called, explicitly changed so that the developer must directly call Bootpay().dissmiss() to close
* Close Android back button - add onCloseHardware event
* Fix android webview keyboard focus bug

## 1.0.4
* Change the widget tree inside the bottom sheet

## 1.0.3
* Fix iOS webview crash bug

## 1.0.2
* iOS build bug fixes

## 1.0.1
* Android api 29 and below bug fix

## 1.0.0
* Android, iOS, Web support
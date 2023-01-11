## 4.4.4
* params -> metadata 필드데이터 변경, metadata 전송안되는 현상 개선 

## 4.4.3
* 카드자동결제 결제수단 등록 후 조건부적 안닫히는 현상 개선
 
## 4.4.2
* 본인인증 age_limit default 값 0 으로 셋팅  

## 4.4.1
* 카드자동결제 요청시 100원 결제 옵션 extra.subscribe_test_payment 추가 

## 4.4.0
* bootpay_webview_flutter 3.x 버전으로 fork 후 적용 
* 통계 버그 수정 

## 4.3.5
* ㅅㅐ로운 웹뷰버전이 아닌 기존 웹뷰버전으로 고정 

## 4.3.4
* confirm async Web 버그 수정
* js 4.2.5 update 
* 본인인증 age_limit 추가 

## 4.3.3
* confirm async Web 지원

## 4.3.2
* confirm async 지원
    - confirm이 정의되어있다면 confirm이 수행되고,
    - confirm이 정의되어있지 않다면, confirmAsync가 수행됨 

## 4.3.1
* request 후 event  async 지원  

## 4.2.7
* js 4.2.2 update
* debounce close 중복호출되는 버그 수정

## 4.2.6
* js 4.2.1 update

## 4.2.5
* js 4.2.0 update, 결제시 progress bar 삽입 

## 4.2.4
* debounce close 중복호출되는 버그 수정 

## 4.2.3
* close event debounce 적용
* closeHardware event 삭제
* ios swipe back 적용 

## 4.2.2
* bootpay js 4.1.2 update, methods 버그 수정 

## 4.2.1
* bio와 버전 동기화를 위한 배포 

## 4.2.0
* bootpay js 4.1.0 업데이트 

## 4.1.4
* webview가 pop 될때 null인데 빌드되는 현상이 있어 예외처리 

## 4.1.3
* flutter web 정기결제, 본인인증 버그 수정 

## 4.1.1
* tablet 판단 버그 수정  

## 4.1.0
* ipad resize

## 4.0.9
* ipad 결제 지원 

## 4.0.8
* password 결제 지원 

## 4.0.7
* flutter web 지원 

## 4.0.6
* uuid 보장안되는 버그 수정 

## 4.0.5
* 통계함수 호출시 버전정보 보내지 않도록(개발사가) 수정 

## 4.0.4
* extra openType redirect default 적용

## 4.0.3
* print log 부분 삭제 

## 4.0.2
* extra 옵션을 위한 모델 추가 

## 4.0.1
* 정기결제, 본인인증 호출 함수 버그 수정 

## 4.0.0
* bootpay js major update 

## 1.9.01
* 통계관련 세션키 버그 수정 

## 1.9.0
* bootpay webview downgrade to 2.2.21

## 1.8.13
* v2 webview android 에서 webview_flutter와 충돌나는 버그 수정 

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
* 안드로이드 백버튼 종료 - onCloseHardware 버그 수정 

## 1.7.5
* android 12를 위한 gradle 7.0 버전 적용, minSdk 21 이상 적용
* 안드로이드 navgation url 로직 수정 
* 네이버페이 뒤로가기 버튼 제거 

## 1.7.4
* quota 버그 수정 

## 1.7.3
* bootpay_webview_flutter 2.1.41 적용 

## 1.7.2
* 상품명에 ' 문자가 있을 경우 결제창이 열리지 않는 버그가 있어서 예외처리

## 1.7.1
* dismiss 함수에 null 조건 처리 

## 1.7.0
* 네이버페이 결제형 화면 나타났을 경우 close 버튼을 삽입 

## 1.6.1
* 연동 예제 update

## 1.6.0
* bootpay webview 2.1.4 적용 
 - android manifest 외부앱 패키지명 update

## 1.5.0
* 통계용 함수 인터페이스명 변경
* bootpay closeButton 클릭시 이벤트 누락 버그 수정 

## 1.4.1
* Bootpay.transacntionConfirm 호출시 경고문구 안뜨게 수정 

## 1.4.0
* analytics bootpay api added 

## 1.3.2
* null safety migration

## 1.3.1
* null safety migration

## 1.3.0
* 가상계좌 발급시 onReady 호출 안되는 치명적 버그 수정 

## 1.2.1
* readme update 

## 1.1.9
* javascript error 경고 문구가 나서 해당 부분 비동기 호출로 해결

## 1.1.8
* 필드명 변경 applicationId => webApplicationId

## 1.1.7
* web 결제시 methods 버그 수정, 앱과 로직 분기 

## 1.1.6
* debug 시 넣었던 주석 제거 

## 1.1.5
* web 결제시 methods 버그 수정 

## 1.1.4
* bootpay reqeust시 경고 문구 남지 않게 수정 

## 1.1.3
* isMaterialStyle 파라미터 삭제  

## 1.1.2
* webview 버전 업데이트 

## 1.1.1
* methods 버그 수정 

## 1.1.0
* 버전 재배포  

## 1.0.6
* webview navigation 버그 개선 

## 1.0.5
* onClose 호출 후 자동으로 닫히지 않도록 기능 변경, 개발자가 직접 Bootpay().dissmiss()를 호출해야 닫히도록 명시적으로 변경
* 안드로이드 백버튼 종료 - onCloseHardware 이벤트 추가 
* 안드로이드 웹뷰 키보드 포커스 버그 수정 

## 1.0.4
* bottom sheet 내부 위젯트리 변경   

## 1.0.3
* iOS webview 충돌 버그 수정  

## 1.0.2
* iOS 빌드 버그 수정  

## 1.0.1
* Android api 29 이하 버그 수정  

## 1.0.0
* Android, iOS, Web 지원 
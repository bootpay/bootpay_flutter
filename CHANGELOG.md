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
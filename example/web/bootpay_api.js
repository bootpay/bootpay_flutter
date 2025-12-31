//function _requestPayment(payload) {
//    Bootpay.requestPayment(JSON.parse(payload))
//    .then(function(res){
//        if (res.event === 'confirm') {
//              Bootpay.confirm()
//              .then(function(confirmRes) {
//                    BootpayDone(JSON.stringify(confirmRes));
//              }, function(confirmRes) {
//               if (confirmRes.event === 'error') { BootpayError(JSON.stringify(confirmRes)); }
//               else if (confirmRes.event === 'cancel') { BootpayCancel(JSON.stringify(confirmRes)); }
//              })
//
//        }
//        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
//        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
//    }, function(res) {
//        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
//        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
//    });
//}



function _setLocale(locale) {
    Bootpay.setLocale(locale)
}

function _removePaymentWindow() {
    Bootpay.dismiss()
}


var closeEventRegistered = false; // close 이벤트가 등록되었는지 여부를 추적하는 변수

// 서버에서 window.BootpayFlutterWebView.postMessage(data)로 보내는 이벤트 처리
// Android/iOS 네이티브와 동일한 인터페이스 제공
window.BootpayFlutterWebView = {
    postMessage: function(data) {
        console.log('[BootpayFlutterWebView] postMessage received:', data);
        try {
            var parsed = (typeof data === 'string') ? JSON.parse(data) : data;
            var dataStr = (typeof data === 'string') ? data : JSON.stringify(data);

            switch(parsed.event) {
                case 'cancel':
                    if (window.BootpayCancel) BootpayCancel(dataStr);
                    if (window.BootpayClose) BootpayClose();
                    break;
                case 'error':
                    if (window.BootpayError) BootpayError(dataStr);
                    if (window.BootpayClose) BootpayClose();
                    break;
                case 'issued':
                    if (window.BootpayIssued) BootpayIssued(dataStr);
                    break;
                case 'done':
                    if (window.BootpayDone) BootpayDone(dataStr);
                    break;
                case 'confirm':
                    if (window.BootpayConfirm) {
                        if (BootpayConfirm(dataStr)) {
                            _transactionConfirm();
                        } else if (window.BootpayAsyncConfirm) {
                            BootpayAsyncConfirm(dataStr)
                            .then(function(res) {
                                if (res) {
                                    _transactionConfirm();
                                }
                            });
                        }
                    }
                    break;
                case 'close':
                    if (window.BootpayClose) BootpayClose();
                    break;
                case 'bootpayWidgetFullSizeScreen':
                    // 위젯 전체화면 이벤트 (Web에서는 JS SDK가 자체 처리)
                    console.log('[BootpayFlutterWebView] bootpayWidgetFullSizeScreen');
                    break;
                case 'bootpayWidgetRevertScreen':
                    // 위젯 화면 복귀 이벤트 (Web에서는 JS SDK가 자체 처리)
                    console.log('[BootpayFlutterWebView] bootpayWidgetRevertScreen');
                    break;
                default:
                    console.log('[BootpayFlutterWebView] Unknown event:', parsed.event);
            }
        } catch (e) {
            console.error('[BootpayFlutterWebView] Error parsing data:', e);
        }
    }
};

function _jsBeforeLoad() {
    _addCloseEventOnce(); // 이 함수를 호출하여 한 번만 close 이벤트를 등록하도록 함
}

function _addCloseEventOnce() {
    if (!closeEventRegistered) { // close 이벤트가 등록되어 있지 않은 경우에만 등록

        document.addEventListener('bootpayclose', function (e) {
            if (window.BootpayClose) {
                BootpayClose();
            }
        });
        closeEventRegistered = true; // close 이벤트가 이제 등록되었음을 표시
    }
}


function _requestPayment(payload) {
    Bootpay.requestPayment(JSON.parse(payload))
    .then(function(res){
        if (res.event === 'confirm') {
          if(BootpayConfirm(JSON.stringify(res))) {
            _transactionConfirm();
          } else {
            BootpayAsyncConfirm(JSON.stringify(res))
            .then(function(res){
              if(res) {
                _transactionConfirm();
              }
            }, function(res) {
            });
          }
        }
        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
    }, function(res) {
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
    });
}

//function _requestPayment(payload) {
//    Bootpay.requestPayment(JSON.parse(payload))
//    .then(function(res){
//        if (res.event === 'confirm') {
//          if(BootpayConfirm(JSON.stringify(res))) {
//            _transactionConfirm();
//          } else {
//            BootpayAsyncConfirm(JSON.stringify(res))
//            .then(function(res){
//              if(res) {
//                _transactionConfirm();
//              }
//            }, function(res) {
//            });
//          }
//        }
//        else if (res.event === 'issued') { console.log(res);  }
//        else if (res.event === 'done') { console.log(res);  }
//    }, function(res) {
//        if (res.event === 'error') { console.log(res); }
//        else if (res.event === 'cancel') { console.log(res); }
//    });
//}

function _requestSubscription(payload) {
    console.log('[Bootpay] _requestSubscription called');
    console.log('[Bootpay] BootpayCancel defined:', typeof window.BootpayCancel);
    console.log('[Bootpay] BootpayClose defined:', typeof window.BootpayClose);
    Bootpay.requestSubscription(JSON.parse(payload))
    .then(function(res){
        console.log('[Bootpay] subscription then:', res.event, res);
        if (res.event === 'confirm') {
          if(BootpayConfirm(JSON.stringify(res))) {
            _transactionConfirm();
          } else {
            BootpayAsyncConfirm(JSON.stringify(res))
            .then(function(res){
              if(res) {
                _transactionConfirm();
              }
            }, function(res) {
            });
          }
        }
        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res)); BootpayClose(); }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res)); BootpayClose(); }
    }, function(res) {
        console.log('[Bootpay] subscription reject:', res.event, res);
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); BootpayClose(); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); BootpayClose(); }
    });
}

function _requestAuthentication(payload) {
    Bootpay.requestAuthentication(JSON.parse(payload))
    .then(function(res){
        if (res.event === 'confirm') {
          if(BootpayConfirm(JSON.stringify(res))) {
            _transactionConfirm();
          } else {
            BootpayAsyncConfirm(JSON.stringify(res))
            .then(function(res){
              if(res) {
                _transactionConfirm();
              }
            }, function(res) {
            });
          }
        }
        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
    }, function(res) {
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
    });
}

function _transactionConfirm() {
    Bootpay.confirm()
    .then(function(res){
        if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
    }, function(res) {
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
    });
}

function _dismiss(context) {
    Bootpay.destroy();
}

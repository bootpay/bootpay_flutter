

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
    Bootpay.requestSubscription(JSON.parse(payload))
    .then(function(res){
        if (res.event === 'confirm') {
          if(BootpayConfirm(JSON.stringify(res))) {
            _transactionConfirm();
          }
        }
        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
    }, function(res) {
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
    });
}

function _requestAuthentication(payload) {
    Bootpay.requestAuthentication(JSON.parse(payload))
    .then(function(res){
        if (res.event === 'confirm') {
          if(BootpayConfirm(JSON.stringify(res))) {
            _transactionConfirm();
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

// ========== Widget 관련 함수 ==========

// Widget 컨테이너 생성
function _createWidgetContainer(containerId) {
    var container = document.getElementById(containerId);
    if (!container) {
        container = document.createElement('div');
        container.id = containerId;
        container.style.width = '100%';
        container.style.minHeight = '300px';
    }
    return container;
}

// Widget 렌더링
function _renderWidget(containerId, payload) {
    var container = _createWidgetContainer(containerId);
    if (typeof BootpayWidget !== 'undefined') {
        BootpayWidget.render('#' + containerId, JSON.parse(payload));
    } else {
        console.error('BootpayWidget is not loaded');
    }
}

// Widget 업데이트
function _updateWidget(payload, refresh) {
    if (typeof BootpayWidget !== 'undefined') {
        BootpayWidget.update(JSON.parse(payload), refresh);
    }
}

// Widget 결제 요청
function _widgetRequestPayment(payload) {
    if (typeof BootpayWidget !== 'undefined') {
        return BootpayWidget.requestPayment(JSON.parse(payload));
    }
    return Promise.reject({event: 'error', error: 'BootpayWidget is not loaded'});
}

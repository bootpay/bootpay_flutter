

function _requestPayment(payload) {
    Bootpay.requestPayment(JSON.parse(payload))
    .then(function(res){
        if (res.event === 'confirm') {
              Bootpay.confirm()
              .then(function(confirmRes) {
                    BootpayDone(JSON.stringify(confirmRes));
              }, function(confirmRes) {
               if (confirmRes.event === 'error') { BootpayError(JSON.stringify(confirmRes)); }
               else if (confirmRes.event === 'cancel') { BootpayCancel(JSON.stringify(confirmRes)); }
              })

        }
        else if (res.event === 'issued') { BootpayIssued(JSON.stringify(res));  }
        else if (res.event === 'done') { BootpayDone(JSON.stringify(res));  }
    }, function(res) {
        if (res.event === 'error') { BootpayError(JSON.stringify(res)); }
        else if (res.event === 'cancel') { BootpayCancel(JSON.stringify(res)); }
    });
}


function _jsBeforeLoad() {
    _addCloseEvent();
}

function _setLocale(locale) {
    Bootpay.setLocale(locale)
}

function _addCloseEvent() {
    document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });
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

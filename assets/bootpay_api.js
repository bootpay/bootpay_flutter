function _request(payload) {
//alert(2134);
    BootPay.request(JSON.parse(payload))
    .error(function(data){ BootpayError( JSON.stringify(data) ); })
    .ready(function(data){ BootpayReady( JSON.stringify(data) ); })
    .close(function(data){ BootpayClose(                     ); })
    .confirm(function(data){
        var result = BootpayConfirm( JSON.stringify(data) );
        if(result) {
            BootPay.transactionConfirm(data);
        } else {
            BootPay.removePaymentWindow();
        }
    })
    .cancel(function(data){ BootpayCancel( JSON.stringify(data) ); })
    .done(function(data){ BootpayDone( JSON.stringify(data) ); })
}

function _transactionConfirm(data) {
    BootPay.transactionConfirm(data);
}

function _removePaymentWindow() {
    BootPay.removePaymentWindow();
}

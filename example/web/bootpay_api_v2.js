function _jsBeforeLoad() {
    Bootpay.setEnvironmentMode('development');
    _addCloseEvent();
}

function _requestPayment(payload) {
    Bootpay.requestPayment(JSON.parse(payload))
    .then(
        function (response) {
            if (response.event === 'confirm') {
                var result = BootpayConfirm( JSON.stringify(response) );
                if(result) {
                    Bootpay.confirm().then(
                        function (response) {
                            if (response.event === 'issued') {
                                BootpayIssued( JSON.stringify(response) );
                            } else if(response.event === 'done') {
                                BootpayDone( JSON.stringify(response) );
                            }
                        }, function (error) {
                            switch (error.event) {
                                case 'error':
                                    BootpayError( JSON.stringify(error) );
                                    break;
                                case 'cancel':
                                    BootpayCancel( JSON.stringify(error) );
                                    break;
                                default:
                                    break;
                                // alert(error.message)
                            }
                        }
                    );
                } else {
                    Bootpay.removePaymentWindow();
                }
            } else if(response.event === 'done') {
                BootpayDone( JSON.stringify(response) );
            } else if(response.event === 'issued') {
                BootpayIssued( JSON.stringify(response) );
            }
        }, function (error) {
            switch (error.event) {
                case 'error':
                    BootpayError( JSON.stringify(error) );
                    break;
                case 'cancel':
                    BootpayCancel( JSON.stringify(error) );
                    break;
                default:
                    throw error
                // alert(error.message)
            }
        }
    );
}

function _requestSubscription() {
    Bootpay.requestSubscription(JSON.parse(payload))
    .then(
        function (response) {
            if (response.event === 'confirm') {
                var result = BootpayConfirm( JSON.stringify(response) );
                if(result) {
                    Bootpay.confirm().then(
                        function (response) {
                            if (response.event === 'issued') {
                                BootpayIssued( JSON.stringify(response) );
                            } else if(response.event === 'done') {
                                BootpayDone( JSON.stringify(response) );
                            }
                        }, function (error) {
                            switch (error.event) {
                                case 'error':
                                    BootpayError( JSON.stringify(error) );
                                    break;
                                case 'cancel':
                                    BootpayCancel( JSON.stringify(error) );
                                    break;
                                default:
                                    break;
                                // alert(error.message)
                            }
                        }
                    );
                } else {
                    Bootpay.removePaymentWindow();
                }
            } else if(response.event === 'done') {
                BootpayDone( JSON.stringify(response) );
            } else if(response.event === 'issued') {
                BootpayIssued( JSON.stringify(response) );
            }
        }, function (error) {
            switch (error.event) {
                case 'error':
                    BootpayError( JSON.stringify(error) );
                    break;
                case 'cancel':
                    BootpayCancel( JSON.stringify(error) );
                    break;
                default:
                    throw error
                // alert(error.message)
            }
        }
    );
}

function _requestAuthentication() {
    Bootpay.requestAuthentication(JSON.parse(payload))
    .then(
        function (response) {
            if (response.event === 'confirm') {
                var result = BootpayConfirm( JSON.stringify(response) );
                if(result) {
                    Bootpay.confirm().then(
                        function (response) {
                            if (response.event === 'issued') {
                                BootpayIssued( JSON.stringify(response) );
                            } else if(response.event === 'done') {
                                BootpayDone( JSON.stringify(response) );
                            }
                        }, function (error) {
                            switch (error.event) {
                                case 'error':
                                    BootpayError( JSON.stringify(error) );
                                    break;
                                case 'cancel':
                                    BootpayCancel( JSON.stringify(error) );
                                    break;
                                default:
                                    break;
                                // alert(error.message)
                            }
                        }
                    );
                } else {
                    Bootpay.removePaymentWindow();
                }
            } else if(response.event === 'done') {
                BootpayDone( JSON.stringify(response) );
            } else if(response.event === 'issued') {
                BootpayIssued( JSON.stringify(response) );
            }
        }, function (error) {
            switch (error.event) {
                case 'error':
                    BootpayError( JSON.stringify(error) );
                    break;
                case 'cancel':
                    BootpayCancel( JSON.stringify(error) );
                    break;
                default:
                    break;
//                    throw error
                // alert(error.message)
            }
        }
    );
}

function _confirm() {
    Bootpay.confirm().then(
        function (response) {
            if (response.event === 'issued') {
                BootpayIssued( JSON.stringify(response) );
            } else if(response.event === 'done') {
                BootpayDone( JSON.stringify(response) );
            }
        }, function (error) {
            switch (error.event) {
                case 'error':
                    BootpayError( JSON.stringify(error) );
                    break;
                case 'cancel':
                    BootpayCancel( JSON.stringify(error) );
                    break;
                default:
                    break;
                // alert(error.message)
            }
        }
    );
}

function _removePaymentWindow() {
    Bootpay.removePaymentWindow();
}

function _addCloseEvent() {
    document.addEventListener('bootpayclose', function (e) {
        BootpayClose();
    });
}
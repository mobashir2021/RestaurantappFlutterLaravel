@php($currency=\App\Model\BusinessSetting::where(['key'=>'currency'])->first()->value)

    <!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <title>
        @yield('title')
    </title>
    <!-- SEO Meta Tags-->
    <meta name="description" content="">
    <meta name="keywords" content="">
    <meta name="author" content="">
    <!-- Viewport-->
    {{--<meta name="_token" content="{{csrf_token()}}">--}}
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Favicon and Touch Icons-->
    <link rel="shortcut icon" href="favicon.ico">
    <!-- Font -->
    <!-- CSS Implementing Plugins -->
    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/css/vendor.min.css">
    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/vendor/icon-set/style.css">
    <!-- CSS Front Template -->
    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/css/theme.minc619.css?v=1.0">
    <script
        src="{{asset('public/assets/admin')}}/vendor/hs-navbar-vertical-aside/hs-navbar-vertical-aside-mini-cache.js"></script>
    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/css/toastr.css">

    {{--stripe--}}
    <script src="https://polyfill.io/v3/polyfill.min.js?version=3.52.1&features=fetch"></script>
    <script src="https://js.stripe.com/v3/"></script>
    {{--stripe--}}

    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/css/bootstrap.css">

</head>
<!-- Body-->
<body class="toolbar-enabled">
<!-- Page Content-->
<div class="container pb-5 mb-2 mb-md-4">
    <div class="row">
        <div class="col-md-12 mb-5 pt-5">
            <center class="">
                <h1>Payment method</h1>
            </center>
        </div>
        <section class="col-lg-12">
            <div class="checkout_details mt-3">
                <div class="row">

                    @php($config=\App\CentralLogics\Helpers::get_business_settings('ssl_commerz_payment'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card" onclick="$('#ssl-form').submit()">
                                <div class="card-body" style="height: 70px">
                                    <form action="{{ url('/pay-ssl') }}" method="POST" class="needs-validation"
                                          id="ssl-form">
                                        <input type="hidden" value="{{ csrf_token() }}" name="_token"/>
                                        <button class="btn btn-block" type="submit">
                                            <img width="100"
                                                 src="{{asset('public/assets/admin/img/sslcomz.png')}}"/>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @endif

                    @php($config=\App\CentralLogics\Helpers::get_business_settings('razor_pay'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    @php($config=\App\CentralLogics\Helpers::get_business_settings('razor_pay'))
                                    @php($order=\App\Model\Order::find(session('order_id')))
                                    <form action="{!!route('payment-razor')!!}" method="POST">
                                    @csrf
                                    <!-- Note that the amount is in paise = 50 INR -->
                                        <!--amount need to be in paisa-->
                                        <script src="https://checkout.razorpay.com/v1/checkout.js"
                                                data-key="{{ Config::get('razor.razor_key') }}"
                                                data-amount="{{$order->order_amount*100}}"
                                                data-buttontext="Pay {{$order->order_amount}} {{\App\CentralLogics\Helpers::currency_code()}}"
                                                data-name="{{\App\Model\BusinessSetting::where(['key'=>'restaurant_name'])->first()->value}}"
                                                data-description="{{$order['id']}}"
                                                data-image="{{asset('storage/app/public/restaurant/'.\App\Model\BusinessSetting::where(['key'=>'logo'])->first()->value)}}"
                                                data-prefill.name="{{$order->customer->f_name}}"
                                                data-prefill.email="{{$order->customer->email}}"
                                                data-theme.color="#ff7529">
                                        </script>
                                    </form>
                                    <button class="btn btn-block" type="button"
                                            onclick="{{\App\CentralLogics\Helpers::currency_code()=='INR'?"$('.razorpay-payment-button').click()":"toastr.error('Your currency is not supported by Razor Pay.')"}}">
                                        <img width="100"
                                             src="{{asset('public/assets/admin/img/razorpay.png')}}"/>
                                    </button>
                                </div>
                            </div>
                        </div>
                    @endif


                    @php($config=\App\CentralLogics\Helpers::get_business_settings('paypal'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    <form class="needs-validation" method="POST" id="payment-form"
                                          action="{{route('pay-paypal')}}">
                                        {{ csrf_field() }}
                                        <button class="btn btn-block" type="submit">
                                            <img width="100"
                                                 src="{{asset('public/assets/admin/img/paypal.png')}}"/>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @endif


                    @php($config=\App\CentralLogics\Helpers::get_business_settings('stripe'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    @php($config=\App\CentralLogics\Helpers::get_business_settings('stripe'))
                                    <button class="btn btn-block" type="button" id="checkout-button">
                                        <i class="czi-card"></i> Credit / Debit card ( Stripe )
                                    </button>
                                    <script type="text/javascript">
                                        // Create an instance of the Stripe object with your publishable API key
                                        var stripe = Stripe('{{$config['published_key']}}');
                                        var checkoutButton = document.getElementById("checkout-button");
                                        checkoutButton.addEventListener("click", function () {
                                            fetch("{{route('pay-stripe')}}", {
                                                method: "GET",
                                            }).then(function (response) {
                                                console.log(response)
                                                return response.text();
                                            }).then(function (session) {
                                                console.log(JSON.parse(session).id)
                                                return stripe.redirectToCheckout({sessionId: JSON.parse(session).id});
                                            }).then(function (result) {
                                                if (result.error) {
                                                    alert(result.error.message);
                                                }
                                            }).catch(function (error) {
                                                console.error("Error:", error);
                                            });
                                        });
                                    </script>
                                </div>
                            </div>
                        </div>
                    @endif


                    @php($config=\App\CentralLogics\Helpers::get_business_settings('paystack'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    @php($config=\App\CentralLogics\Helpers::get_business_settings('paystack'))
                                    @php($order=\App\Model\Order::find(session('order_id')))
                                    <form method="POST" action="{{ route('paystack-pay') }}" accept-charset="UTF-8"
                                          class="form-horizontal"
                                          role="form">
                                        @csrf
                                        <div class="row">
                                            <div class="col-md-8 col-md-offset-2">
                                                <input type="hidden" name="email"
                                                       value="{{$order->customer->email!=null?$order->customer->email:'required@email.com'}}"> {{-- required --}}
                                                <input type="hidden" name="orderID" value="{{$order['id']}}">
                                                <input type="hidden" name="amount"
                                                       value="{{$order['order_amount']*100}}"> {{-- required in kobo --}}
                                                <input type="hidden" name="quantity" value="1">
                                                <input type="hidden" name="currency"
                                                       value="{{$currency}}">
                                                <input type="hidden" name="metadata"
                                                       value="{{ json_encode($array = ['key_name' => 'value',]) }}"> {{-- For other necessary things you want to add to your payload. it is optional though --}}
                                                <input type="hidden" name="reference"
                                                       value="{{ Paystack::genTranxRef() }}"> {{-- required --}}
                                                <p>
                                                    <button class="paystack-payment-button" style="display: none"
                                                            type="submit"
                                                            value="Pay Now!"></button>
                                                </p>
                                            </div>
                                        </div>
                                    </form>
                                    <button class="btn btn-block" type="button"
                                            onclick="$('.paystack-payment-button').click()">
                                        <img width="100"
                                             src="{{asset('public/assets/admin/img/paystack.png')}}"/>
                                    </button>
                                </div>
                            </div>
                        </div>
                    @endif

                    @php($config=\App\CentralLogics\Helpers::get_business_settings('senang_pay'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    @php($config=\App\CentralLogics\Helpers::get_business_settings('senang_pay'))
                                    @php($order=\App\Model\Order::find(session('order_id')))
                                    @php($user=\App\User::where(['id'=>$order['user_id']])->first())
                                    @php($secretkey = $config['secret_key'])
                                    @php($data = new \stdClass())
                                    @php($data->merchantId = $config['merchant_id'])
                                    @php($data->detail = 'payment')
                                    @php($data->order_id = $order->id)
                                    @php($data->amount = $order->order_amount)
                                    @php($data->name = $user->f_name.' '.$user->l_name)
                                    @php($data->email = $user->email)
                                    @php($data->phone = $user->phone)
                                    @php($data->hashed_string = md5($secretkey . urldecode($data->detail) . urldecode($data->amount) . urldecode($data->order_id)))

                                    <form name="order" method="post"
                                          action="https://{{env('APP_MODE')=='live'?'app.senangpay.my':'sandbox.senangpay.my'}}/payment/{{$config['merchant_id']}}">
                                        <input type="hidden" name="detail" value="{{$data->detail}}">
                                        <input type="hidden" name="amount" value="{{$data->amount}}">
                                        <input type="hidden" name="order_id" value="{{$data->order_id}}">
                                        <input type="hidden" name="name" value="{{$data->name}}">
                                        <input type="hidden" name="email" value="{{$data->email}}">
                                        <input type="hidden" name="phone" value="{{$data->phone}}">
                                        <input type="hidden" name="hash" value="{{$data->hashed_string}}">
                                    </form>

                                    <button class="btn btn-block" type="button"
                                            onclick="{{\App\CentralLogics\Helpers::currency_code()=='MYR'?"document.order.submit()":"toastr.error('Your currency is not supported by Senang Pay.')"}}">
                                        <img width="100"
                                             src="{{asset('public/assets/admin/img/senangpay.png')}}"/>
                                    </button>
                                </div>
                            </div>
                        </div>
                    @endif

                    @php($config=\App\CentralLogics\Helpers::get_business_settings('internal_point'))
                    @if(isset($config) && $config['status'])
                        <div class="col-md-6 mb-4" style="cursor: pointer">
                            <div class="card">
                                <div class="card-body" style="height: 70px">
                                    <button class="btn btn-block" type="button" data-toggle="modal"
                                            data-target="#exampleModal">
                                        <i class="czi-card"></i> Wallet Point
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog"
                             aria-labelledby="exampleModalLabel"
                             aria-hidden="true">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h3 class="modal-title" id="exampleModalLabel">Payment by Wallet Point</h3>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <hr>
                                        @php($value=\App\Model\BusinessSetting::where(['key'=>'point_per_currency'])->first()->value)
                                        @php($order=\App\Model\Order::find(session('order_id')))
                                        @php($point=\App\User::where(['id'=>$order['user_id']])->first()->point)
                                        <span>Order Amount: {{$order['order_amount']}} {{\App\CentralLogics\Helpers::currency_symbol()}}</span><br>
                                        <span>Order Amount in Wallet Point : {{$value*$order['order_amount']}} Points</span><br>
                                        <span>Your Available Points : {{$point}} Points</span><br>
                                        <hr>
                                        <center>
                                            @if(($value*$order['order_amount'])<=$point)
                                                <label class="badge badge-soft-success">You have sufficient balance to
                                                    proceed!</label>
                                            @else
                                                <label class="badge badge-soft-danger">Your balance is
                                                    insufficient!</label>
                                            @endif
                                        </center>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close
                                        </button>
                                        @if(($value*$order['order_amount'])<=$point)
                                            <form action="{{route('internal-point-pay')}}" method="POST">
                                                @csrf
                                                <input name="order_id" value="{{$order['id']}}" style="display: none">
                                                <button type="submit" class="btn btn-primary">Proceed</button>
                                            </form>
                                        @else
                                            <button type="button" class="btn btn-primary">Sorry! Next time.</button>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endif
                </div>
            </div>
        </section>
    </div>
</div>

<!-- JS Front -->
<script src="{{asset('public/assets/admin')}}/js/jquery.js"></script>
<script src="{{asset('public/assets/admin')}}/js/bootstrap.js"></script>
<script src="{{asset('public/assets/admin')}}/js/sweet_alert.js"></script>
<script src="{{asset('public/assets/admin')}}/js/toastr.js"></script>
{!! Toastr::message() !!}

<script>
    setTimeout(function () {
        $('.stripe-button-el').hide();
        $('.razorpay-payment-button').hide();
    }, 10)
</script>

</body>
</html>

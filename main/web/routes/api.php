<?php

use App\Http\Controllers\Dashboard\DashboardController;
use App\Http\Controllers\Quran\API\Category\CategoryController;
use App\Http\Controllers\Quran\API\Chapter\ChapterController;
use App\Http\Controllers\Quran\API\Dhikr\DhikrController;
use App\Http\Controllers\Quran\API\Donation\DonationController;
use App\Http\Controllers\Quran\API\Donation\PaypalDonationController;
use App\Http\Controllers\Quran\API\Donation\PaystackDonationController;
use App\Http\Controllers\Quran\API\Donation\RazorpayDonationController;
use App\Http\Controllers\Quran\API\Donation\SslCommerzDonationController;
use App\Http\Controllers\Quran\API\Donation\StripeDonationController;
use App\Http\Controllers\Quran\API\Dua\DuaController;
use App\Http\Controllers\Quran\API\Chand\ChandController;
use App\Http\Controllers\Quran\API\HaramCode\HaramCodeController;
use App\Http\Controllers\Quran\API\HomeLayout\HomeLayoutController;
use App\Http\Controllers\Quran\API\Juze\JuzesController;
use App\Http\Controllers\Quran\API\PaymentMethod\PaymentMethodController;
use App\Http\Controllers\Quran\API\PrayerTime\PrayerTimeController;
use App\Http\Controllers\Quran\API\Reciter\ReciterController;
use App\Http\Controllers\Quran\API\Settings\SettingsController;
use App\Http\Controllers\Quran\API\SifatName\SifatNameController;
use App\Http\Controllers\Quran\API\Theme\ThemeController;
use App\Http\Controllers\Quran\API\Translator\TranslatorController;
use App\Http\Controllers\Quran\API\Verse\VerseController;
use App\Http\Controllers\Quran\API\WallPaper\WallpaperController;
use App\Http\Controllers\Quran\AI\AIChatController;
use App\Http\Controllers\Quran\WallPaper\WallpaperCategoryController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


Route::get('dashboard', [DashboardController::class, 'getDashboardInformation']);
Route::get('get_chand', [ChandController::class, 'getChand']);
Route::get('get-region-info', [DashboardController::class, 'getOsInfo']);
Route::get('get-country-info', [DashboardController::class, 'getCountryInfo']);
Route::get('chapters', [ChapterController::class, 'index']);
Route::get('verses/{chapter}', [VerseController::class, 'index']);
Route::get('juzes', [JuzesController::class, 'index']);
Route::get('translators', [TranslatorController::class, 'index']);
Route::get('dua-list', [DuaController::class, 'index']);
Route::get('dua-details/{id}', [DuaController::class, 'show']);
Route::get('dhikr-list', [DhikrController::class, 'dhikrList']);
Route::get('dhikr-details/{id}', [DhikrController::class, 'show']);
Route::get('sifat-name-list', [SifatNameController::class, 'dhikrList']);
Route::get('sifat-name-details/{id}', [SifatNameController::class, 'show']);
Route::get('haram-code-list', [HaramCodeController::class, 'haramCodeList']);
Route::any('today-prayer-time', [PrayerTimeController::class, 'getPrayerTime']);
Route::get('prayer-by-location', [PrayerTimeController::class, 'prayerByLocation']);
Route::get('settings', [SettingsController::class, 'index']);
Route::get('theme', [ThemeController::class, 'index']);
Route::get('home-layout', [HomeLayoutController::class, 'index']);
Route::get('donation-categories', [CategoryController::class, 'index']);
Route::post('donation-store', [DonationController::class, 'store']);
Route::get('donation-list', [DonationController::class, 'index']);
// Stripe
Route::post('donation/stripe/checkout', [StripeDonationController::class, 'createCheckout']);
Route::post('donation/stripe/verify',   [StripeDonationController::class, 'verifySession']);
// PayPal
Route::get('donation/paypal/client-id',      [PaypalDonationController::class, 'clientId']);
Route::post('donation/paypal/create-order',  [PaypalDonationController::class, 'createOrder']);
Route::post('donation/paypal/capture-order', [PaypalDonationController::class, 'captureOrder']);
// Razorpay
Route::post('donation/razorpay/create-order', [RazorpayDonationController::class, 'createOrder']);
Route::post('donation/razorpay/verify',        [RazorpayDonationController::class, 'verifyPayment']);
// Paystack
Route::get('donation/paystack/public-key',  [PaystackDonationController::class, 'publicKey']);
Route::post('donation/paystack/initialize', [PaystackDonationController::class, 'initialize']);
Route::post('donation/paystack/verify',     [PaystackDonationController::class, 'verify']);
// SSLCommerz
Route::post('donation/sslcommerz/initiate', [SslCommerzDonationController::class, 'initiate']);
Route::post('donation/sslcommerz/success',  [SslCommerzDonationController::class, 'success']);
Route::post('donation/sslcommerz/fail',     [SslCommerzDonationController::class, 'fail']);
Route::post('donation/sslcommerz/cancel',   [SslCommerzDonationController::class, 'cancel']);
Route::post('donation/sslcommerz/ipn',      [SslCommerzDonationController::class, 'ipn']);
Route::get('payment-methods', [PaymentMethodController::class, 'customerPaymentMethod']);
Route::get('get-cities', [PrayerTimeController::class, 'getCities']);
Route::get('reciters', [ReciterController::class, 'index']);
Route::get('reciter-sura/{reciter}', [ReciterController::class, 'reciterSuraList']);
Route::get('wallpapers', [WallpaperController::class, 'index']);
Route::get('wallpaper-category', [WallpaperCategoryController::class, 'wallpaperCategory']);
Route::post('ai/chat', [AIChatController::class, 'chat']);
Route::post('ai/generate-names', [AIChatController::class, 'generateNames']);

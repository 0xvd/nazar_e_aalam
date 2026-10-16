<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Dashboard\DashboardController;
use App\Http\Controllers\InstallDemoDataController;
use App\Http\Controllers\Installer\CompanySettingController;
use App\Http\Controllers\Installer\DatabaseManagerController;
use App\Http\Controllers\Installer\InitialSetupController;
use App\Http\Controllers\Installer\InstallerController;
use App\Http\Controllers\Installer\PurchaseKeyController;
use App\Http\Controllers\Profile\ProfileController;
use App\Http\Controllers\Quran\Donation\DonationController;
use App\Http\Controllers\Quran\Auth\ForgotPasswordController;
use App\Http\Controllers\Quran\Auth\ResetPasswordController;
use App\Http\Controllers\Quran\Auth\UserJoinController;
use App\Http\Controllers\Quran\Category\CategoryController;
use App\Http\Controllers\Quran\Dhikr\DhikrController;
use App\Http\Controllers\Quran\Dua\DuaController;
use App\Http\Controllers\Quran\HarmCode\HaramCodeController;
use App\Http\Controllers\Quran\Reciter\ReciterController;
use App\Http\Controllers\Quran\PaymentMethod\PaymentMethodController;
use App\Http\Controllers\Quran\PrayerTime\PrayerTimeController;
use App\Http\Controllers\Quran\PrayerTime\PrayerTimeImportController;
use App\Http\Controllers\Quran\Reciter\ReciterSuraController;
use App\Http\Controllers\Quran\Reciter\BulkSuraImportController;
use App\Http\Controllers\Quran\Settings\EmailSettingController;
use App\Http\Controllers\Quran\Settings\LandingSettingController;
use App\Http\Controllers\Quran\Settings\SettingsController;
use App\Http\Controllers\Quran\SifatName\SifatNameController;
use App\Http\Controllers\Quran\Blog\BlogController;
use App\Http\Controllers\Quran\Blog\BlogPublicController;
use App\Http\Controllers\Quran\Support\SupportController;
use App\Http\Controllers\Quran\WallPaper\WallpaperCategoryController;
use App\Http\Controllers\Quran\WallPaper\WallpaperController;
use App\Http\Controllers\Role\PermissionController;
use App\Http\Controllers\Role\RoleController;
use App\Http\Controllers\User\UserController;
use App\Http\Controllers\User\UserInviteController;
use App\Http\Controllers\View\ViewController;
use Illuminate\Routing\Router;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/
//Installation
Route::middleware('not_install')->group(function (Router $router) {
    $router->get('install', [InstallerController::class, 'installation'])->name('install.view');
    $router->get('installation/requirements', [InstallerController::class, 'index']);
    $router->get('purchase-code', [PurchaseKeyController::class, 'index'])
        ->name('purchase-code');
    $router->post('purchase-key', [PurchaseKeyController::class, 'check'])
        ->name('check.purchase-key');
    $router->get('environment-setup', [DatabaseManagerController::class, 'index'])->name('database.index');
    $router->post('connect-database', [DatabaseManagerController::class, 'setConnect'])->name('connect.database');
    $router->get('user-information', [DatabaseManagerController::class, 'userInformation'])->name('user.information');
    $router->post('user-store', [DatabaseManagerController::class, 'userStore'])->name('user.store');
    $router->get('company-information', [CompanySettingController::class, 'index'])->name('company.information');
    $router->post('company-store', [CompanySettingController::class, 'update'])->name('company.store');
    $router->get('email-setup', [DatabaseManagerController::class, 'emailSetup'])->name('email.setup');
    $router->post('email-store', [DatabaseManagerController::class, 'update'])->name('email.store');
    $router->post('setup-skip', [DatabaseManagerController::class, 'setupSkip'])->name('skip-setup');
});

Route::get('/', [ViewController::class, 'landingPage'])->name('landing')->middleware('install');
Route::get('/admin', function () {
    return redirect()->route('login');
});

Route::middleware(['guest', 'install'])->group(function () {
    Route::get('login', [LoginController::class, 'showLoginForm'])->name('login');
    Route::post('login', [LoginController::class, 'login'])->name('login.request');
    Route::get('forget-password', [ForgotPasswordController::class, 'index'])->name('forget.password');
    Route::post('forget-password', [ForgotPasswordController::class, 'store'])->name('reset.password.send');
    Route::get('password/reset', [ResetPasswordController::class, 'index'])->name('reset.password.link');
    Route::post('password/reset', [ResetPasswordController::class, 'update'])->name('password.reset');
    Route::get('join/user', [UserJoinController::class, 'index'])->name('user.join.link');
    Route::post('join/user', [UserJoinController::class, 'store'])->name('user.join.confirm');

});

//Supporting Routes for view
Route::middleware(['auth', 'authorize','install'])->controller(ViewController::class)->group(function (Router $router) {

    $router->get('user/list', 'userList')
        ->name('user-list.view')
        ->middleware('can:view_users');

    $router->get('role/list', 'roleList')
        ->name('role-list.view')
        ->middleware('can:view_roles');

    $router->get('haramcode/list', 'haramcodeList')
        ->name('haramcode-list.view')
        ->middleware('can:view_haram_codes');

    $router->get('sifat/list', 'sifatList')
        ->name('sifat-list.view')
        ->middleware('can:view_sifats');

    $router->get('dhikr/list', 'dhikrList')
        ->name('dhikr-list.view')
        ->middleware('can:view_dhikrs');

    $router->get('dua/list', 'duaList')
        ->name('dua-list.view')
        ->middleware('can:view_dua');

    $router->get('wallpaper/list', 'wallpaperList')
        ->name('wallpaper-list.view')
        ->middleware('can:view_wallpaper');

    $router->get('wallpaper/category', 'wallpaperCategory')
        ->name('wallpaper-category.view')
        ->middleware('can:view_wallpaper_category');

    $router->get('prayer-time/list', 'prayerTimeList')
        ->name('prayer-time-list.view')
        ->middleware('can:view_prayer_times');

    $router->get('prayer-time/create', 'prayerTimeCreate')
        ->name('prayer-time-create.view')
        ->middleware('can:create_prayer_times');

    $router->get('prayer-time/{id}/edit', 'prayerTimeEdit')
        ->name('prayer-time-edit.view')
        ->middleware('can:update_prayer_times');

    $router->get('import/prayer-time', 'prayerTimeImport')
        ->name('prayer-time-import.view')
        ->middleware('can:import_prayer_times');


    $router->get('setting', 'setting')
        ->name('setting.view')
        ->middleware(['can:view_setting,view_email_setting']);

    $router->get('category-list', 'categoryList')
        ->name('category.view')
        ->middleware(['can:view_category']);

    $router->get('payment-methods', 'paymentMethodList')
        ->name('payment-list.view')
        ->middleware(['can:view_payment_method']);

    $router->get('donation', 'donationList')
        ->name('donation-list.view')
        ->middleware(['can:view_donation']);


    $router->get('audio/reciter/list', 'audioReciterList')
        ->name('audio-reciter-list.view')
        ->middleware('can:view_reciter');

    $router->get('audio/reciter/sura/list/{reciter}', 'audioSuraList')
        ->name('audio-sura-list.view')
        ->middleware('can:view_reciter_sura');

    $router->get('audio/reciter/bulk-import', 'bulkSuraImport')
        ->name('audio-sura-bulk-import.view')
        ->middleware('can:import_reciter_sura');


    $router->get('my-profile', 'myProfile')->name('my-profile.view');

    // Landing Page admin sub-pages
    $router->get('landing/hero', 'landingHero')
        ->name('landing-hero.view')
        ->middleware('can:view_setting');
    $router->get('landing/stats', 'landingStats')
        ->name('landing-stats.view')
        ->middleware('can:view_setting');
    $router->get('landing/features', 'landingFeatures')
        ->name('landing-features.view')
        ->middleware('can:view_setting');
    $router->get('landing/sections', 'landingSections')
        ->name('landing-sections.view')
        ->middleware('can:view_setting');
    $router->get('landing/download', 'landingDownload')
        ->name('landing-download.view')
        ->middleware('can:view_setting');
    $router->get('landing/footer', 'landingFooter')
        ->name('landing-footer.view')
        ->middleware('can:view_setting');
    $router->get('landing/seo', 'landingSeo')
        ->name('landing-seo.view')
        ->middleware('can:view_setting');

    $router->get('blog/list', 'blogList')
        ->name('blog-list.view')
        ->middleware('can:view_setting');

});

Route::middleware(['admin','install'])->group(callback: function () {
    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('settings', [SettingsController::class, 'index'])->name('setting.index');
    Route::post('settings', [SettingsController::class, 'update'])->name('setting.update');
    Route::get('theme-presets', [SettingsController::class, 'themePresets'])->name('setting.theme-presets');
    Route::post('home-layout', [SettingsController::class, 'homeLayoutUpdate'])->name('setting.home-layout.update');
    Route::get('home-layout-presets', [SettingsController::class, 'homeLayoutPresets'])->name('setting.home-layout.presets');
    Route::post('privacy-support', [SettingsController::class, 'privacySupportUpdate'])->name('setting.update');
    Route::get('landing-settings', [LandingSettingController::class, 'index'])->name('landing-setting.index');
    Route::post('landing-settings', [LandingSettingController::class, 'update'])->name('landing-setting.update');
    Route::get('email-settings', [EmailSettingController::class, 'index'])
        ->name('email-setting.index');
    Route::post('email-settings', [EmailSettingController::class, 'update'])
        ->name('email-setting.update');
    Route::apiResource('dhikrs', DhikrController::class);
    Route::apiResource('dua', DuaController::class);
    Route::apiResource('wallpaper-category', WallpaperCategoryController::class);
    Route::apiResource('wallpaper', WallpaperController::class);
    Route::apiResource('sifats', SifatNameController::class);
    Route::apiResource('haram-codes', HaramCodeController::class);
    Route::apiResource('prayer-times', PrayerTimeController::class);
    Route::post('prayertime-import', [PrayerTimeImportController::class, 'import'])->name('prayer-times.import')->middleware('can:import_prayer_times');
    Route::apiResource('roles', RoleController::class);
    Route::apiResource('users', UserController::class);
    Route::post('user-invite', [UserInviteController::class, 'invite'])
        ->name('user.invite');
    Route::apiResource('payment-method', PaymentMethodController::class);
    Route::apiResource('category', CategoryController::class);
    Route::get('donation-list', [DonationController::class, 'index'])->name('donation.view');
    Route::delete('delete-prayer-times', [PrayerTimeController::class, 'deleteCityPrayerTimes'])->name('delete-prayer-times');

    Route::apiResource('blog-posts', BlogController::class)->parameters(['blog-posts' => 'blog']);
    Route::post('blog-posts-upload-image', [BlogController::class, 'uploadContentImage'])->name('blog-posts.upload-image');
    Route::post('blog-posts-upload-chunk', [BlogController::class, 'uploadThumbnailChunk'])->name('blog-posts.upload-chunk');
    Route::get('blog-posts-upload-chunk/status', [BlogController::class, 'thumbnailUploadStatus'])->name('blog-posts.upload-chunk.status');
    Route::post('blog-posts-upload-chunk/complete', [BlogController::class, 'completeThumbnailUpload'])->name('blog-posts.upload-chunk.complete');
    Route::delete('blog-posts-upload-chunk', [BlogController::class, 'cancelThumbnailUpload'])->name('blog-posts.upload-chunk.cancel');
    Route::apiResource('reciter', ReciterController::class);
    Route::get('reciter-sura-list/{reciter}', [ReciterSuraController::class, 'index'])->name('reciter-sura.view');
    Route::apiResource('reciter-sura', ReciterSuraController::class);
    Route::post('upload-chunk', [ReciterSuraController::class, 'uploadChunk'])->name('upload.chunk');
    Route::get('upload-chunk/status', [ReciterSuraController::class, 'uploadStatus'])->name('upload.chunk.status');
    Route::post('upload-chunk/complete', [ReciterSuraController::class, 'completeUpload'])->name('upload.chunk.complete');
    Route::delete('upload-chunk', [ReciterSuraController::class, 'cancelUpload'])->name('upload.chunk.cancel');

    // Bulk reciter-audio ZIP import
    Route::get('bulk-sura-import/reciters', [BulkSuraImportController::class, 'reciters'])->name('bulk-sura-import.reciters')->middleware('can:import_reciter_sura');
    Route::post('bulk-sura-import/upload-chunk', [BulkSuraImportController::class, 'uploadChunk'])->name('bulk-sura-import.upload-chunk')->middleware('can:import_reciter_sura');
    Route::get('bulk-sura-import/upload-chunk/status', [BulkSuraImportController::class, 'uploadStatus'])->name('bulk-sura-import.upload-chunk.status')->middleware('can:import_reciter_sura');
    Route::post('bulk-sura-import/upload-chunk/complete', [BulkSuraImportController::class, 'completeUpload'])->name('bulk-sura-import.upload-chunk.complete')->middleware('can:import_reciter_sura');
    Route::delete('bulk-sura-import/upload-chunk', [BulkSuraImportController::class, 'cancelUpload'])->name('bulk-sura-import.upload-chunk.cancel')->middleware('can:import_reciter_sura');
    Route::get('bulk-sura-import/{import}/progress', [BulkSuraImportController::class, 'progress'])->name('bulk-sura-import.progress')->middleware('can:import_reciter_sura');

});

Route::get('get-cities', [PrayerTimeController::class, 'getCities']);


Route::middleware('auth')->controller(ProfileController::class)->group(function (Router $router) {
    $router->get('profile', 'index')->name('my-profile');
    $router->post('profile-update', 'update')->name('profile.update');
    $router->post('profile-picture', 'profileThumbnail')->name('profile-picture.update');
    $router->post('password-change', 'passwordChange')->name('password-change');
});

// Supporting Routes for api
Route::middleware(['auth', 'authorize'])->group(callback: function (Router $router) {
    Route::get('finish-setup', [InitialSetupController::class, 'finish'])
        ->name('finish')
        ->middleware('can:view_setting');
    Route::get('finish-transliteration', [InitialSetupController::class, 'finishTransliteration'])
        ->name('finish.transliteration')
        ->middleware('can:view_setting');

    $router->get('permissions', [PermissionController::class, 'index'])
        ->name('permission.index')
        ->middleware(['can:view_roles', 'can:create_roles']);

    $router->post('logout', [LoginController::class, 'logOut'])->name('logout');
});

Route::get('install-demo-data', [InstallDemoDataController::class, 'run'])
    ->name('install-demo-data');
Route::get('symlink', [InstallDemoDataController::class, 'symlink']);


Route::get('blog', [BlogPublicController::class, 'index'])->name('blog.index');
Route::get('blog/{slug}', [BlogPublicController::class, 'show'])->name('blog.show');

Route::get('privacy-policy', [SupportController::class, 'privacyPolicy']);
Route::get('terms-and-conditions', [SupportController::class, 'termsCondition']);
Route::get('support', [SupportController::class, 'support']);




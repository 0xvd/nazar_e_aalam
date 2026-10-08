<?php

namespace App\Http\Controllers\Quran\Support;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SupportController extends Controller
{
    public function privacyPolicy()
    {
        return view('support.privacy-policy');
    }

    public function termsCondition()
    {
        return view('support.terms-condition');
    }

    public function support()
    {
        return view('support.support');
    }
}

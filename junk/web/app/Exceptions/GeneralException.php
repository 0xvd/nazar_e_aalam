<?php

namespace App\Exceptions;

use App\Exceptions\Concerns\ExceptionHelper;
use Exception;
use Illuminate\Http\Request;
use Throwable;

class GeneralException extends Exception
{
    use ExceptionHelper;
    public function __construct($message = '', $code = 403, Throwable $previous = null)
    {
        parent::__construct($message, $code, $previous);
    }

    public function report()
    {
        //
    }


    public function render(Request $request)
    {
        if ($request->expectsJson())
            return response(['status' => false, 'message' => $this->getMessage()], $this->getCode());

        if(view()->exists('custom_errors.'.$this->getCode()))
            return response()->view('custom_errors.'.$this->getCode(), ['message' => $this->getMessage()]);

        return redirect()
            ->back()
            ->withInput()
            ->withFlashDanger($this->message);
    }
}

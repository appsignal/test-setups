<?php

namespace App\Http\Controllers;

use App\BadClass;
use Appsignal\Appsignal;
use Illuminate\Http\Request;
use Throwable;

class ErrorsController extends Controller
{
    public function show(Request $request)
    {
        if ($request->input('debug') == 'true') {
            try {
                BadClass::throw();
            } catch (Throwable $e) {
                return $this->renderBacktraceView($e);
            }
        }

        return BadClass::throw();
    }

    public function wrapped(Request $request)
    {
        if ($request->input('debug') == 'true') {
            try {
                BadClass::throwWrapped();
            } catch (Throwable $e) {
                return $this->renderBacktraceView($e);
            }
        }

        return BadClass::throwWrapped();
    }

    public function handled()
    {
        try {
            BadClass::throwWrapped();
        } catch (Throwable $e) {
            Appsignal::setError($e);
        }

        return view('back', ['message' => 'Reported handled error to AppSignal']);
    }

    protected function renderBacktraceView(Throwable $e)
    {
        return response()->view('backtrace', [
            'error' => $e->getMessage(),
            'backtrace' => $e->getTraceAsString(),
        ], 500);
    }
}

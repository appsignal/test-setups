<?php

namespace App\Http\Controllers;

use Exception;
use OpenTelemetry\API\Trace\Span;
use OpenTelemetry\API\Trace\StatusCode;

class BacktraceController extends Controller
{
    public function backtrace()
    {
        try {
            $this->methodA();
        } catch (Exception $e) {
            $span = Span::getCurrent();
            $span->recordException($e);
            $span->setStatus(StatusCode::STATUS_ERROR, $e->getMessage());

            return response()->view('backtrace', [
                'note' => "<strong>Note:</strong> This error was intentionally thrown and caught to demonstrate PHP backtrace functionality. The error flows through multiple methods (A → B → C → D → E → F → throwError) to create an extensive call stack. The error has been reported to AppSignal via OpenTelemetry.",
                'error' => $e->getMessage(),
                'backtrace' => $e->getTraceAsString()
            ], 500);
        }
    }

    private function methodA()
    {
        usleep(50000); // 50ms delay
        return $this->methodB();
    }

    private function methodB()
    {
        usleep(30000); // 30ms delay
        return $this->methodC();
    }

    private function methodC()
    {
        usleep(20000); // 20ms delay
        return $this->methodD();
    }

    private function methodD()
    {
        usleep(10000); // 10ms delay
        return $this->methodE();
    }

    private function methodE()
    {
        usleep(5000); // 5ms delay
        return $this->methodF();
    }

    private function methodF()
    {
        return $this->throwError();
    }

    private function throwError()
    {
        throw new Exception('Deep stack trace error from methodF -> throwError');
    }
}

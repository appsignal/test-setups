<?php

namespace App;

class ErrorHandler
{
    public function throwError()
    {
        $this->realThrowError();
    }

    private function realThrowError()
    {
        throw new \Exception('Uh oh!');
    }
}

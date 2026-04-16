<?php

namespace App;

use Exception;
use Throwable;

class BadClass
{
    public static function throw(): void
    {
        throw new Exception('Inner');
    }

    public static function throwWrapped(): void
    {
        try {
            static::throw();
        } catch (Throwable $e) {
            throw new Exception('Wrapper', 0, $e);
        }
    }
}

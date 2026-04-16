<?php

namespace App;

class ErrorsController
{
    public function show(): void
    {
        BadClass::throw();
    }

    public function wrapped(): void
    {
        BadClass::throwWrapped();
    }
}

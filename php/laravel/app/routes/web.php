<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/extension', function () {
    return extension_loaded("opentelemetry") ? "yes" : "no";
});

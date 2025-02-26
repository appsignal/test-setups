<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/slow', function () {
    sleep(3);
    return view('slow');
});

Route::get('/error', function () {
  throw new Exception('Uh oh!');
});

Route::get('/extension', function () {
    return extension_loaded("opentelemetry") ? "yes" : "no";
});

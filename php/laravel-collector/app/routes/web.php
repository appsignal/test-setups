<?php

use OpenTelemetry\API\Trace\Span;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $params = [
        'param1' => 'value1',
        'param2' => 'value2',
        'nested' => [
            'param3' => 'value3',
            'param4' => 'value4',
        ],
    ];
    $json = json_encode($params);
    
    $span = Span::getCurrent();
    $span->setAttribute(
        'appsignal.function.parameters',
        $json
    );

    $span->setAttribute("appsignal.tag.user_id", 123);
    $span->setAttribute("appsignal.tag.my_tag_string", "tag value");
    $span->setAttribute("appsignal.tag.my_tag_string_slice", ["abc", "def"]);
    $span->SetAttribute("appsignal.tag.my_tag_bool_true", true);
    $span->SetAttribute("appsignal.tag.my_tag_bool_false", false);
    $span->SetAttribute("appsignal.tag.my_tag_bool_slice", [true, false]);
    $span->SetAttribute("appsignal.tag.my_tag_float64", 12.34);
    $span->SetAttribute("appsignal.tag.my_tag_float64_slice", [12.34, 56.78]);
    $span->SetAttribute("appsignal.tag.my_tag_int", 1234);
    $span->SetAttribute("appsignal.tag.my_tag_int_slice", [1234, 5678]);
    $span->SetAttribute("appsignal.tag.my_tag_int64", 1234);
    $span->SetAttribute("appsignal.tag.my_tag_int64_slice", [1234, 5678]);
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

Route::get('/queue', function () {
    \App\Jobs\ExampleJob::dispatch(['time' => time()]);
    return "Job dispatched";
});

Route::get('/logs', function () {
    Log::info('Logging a message');
    Log::error('Logging an error message');
    Log::info('Logging a fancy message', ['some' => 'context']);
});

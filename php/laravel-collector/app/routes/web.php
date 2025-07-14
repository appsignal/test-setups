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

Route::get('/io', function () {
    $results = [];
    $tempFile = storage_path('app/temp_io_test.txt');

    // file_put_contents - Write data to file
    $content = "IO test content - " . date('Y-m-d H:i:s') . "\n";
    file_put_contents($tempFile, $content);
    $results[] = "file_put_contents: File written to " . $tempFile;

    // file_get_contents - Read entire file into string
    $readContent = file_get_contents($tempFile);
    $results[] = "file_get_contents: Read content - " . trim($readContent);

    // fopen - Open file for stream operations
    $stream = fopen($tempFile, 'a+');
    $results[] = "fopen: Opened file stream for " . $tempFile;

    // fwrite - Write to file stream
    $additionalContent = "Additional line via fwrite\n";
    fwrite($stream, $additionalContent);
    $results[] = "fwrite: Wrote additional content to stream";

    // fread - Read from file stream
    rewind($stream); // Reset to beginning
    $streamContent = fread($stream, 100);
    $results[] = "fread: Read from stream - " . trim($streamContent);

    // Close stream and clean up
    fclose($stream);
    unlink($tempFile);
    $results[] = "Cleanup: File deleted";

    return response()->json([
        'message' => 'OpenTelemetry IO instrumentation test completed',
        'results' => $results
    ]);
});

Route::get('/backtrace', [App\Http\Controllers\BacktraceController::class, 'backtrace']);

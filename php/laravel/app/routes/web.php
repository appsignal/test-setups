<?php

use App\Http\Controllers\BacktraceController;
use App\Http\Controllers\ErrorsController;
use App\Jobs\ExampleJob;
use Appsignal\Appsignal;
use Illuminate\Support\Facades\Log;
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

    Appsignal::addAttributes([
        'appsignal.function.parameters' => json_encode($params),
    ]);

    Appsignal::addAttributes([
        'appsignal.tag.user_id' => 123,
        'appsignal.tag.my_tag_string' => 'tag value',
        'appsignal.tag.my_tag_string_slice' => ['abc', 'def'],
        'appsignal.tag.my_tag_bool_true' => true,
        'appsignal.tag.my_tag_bool_false' => false,
        'appsignal.tag.my_tag_bool_slice' => [true, false],
        'appsignal.tag.my_tag_float64' => 12.34,
        'appsignal.tag.my_tag_float64_slice' => [12.34, 56.78],
        'appsignal.tag.my_tag_int' => 1234,
        'appsignal.tag.my_tag_int_slice' => [1234, 5678],
        'appsignal.tag.my_tag_int64' => 1234,
        'appsignal.tag.my_tag_int64_slice' => [1234, 5678],
    ]);

    return view('welcome');
});

Route::get('/slow', function () {
    sleep(3);

    return view('slow');
});

Route::get('/extension', function () {
    $extensionLoaded = extension_loaded('opentelemetry') ? 'yes' : 'no';

    return view('back', ['message' => $extensionLoaded]);
});

Route::get('/queue', function () {
    ExampleJob::dispatch(['time' => time()]);

    return view('back', ['message' => 'Job dispatched']);
});

Route::get('/io', function () {
    $results = [];
    $tempFile = storage_path('app/temp_io_test.txt');

    // file_put_contents - Write data to file
    $content = 'IO test content - '.date('Y-m-d H:i:s')."\n";
    file_put_contents($tempFile, $content);
    $results[] = 'file_put_contents: File written to '.$tempFile;

    // file_get_contents - Read entire file into string
    $readContent = file_get_contents($tempFile);
    $results[] = 'file_get_contents: Read content - '.trim($readContent);

    // fopen - Open file for stream operations
    $stream = fopen($tempFile, 'a+');
    $results[] = 'fopen: Opened file stream for '.$tempFile;

    // fwrite - Write to file stream
    $additionalContent = "Additional line via fwrite\n";
    fwrite($stream, $additionalContent);
    $results[] = 'fwrite: Wrote additional content to stream';

    // fread - Read from file stream
    rewind($stream); // Reset to beginning
    $streamContent = fread($stream, 100);
    $results[] = 'fread: Read from stream - '.trim($streamContent);

    // Close stream and clean up
    fclose($stream);
    unlink($tempFile);
    $results[] = 'Cleanup: File deleted';

    return view('back', [
        'message' => 'OpenTelemetry IO instrumentation test completed',
        'json' => $results,
    ]);
});

Route::get('/backtrace', [BacktraceController::class, 'backtrace']);

Route::get('/instrument', function () {
    Appsignal::instrument(
        'my-span',
        [
            'string-attribute' => 'abcdef',
            'int-attribute' => 1234,
            'bool-attribute' => true,
        ],
        closure: fn () => null,
    );

    return view('back', ['message' => 'Added a span to this trace.']);
});

Route::get('/instrument-nested', function () {
    Appsignal::instrument('parent', ['msg' => 'from parent span'], closure: function () {
        $span = Appsignal::instrument('child', ['msg' => 'from child span']);
        $span->end();
    });

    return view('back', ['message' => 'Added nested spans to this trace.']);
});

Route::get('/set-action', function () {
    Appsignal::setAction('my action');

    return view('back', ['message' => 'Set custom action name for this trace.']);
});

Route::get('/custom-data', function () {
    Appsignal::addAttributes([
        'string-attribute' => 'abcdef',
        'int-attribute' => 1234,
        'bool-attribute' => true,
    ]);

    return view('back', ['message' => 'Set custom data for this trace.']);
});

Route::get('/tags', function () {
    Appsignal::addTags([
        'string-tag' => 'some value',
        'integer-tag' => 1234,
        'bool-tag' => true,
    ]);

    return view('back', ['message' => 'Added tags to this trace.']);
});

Route::get('/log', function () {
    Log::info('My log');

    return view('back', ['message' => 'Sent a log.']);
});

Route::get('/logs', function () {
    Log::info('Logging a message');
    Log::error('Logging an error message');
    Log::info('Logging a fancy message', ['some' => 'context']);

    return view('back', ['message' => 'Sent multiple logs.']);
});

Route::get('/log-with-attributes', function () {
    Log::info('My log with attributes', ['foo' => 'bar']);

    return view('back', ['message' => 'Sent a log with attributes.']);
});

Route::get('/set-gauge', function () {
    Appsignal::setGauge('my_gauge', 12);
    Appsignal::setGauge('my_gauge_with_attributes', 13, ['region' => 'eu']);

    return view('back', ['message' => 'Set a gauge with and without attributes.']);
});

Route::get('/add-distribution-value', function () {
    Appsignal::addDistributionValue('my_distribution', 50);
    Appsignal::addDistributionValue('my_distribution', 70);

    Appsignal::addDistributionValue('my_distribution_with_attributes', 10, ['region' => 'eu']);
    Appsignal::addDistributionValue('my_distribution_with_attributes', 20, ['region' => 'eu']);
    Appsignal::addDistributionValue('my_distribution_with_attributes', 30, ['region' => 'eu']);

    return view('back', ['message' => 'Added values to a distribution with and without attributes.']);
});

Route::get('/counter', function () {
    Appsignal::incrementCounter('my_counter', 1);
    Appsignal::incrementCounter('my_counter', 3, ['region' => 'eu']);

    return view('back', ['message' => 'Incremented counter with and without attributes.']);
});

Route::get('/error', [ErrorsController::class, 'show']);
Route::get('/error-wrapped', [ErrorsController::class, 'wrapped']);
Route::get('/error-handled', [ErrorsController::class, 'handled']);

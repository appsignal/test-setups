@props(['json' => null])
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Laravel</title>
    </head>
    <body>
        <p>{{ $message }}</p>
        @if($json)
            <pre>{!! json_encode($json, JSON_PRETTY_PRINT) !!}</pre>
        @endif

        <p><a href="/">← Back to Home</a></p>
    </body>
</html>

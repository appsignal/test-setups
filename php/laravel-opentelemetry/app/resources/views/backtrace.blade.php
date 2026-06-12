<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP Backtrace Test</title>
</head>
<body>
    <h1>PHP Backtrace Test</h1>

    <p><strong>Error:</strong> {{ $error }}</p>

    <p>{{ $note }}</p>

    <h2>PHP Backtrace (via $e->getTraceAsString())</h2>
    <pre>{{ $backtrace }}</pre>

    <a href="/">← Back to Home</a>
</body>
</html>
